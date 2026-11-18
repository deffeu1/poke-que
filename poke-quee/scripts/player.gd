extends CharacterBody2D

@export var speed: float = 100.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Guarda la última dirección (por defecto mirando hacia abajo)
var last_dir: String = "down"
var can_move: bool = true


func _ready() -> void:
	if GameManager.has_saved_position:
		global_position = GameManager.last_player_position

func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Bloquea movimiento diagonal
	if input_dir.x != 0:
		input_dir.y = 0
		
	velocity = input_dir * speed
	move_and_slide()
	actualizar_animacion(input_dir)

func actualizar_animacion(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		# Reproduce el idle correspondiente a la última dirección
		anim.play("idle_" + last_dir)
		return
		
	if dir.x > 0:
		last_dir = "right"
		anim.play("walk_right")
	elif dir.x < 0:
		last_dir = "left"
		anim.play("walk_left")
	elif dir.y > 0:
		last_dir = "down"
		anim.play("walk_down")
	elif dir.y < 0:
		last_dir = "up"
		anim.play("walk_up")

func bloquear_movimiento(mirar_hacia: Vector2) -> void:
	can_move = false
	velocity = Vector2.ZERO
	
	var diff := mirar_hacia - global_position
	if abs(diff.x) > abs(diff.y):
		last_dir = "right" if diff.x > 0 else "left"
	else:
		last_dir = "down" if diff.y > 0 else "up"
		
	anim.play("idle_" + last_dir)
