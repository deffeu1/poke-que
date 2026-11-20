extends Area2D

@export var solo_tras_derrotar_jefe: bool = true
@export var mensaje_victoria: String = "¡Has recuperado el Orbe Místico, "

@onready var sprite: Node2D = $AnimatedSprite2D
@onready var audio_orbe: AudioStreamPlayer = $AudioOrbe

var recogido: bool = false

func _ready() -> void:
	iniciar_animacion_orbe()

func iniciar_animacion_orbe() -> void:
	var pos_base: Vector2 = sprite.position
	var tween := create_tween().set_loops()
	tween.tween_property(sprite, "position:y", pos_base.y - 5.0, 0.85).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(sprite, "modulate", Color(1.4, 1.8, 2.2), 0.85)
	tween.tween_property(sprite, "position:y", pos_base.y, 0.85).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.85)

func _on_body_entered(body: Node2D) -> void:
	if recogido or not body.is_in_group("player"):
		return
	if solo_tras_derrotar_jefe and not ("boss_final" in GameManager.defeated_enemies):
		return
		
	recogido = true
	if body.has_method("set_physics_process"):
		body.set_physics_process(false)
		
	# Frena la música de fondo del mapa y reproduce el sonido del Orbe
	var musica_mapa := get_tree().current_scene.find_child("MusicaAmbiente", true, false)
	if musica_mapa is AudioStreamPlayer:
		musica_mapa.stop()
	audio_orbe.play()
		
	var tween := create_tween()
	tween.tween_property(sprite, "scale", sprite.scale * 1.5, 0.35)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.35)
	await tween.finished
	
	await mostrar_dialogo_final()
	
	GameManager.game_won = true
	SceneTransition.cambiar_escena("res://escenas/EndScreen.tscn")

func mostrar_dialogo_final() -> void:
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
	texto.text = mensaje_victoria + GameManager.player_name + "! El sacrificio del Guardián no fue en vano. La mazmorra por fin está en paz."
	margen.add_child(texto)
	
	await get_tree().process_frame
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("interactuar") or Input.is_action_just_pressed("ui_accept"):
			break
			
	capa.queue_free()
