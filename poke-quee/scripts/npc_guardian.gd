extends StaticBody2D

@export var desplazamiento_al_abrir: Vector2 = Vector2(48, 0)

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
		dialogue_text.text = "El camino hacia la siguiente sala ya está abierto. ¡Tené cuidado!"
	elif GameManager.has_key:
		dialogue_text.text = "¡Conseguiste la llave! Te abro el paso a la siguiente habitación."
		GameManager.has_key = false
		GameManager.gate_unlocked = true
		apartarse()
	else:
		dialogue_text.text = "Alto ahí. No podés pasar sin la llave de la mazmorra."

func cerrar_dialogo() -> void:
	hablando = false
	dialogue_box.visible = false
	
	if player_ref and player_ref.has_method("set_physics_process"):
		player_ref.set_physics_process(true)
	if player_in_range:
		prompt_label.visible = true

func apartarse() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position", position + desplazamiento_al_abrir, 0.6)

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
