extends CharacterBody2D

@export var speed: float = 40.0
@export var wander_radius: float = 64.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var wander_timer: Timer = $WanderTimer
@onready var detection_area: Area2D = $DetectionArea
@onready var exclamation: Label = $ExclamationLabel
@onready var raycast: RayCast2D = $RayCast2D

var start_position: Vector2
var move_dir: Vector2 = Vector2.ZERO
var last_dir: String = "down"
var player_detected: bool = false
var player_in_range: Node2D = null

func _ready() -> void:
	if GameManager.defeated_enemies.has(name):
		queue_free()
		return
		
	start_position = global_position
	exclamation.visible = false
	elegir_nueva_accion()

func _physics_process(_delta: float) -> void:
	if player_detected:
		velocity = Vector2.ZERO
		return
		
	if player_in_range != null:
		verificar_linea_de_vision(player_in_range)
		if player_detected:
			return
			
	velocity = move_dir * speed
	move_and_slide()
	
	if is_on_wall() or global_position.distance_to(start_position) > wander_radius:
		move_dir = (start_position - global_position).normalized()
		if abs(move_dir.x) > abs(move_dir.y):
			move_dir = Vector2(sign(move_dir.x), 0)
		else:
			move_dir = Vector2(0, sign(move_dir.y))
			
	actualizar_animacion_y_vision(move_dir)

func verificar_linea_de_vision(objetivo: Node2D) -> void:
	raycast.target_position = to_local(objetivo.global_position)
	raycast.force_raycast_update()
	
	if raycast.is_colliding() and raycast.get_collider() != objetivo:
		return
		
	player_detected = true
	move_dir = Vector2.ZERO
	anim.play("idle_" + last_dir)
	
	GameManager.current_enemy_id = name
	GameManager.last_player_position = objetivo.global_position
	GameManager.has_saved_position = true

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null

func _on_wander_timer_timeout() -> void:
	if not player_detected:
		elegir_nueva_accion()

func elegir_nueva_accion() -> void:
	var opciones := [
		Vector2.ZERO,
		Vector2.ZERO,
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2.UP,
		Vector2.DOWN
	]
	move_dir = opciones.pick_random()
	wander_timer.wait_time = randf_range(1.0, 2.5)

func actualizar_animacion_y_vision(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		anim.play("idle_" + last_dir)
		return
		
	if dir.x > 0:
		last_dir = "right"
		anim.play("walk_right")
		detection_area.rotation_degrees = -90
	elif dir.x < 0:
		last_dir = "left"
		anim.play("walk_left")
		detection_area.rotation_degrees = 90
	elif dir.y > 0:
		last_dir = "down"
		anim.play("walk_down")
		detection_area.rotation_degrees = 0
	elif dir.y < 0:
		last_dir = "up"
		anim.play("walk_up")
		detection_area.rotation_degrees = 180

func mostrar_exclamacion() -> void:
	exclamation.visible = true
	var pos_original := exclamation.position
	var tween := create_tween()
	tween.tween_property(exclamation, "position:y", pos_original.y - 8, 0.12).set_trans(Tween.TRANS_BACK)
	tween.tween_property(exclamation, "position:y", pos_original.y, 0.12)
	
	await get_tree().create_timer(0.8).timeout
	get_tree().change_scene_to_file("res://escenas/BattleScene.tscn")
