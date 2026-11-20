extends CharacterBody2D

@export var velocidad_seguimiento: float = 115.0
@export var distancia_arranque: float = 52.0
@export var distancia_frenado: float = 36.0
@export var capa_puerta: TileMapLayer
@export var celdas_puerta: Array[Vector2i] = [Vector2i(5, 37), Vector2i(6, 37)]

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var prompt_label: Label = $PromptLabel
@onready var dialogue_box: PanelContainer = $DialogueLayer/DialogueBox
@onready var dialogue_text: Label = $DialogueLayer/DialogueBox/DialogueText

var siguiendo_activo: bool = false
var player_in_range: bool = false
var player_ref: Node2D = null
var hablando: bool = false
var ultima_direccion: String = "up"

func _ready() -> void:
	prompt_label.visible = false
	dialogue_box.visible = false
	
	if GameManager.guardian_dead:
		abrir_puerta()
		queue_free()
		return
		
	if GameManager.gate_unlocked:
		abrir_puerta()
		colision.disabled = true
		ultima_direccion = "down"
		
	if GameManager.guardian_following:
		var jugador := get_tree().get_first_node_in_group("player")
		if jugador != null:
			player_ref = jugador
			global_position = jugador.global_position + Vector2(-24, 0)
			
	reproducir_idle()

func _physics_process(_delta: float) -> void:
	if not GameManager.guardian_following or hablando or GameManager.guardian_dead:
		velocity = Vector2.ZERO
		siguiendo_activo = false
		return
		
	if player_ref == null:
		player_ref = get_tree().get_first_node_in_group("player")
		if player_ref == null:
			return
			
	var vector_hacia_jugador := player_ref.global_position - global_position
	var distancia := vector_hacia_jugador.length()
	
	if distancia > distancia_arranque:
		siguiendo_activo = true
	elif distancia <= distancia_frenado:
		siguiendo_activo = false
		
	if siguiendo_activo:
		var direccion := vector_hacia_jugador.normalized()
		velocity = direccion * velocidad_seguimiento
		move_and_slide()
		actualizar_animacion_caminar(direccion)
	else:
		velocity = Vector2.ZERO
		reproducir_idle()

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interactuar"):
		if not hablando:
			iniciar_dialogo()
		else:
			cerrar_dialogo()

func iniciar_dialogo() -> void:
	hablando = true
	prompt_label.visible = false
	if player_ref and player_ref.has_method("set_physics_process"):
		player_ref.set_physics_process(false)
		
	if player_ref != null:
		mirar_hacia(player_ref.global_position - global_position)
		
	dialogue_box.visible = true
	
	if GameManager.guardian_following:
		dialogue_text.text = "Estoy justo detrás tuyo, " + GameManager.player_name + ". ¡Tengamos cuidado con lo que hay más adelante!"
	elif GameManager.has_key:
		dialogue_text.text = "¡Conseguiste la llave, " + GameManager.player_name + "! Ya abrí la puerta. Voy con vos, juntos tenemos más chances de salir."
		GameManager.has_key = false
		GameManager.gate_unlocked = true
		GameManager.talked_to_guardian = true
		GameManager.guardian_following = true
		colision.disabled = true
		abrir_puerta()
	elif not GameManager.talked_to_guardian:
		dialogue_text.text = "¡Ey, no ataques! Yo no soy como esos salvajes. Necesito que me traigas la llave de esta puerta para poder salir de acá."
		GameManager.talked_to_guardian = true
	else:
		dialogue_text.text = "¿Ya encontraste la llave, " + GameManager.player_name + "? Seguí buscando por las otras salas y traémela."

func cerrar_dialogo() -> void:
	hablando = false
	dialogue_box.visible = false
	
	if not GameManager.guardian_following:
		ultima_direccion = "up"
		reproducir_idle()
		
	if player_ref and player_ref.has_method("set_physics_process"):
		player_ref.set_physics_process(true)
	if player_in_range and not GameManager.guardian_following:
		prompt_label.visible = true

func abrir_puerta() -> void:
	var mapa: Node = capa_puerta
	if mapa == null:
		mapa = get_tree().current_scene.find_child("cosas", true, false)
	if mapa == null:
		return
	for celda in celdas_puerta:
		if mapa is TileMapLayer:
			mapa.erase_cell(celda)
		elif mapa is TileMap:
			mapa.erase_cell(0, celda)

func mirar_hacia(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		ultima_direccion = "right" if dir.x > 0 else "left"
	else:
		ultima_direccion = "down" if dir.y > 0 else "up"
	reproducir_idle()

func actualizar_animacion_caminar(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y) + 0.15:
		ultima_direccion = "right" if dir.x > 0 else "left"
	elif abs(dir.y) > abs(dir.x) + 0.15:
		ultima_direccion = "down" if dir.y > 0 else "up"
	reproducir_animacion("walk_" + ultima_direccion)

func reproducir_idle() -> void:
	var frames := anim.sprite_frames
	if frames == null:
		return
	var anim_idle := "idle_" + ultima_direccion
	if frames.has_animation(anim_idle):
		reproducir_animacion(anim_idle)
	elif frames.has_animation("idle_down"):
		reproducir_animacion("idle_down")
	elif frames.has_animation("idle"):
		reproducir_animacion("idle")
	elif frames.get_animation_names().size() > 0:
		reproducir_animacion(frames.get_animation_names()[0])

func reproducir_animacion(nombre: String) -> void:
	if anim.sprite_frames != null and anim.sprite_frames.has_animation(nombre):
		if anim.animation != nombre or not anim.is_playing():
			anim.play(nombre)

func morir_en_cinematica() -> void:
	GameManager.guardian_following = false
	GameManager.guardian_dead = true
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1, 0.15, 0.15), 0.1)
	tween.tween_property(self, "rotation_degrees", 90.0, 0.25)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	queue_free()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		if not hablando and not GameManager.guardian_following:
			prompt_label.visible = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_in_range = false
		prompt_label.visible = false
