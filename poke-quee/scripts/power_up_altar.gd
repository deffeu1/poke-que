extends Area2D

@export var bonus_max_hp: int = 40
@export var bonus_max_mana: int = 30
@export var mensaje_obtencion: String = "¡Una energía ancestral recorre tu cuerpo! Tu ataque, vida máxima (+40 PS) y maná máximo (+30 PM) aumentaron. Ahora podés enfrentar al Señor de la Mazmorra."

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var prompt_label: Label = $PromptLabel

var player_in_range: bool = false
var player_ref: Node2D = null
var activado: bool = false
var tween_flotacion: Tween = null
var escala_inicial: Vector2 = Vector2.ONE

func _ready() -> void:
	prompt_label.visible = false
	escala_inicial = sprite.scale
	sprite.stop()
	
	var anim_nombre := obtener_nombre_animacion()
	if anim_nombre != "":
		sprite.animation = anim_nombre
		sprite.sprite_frames.set_animation_loop(anim_nombre, false)
		if GameManager.player_has_powerup:
			activado = true
			sprite.frame = sprite.sprite_frames.get_frame_count(anim_nombre) - 1
			return
		else:
			sprite.frame = 0
			
	iniciar_animacion_idle()

func obtener_nombre_animacion() -> String:
	if sprite.sprite_frames == null:
		return ""
	var nombres := sprite.sprite_frames.get_animation_names()
	if nombres.size() > 0:
		return nombres[0]
	return ""

func iniciar_animacion_idle() -> void:
	tween_flotacion = create_tween().set_loops()
	tween_flotacion.tween_property(sprite, "modulate", Color(1.35, 1.25, 0.85), 0.9).set_trans(Tween.TRANS_SINE)
	tween_flotacion.tween_property(sprite, "modulate", Color.WHITE, 0.9).set_trans(Tween.TRANS_SINE)

func _process(_delta: float) -> void:
	if activado or not player_in_range:
		return
	if Input.is_action_just_pressed("interactuar"):
		activar_powerup()

func activar_powerup() -> void:
	activado = true
	prompt_label.visible = false
	
	if tween_flotacion != null:
		tween_flotacion.kill()
	sprite.modulate = Color.WHITE
	
	if player_ref != null and player_ref.has_method("set_physics_process"):
		player_ref.set_physics_process(false)
		
	var anim_nombre := obtener_nombre_animacion()
	if anim_nombre != "":
		sprite.play(anim_nombre)
		await sprite.animation_finished
		sprite.pause()
		sprite.frame = sprite.sprite_frames.get_frame_count(anim_nombre) - 1
		
	if player_ref != null:
		var tween_player := create_tween()
		tween_player.tween_property(player_ref, "modulate", Color(1.8, 1.6, 0.8), 0.25)
		tween_player.tween_property(player_ref, "modulate", Color.WHITE, 0.35)
		
	GameManager.player_has_powerup = true
	GameManager.player_max_hp += bonus_max_hp
	GameManager.player_hp = GameManager.player_max_hp
	GameManager.player_max_mana += bonus_max_mana
	GameManager.player_mana = GameManager.player_max_mana
	GameManager.stats_changed.emit()
	
	await mostrar_dialogo_powerup()
	
	if player_ref != null and player_ref.has_method("set_physics_process"):
		player_ref.set_physics_process(true)

func mostrar_dialogo_powerup() -> void:
	var capa := CanvasLayer.new()
	capa.layer = 25
	get_tree().current_scene.add_child(capa)
	
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_left = 80
	panel.offset_right = -80
	panel.offset_top = -140
	panel.offset_bottom = -24
	capa.add_child(panel)
	
	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 20)
	margen.add_theme_constant_override("margin_right", 20)
	margen.add_theme_constant_override("margin_top", 16)
	margen.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margen)
	
	var texto := Label.new()
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.text = mensaje_obtencion
	margen.add_child(texto)
	
	await get_tree().process_frame
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("interactuar") or Input.is_action_just_pressed("ui_accept"):
			break
			
	capa.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		if not activado:
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_in_range = false
		prompt_label.visible = false
