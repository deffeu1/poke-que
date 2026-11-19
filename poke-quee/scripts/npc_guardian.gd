extends StaticBody2D

@export var desplazamiento_al_abrir: Vector2 = Vector2(48, 0)
@export var celdas_puerta: Array[Vector2i] = [Vector2i(5, 37), Vector2i(6, 37)]
@export var capa_puerta: TileMapLayer

@onready var prompt_label: Label = $PromptLabel
@onready var dialogue_box: PanelContainer = $DialogueLayer/DialogueBox
@onready var dialogue_text: Label = $DialogueLayer/DialogueBox/DialogueText
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


var player_in_range: bool = false
var player_ref: Node2D = null
var hablando: bool = false

func _ready() -> void:
	anim.play("idle")
	prompt_label.visible = false
	dialogue_box.visible = false
	if GameManager.gate_unlocked:
		position += desplazamiento_al_abrir
		abrir_puerta()

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
		
	dialogue_box.visible = true
	
	if GameManager.gate_unlocked:
		dialogue_text.text = "El camino ya está despejado. ¡Suerte ahí adelante!"
	elif GameManager.has_key:
		dialogue_text.text = "¡Conseguiste la llave! Ya mismo me corro para que podamos salir de acá."
		GameManager.has_key = false
		GameManager.gate_unlocked = true
		GameManager.talked_to_guardian = true
		apartarse()
	elif not GameManager.talked_to_guardian:
		dialogue_text.text = "¡Ey, no ataques! Yo no soy como esos salvajes. Necesito que me traigas la llave de esta puerta para poder salir de acá."
		GameManager.talked_to_guardian = true
	else:
		dialogue_text.text = "¿Ya encontraste la llave? Seguí buscando por las otras salas y traémela."

func cerrar_dialogo() -> void:
	hablando = false
	dialogue_box.visible = false
	
	if player_ref and player_ref.has_method("set_physics_process"):
		player_ref.set_physics_process(true)
	if player_in_range:
		prompt_label.visible = true

func apartarse() -> void:
	abrir_puerta()
	if anim.sprite_frames.has_animation("walk_right"):
		anim.play("walk_right")
		
	var tween := create_tween()
	tween.tween_property(self, "position:x", position.x + desplazamiento_al_abrir.x, 0.6)
	await tween.finished
	
	if anim.sprite_frames.has_animation("idle"):
		anim.play("idle")

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		if not hablando:
			prompt_label.visible = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_in_range = false
		player_ref = null
		prompt_label.visible = false

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
