extends CharacterBody2D

@export var boss_name: String = "Señor de la Mazmorra"
@export var boss_max_hp: int = 140
@export var min_dmg: int = 16
@export var max_dmg: int = 26

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var cinematica_iniciada: bool = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	if cinematica_iniciada or not body.is_in_group("player"):
		return
	if GameManager.boss_first_encounter_done and not GameManager.player_has_powerup:
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
		
	GameManager.has_saved_position = true
	GameManager.saved_player_position = body.global_position
	GameManager.is_boss_battle = true
	GameManager.current_enemy_id = "boss_final"
	GameManager.current_enemy_name = boss_name
	GameManager.current_enemy_max_hp = boss_max_hp
	GameManager.current_enemy_min_dmg = min_dmg
	GameManager.current_enemy_max_dmg = max_dmg
	GameManager.current_enemy_frames = anim.sprite_frames
	
	var tilemap := get_tree().current_scene.find_child("piso", true, false)
	if tilemap is TileMapLayer:
		GameManager.saved_player_position = tilemap.to_global(tilemap.map_to_local(Vector2i(5, 37))) + Vector2(8, 32)
	else:
		GameManager.saved_player_position = Vector2(88, 624)
		
	GameManager.has_saved_position = true
	SceneTransition.cambiar_escena("res://escenas/battle_scene.tscn")

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
