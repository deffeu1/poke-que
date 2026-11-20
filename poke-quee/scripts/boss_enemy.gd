extends CharacterBody2D

@export var boss_name: String = "Señor de la Mazmorra"
@export var boss_max_hp: int = 140
@export var min_dmg: int = 16
@export var max_dmg: int = 26
@export var segunda_ubicacion: Marker2D
@export var coordenadas_segunda_sala: Vector2 = Vector2.ZERO
@export var distancia_rechazo_izquierda: float = 48.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var cinematica_iniciada: bool = false
var rechazando_entrada: bool = false

func _ready() -> void:
	if "boss_final" in GameManager.defeated_enemies:
		queue_free()
		return
		
	if GameManager.boss_first_encounter_done:
		if segunda_ubicacion != null:
			global_position = segunda_ubicacion.global_position
		elif coordenadas_segunda_sala != Vector2.ZERO:
			global_position = coordenadas_segunda_sala

func _on_detection_area_body_entered(body: Node2D) -> void:
	if cinematica_iniciada or rechazando_entrada or not body.is_in_group("player"):
		return
		
	if GameManager.boss_first_encounter_done and not GameManager.player_has_powerup:
		rechazar_entrada_jugador(body)
		return
		
	cinematica_iniciada = true
	
	if body.has_method("set_physics_process"):
		body.set_physics_process(false)
		
	var guardian := get_tree().get_first_node_in_group("guardian")
	if guardian != null and not GameManager.guardian_dead:
		GameManager.guardian_following = false
		var pos_guardian: Vector2 = guardian.global_position
		var tween := create_tween()
		tween.tween_property(self, "global_position", pos_guardian + Vector2(28, 0), 0.45)
		await tween.finished
		
		if anim.sprite_frames.has_animation("attack"):
			anim.play("attack")
			
		sacudir_camara()
		if guardian.has_method("morir_en_cinematica"):
			await guardian.morir_en_cinematica()
		await get_tree().create_timer(0.5).timeout
	elif GameManager.boss_first_encounter_done and GameManager.player_has_powerup:
		await mostrar_dialogo_revancha()
		
	if not GameManager.boss_first_encounter_done:
		var tilemap := get_tree().current_scene.find_child("piso", true, false)
		if tilemap is TileMapLayer:
			GameManager.saved_player_position = tilemap.to_global(tilemap.map_to_local(Vector2i(5, 37))) + Vector2(8, 32)
		else:
			GameManager.saved_player_position = Vector2(88, 624)
	else:
		GameManager.saved_player_position = body.global_position
		
	GameManager.has_saved_position = true
	GameManager.is_boss_battle = true
	GameManager.current_enemy_id = "boss_final"
	GameManager.current_enemy_name = boss_name
	GameManager.current_enemy_max_hp = boss_max_hp
	GameManager.current_enemy_min_dmg = min_dmg
	GameManager.current_enemy_max_dmg = max_dmg
	GameManager.current_enemy_frames = anim.sprite_frames
	
	SceneTransition.cambiar_escena("res://escenas/battle_scene.tscn")

func mostrar_dialogo_revancha() -> void:
	var lineas: Array[String] = [
		boss_name + ": ¿Otra vez vos, " + GameManager.player_name + "? Creí haberte aplastado la última vez... aunque esa energía que emanás es distinta.",
		GameManager.player_name + ": Este poder es por el Guardián. ¡Hoy se termina todo!"
	]
	
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
	texto.text = lineas[0]
	margen.add_child(texto)
	
	var indice: int = 0
	await get_tree().process_frame
	while indice < lineas.size():
		await get_tree().process_frame
		if Input.is_action_just_pressed("interactuar") or Input.is_action_just_pressed("ui_accept"):
			indice += 1
			if indice < lineas.size():
				texto.text = lineas[indice]
				
	capa.queue_free()

func rechazar_entrada_jugador(player: Node2D) -> void:
	rechazando_entrada = true
	if player.has_method("set_physics_process"):
		player.set_physics_process(false)
		
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
	texto.text = "Su aura oscura me impide avanzar... Todavía no tengo la fuerza suficiente. Necesito encontrar el poder oculto antes de volver a enfrentarlo."
	margen.add_child(texto)
	
	await get_tree().process_frame
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("interactuar") or Input.is_action_just_pressed("ui_accept"):
			break
			
	capa.queue_free()
	
	var player_anim := player.find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D
	if player_anim != null and player_anim.sprite_frames != null and player_anim.sprite_frames.has_animation("walk_left"):
		player_anim.play("walk_left")
		
	var destino := player.global_position + Vector2(-distancia_rechazo_izquierda, 0)
	var tween := create_tween()
	tween.tween_property(player, "global_position", destino, 0.45)
	await tween.finished
	
	if player_anim != null and player_anim.sprite_frames != null and player_anim.sprite_frames.has_animation("idle_left"):
		player_anim.play("idle_left")
		
	if player.has_method("set_physics_process"):
		player.set_physics_process(true)
		
	await get_tree().create_timer(0.3).timeout
	rechazando_entrada = false

func sacudir_camara() -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var offset_original := cam.offset
	var tween := create_tween()
	tween.tween_property(cam, "offset", offset_original + Vector2(8, -6), 0.05)
	tween.tween_property(cam, "offset", offset_original + Vector2(-8, 6), 0.05)
	tween.tween_property(cam, "offset", offset_original + Vector2(5, 4), 0.05)
	tween.tween_property(cam, "offset", offset_original, 0.05)
