extends Control

enum State { START, PLAYER_TURN, ENEMY_TURN, BUSY, WIN, LOSE }
var state: State = State.START

# Estadísticas básicas
var player_max_hp: int = 100
var player_hp: int = 100
var enemy_max_hp: int = 60
var enemy_hp: int = 60

@onready var player_hp_bar: ProgressBar = $PlayerHUD/PlayerHP
@onready var enemy_hp_bar: ProgressBar = $EnemyHUD/EnemyHP
@onready var dialog_label: Label = $DialogPanel/DialogLabel
@onready var action_menu: HBoxContainer = $ActionMenu

func _ready() -> void:
	# Configura las barras de vida
	player_hp_bar.max_value = player_max_hp
	player_hp_bar.value = player_hp
	enemy_hp_bar.max_value = enemy_max_hp
	enemy_hp_bar.value = enemy_hp
	
	action_menu.visible = false
	dialog_label.text = "¡Un Hombre de Jengibre salvaje te desafía!"
	await get_tree().create_timer(1.5).timeout
	turno_jugador()

func turno_jugador() -> void:
	state = State.PLAYER_TURN
	dialog_label.text = "¿Qué vas a hacer?"
	action_menu.visible = true

func _on_btn_atacar_pressed() -> void:
	if state != State.PLAYER_TURN:
		return
	state = State.BUSY
	action_menu.visible = false
	
	var danio := randi_range(15, 25)
	enemy_hp = max(0, enemy_hp - danio)
	enemy_hp_bar.value = enemy_hp
	dialog_label.text = "¡Atacaste e hiciste " + str(danio) + " de daño!"
	
	await get_tree().create_timer(1.2).timeout
	
	if enemy_hp <= 0:
		ganar_combate()
	else:
		turno_enemigo()

func _on_btn_curar_pressed() -> void:
	if state != State.PLAYER_TURN:
		return
	state = State.BUSY
	action_menu.visible = false
	
	var cura := 20
	player_hp = min(player_max_hp, player_hp + cura)
	player_hp_bar.value = player_hp
	dialog_label.text = "¡Te curaste " + str(cura) + " PS!"
	
	await get_tree().create_timer(1.2).timeout
	turno_enemigo()

func _on_btn_huir_pressed() -> void:
	if state != State.PLAYER_TURN:
		return
	state = State.BUSY
	action_menu.visible = false
	dialog_label.text = "¡Escapaste con éxito!"
	await get_tree().create_timer(1.0).timeout
	volver_al_mapa()

func turno_enemigo() -> void:
	state = State.ENEMY_TURN
	var danio := randi_range(10, 18)
	player_hp = max(0, player_hp - danio)
	player_hp_bar.value = player_hp
	dialog_label.text = "¡El enemigo ataca y te saca " + str(danio) + " PS!"
	
	await get_tree().create_timer(1.2).timeout
	
	if player_hp <= 0:
		state = State.LOSE
		dialog_label.text = "Te quedaste sin energía..."
		await get_tree().create_timer(1.5).timeout
		volver_al_mapa()
	else:
		turno_jugador()

func ganar_combate() -> void:
	state = State.WIN
	# Registra a este enemigo como derrotado
	if GameManager.current_enemy_id != "":
		GameManager.defeated_enemies.append(GameManager.current_enemy_id)
		
	dialog_label.text = "¡Ganaste el combate!"
	await get_tree().create_timer(1.5).timeout
	volver_al_mapa()

func volver_al_mapa() -> void:
	get_tree().change_scene_to_file("res://escenas/world.tscn")
