extends Control

enum State { START, PLAYER_TURN, ENEMY_TURN, BUSY, WIN, LOSE }
var state: State = State.START

var enemy_max_hp: int = 60
var enemy_hp: int = 60

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var enemy_sprite: AnimatedSprite2D = $EnemySprite
@onready var player_hp_bar: ProgressBar = $PlayerHUD/PlayerHP
@onready var enemy_hp_bar: ProgressBar = $EnemyHUD/EnemyHP
@onready var dialog_label: Label = $DialogPanel/DialogLabel
@onready var action_menu: HBoxContainer = $ActionMenu
@onready var attacks_menu: GridContainer = $AttacksMenu
@onready var btn_curar: Button = $AttacksMenu/BtnMove3

func _ready() -> void:
	# Desactiva bucles en las animaciones de ataque si existen
	if player_sprite.sprite_frames.has_animation("attack"):
		player_sprite.sprite_frames.set_animation_loop("attack", false)
	if enemy_sprite.sprite_frames.has_animation("attack"):
		enemy_sprite.sprite_frames.set_animation_loop("attack", false)
		
	# Inicia las poses en reposo con tus nombres exactos
	if player_sprite.sprite_frames.has_animation("player"):
		player_sprite.play("player")
	if enemy_sprite.sprite_frames.has_animation("gengibre"):
		enemy_sprite.play("gengibre")
		
	player_hp_bar.max_value = GameManager.player_max_hp
	player_hp_bar.value = GameManager.player_hp
	enemy_hp_bar.max_value = enemy_max_hp
	enemy_hp_bar.value = enemy_hp
	
	ocultar_menus()
	dialog_label.text = "¡Un Hombre de Jengibre salvaje te desafía!"
	await get_tree().create_timer(1.5).timeout
	turno_jugador()

func ocultar_menus() -> void:
	action_menu.visible = false
	attacks_menu.visible = false

func turno_jugador() -> void:
	state = State.PLAYER_TURN
	dialog_label.text = "¿Qué vas a hacer?"
	action_menu.visible = true
	attacks_menu.visible = false

func _on_btn_atacar_pressed() -> void:
	if state != State.PLAYER_TURN:
		return
	action_menu.visible = false
	attacks_menu.visible = true
	
	btn_curar.text = "Poción (" + str(GameManager.potions) + ")"
	btn_curar.disabled = (GameManager.potions <= 0 or GameManager.player_hp >= GameManager.player_max_hp)
	dialog_label.text = "Elegí un movimiento:"

func _on_btn_huir_pressed() -> void:
	if state != State.PLAYER_TURN:
		return
	state = State.BUSY
	ocultar_menus()
	GameManager.has_saved_position = false
	dialog_label.text = "¡Escapaste con éxito!"
	await get_tree().create_timer(1.0).timeout
	volver_al_mapa()

func _on_btn_volver_pressed() -> void:
	if state != State.PLAYER_TURN:
		return
	attacks_menu.visible = false
	action_menu.visible = true
	dialog_label.text = "¿Qué vas a hacer?"

func _on_btn_move_1_pressed() -> void:
	ejecutar_movimiento("Golpe Rápido", 12, 16, false)

func _on_btn_move_2_pressed() -> void:
	ejecutar_movimiento("Bola de Fuego", 18, 30, false)

func _on_btn_move_3_pressed() -> void:
	ejecutar_movimiento("Poción", 25, 25, true)

func ejecutar_movimiento(nombre: String, valor_min: int, valor_max: int, es_cura: bool) -> void:
	if state != State.PLAYER_TURN:
		return
		
	if es_cura:
		if GameManager.potions <= 0 or GameManager.player_hp >= GameManager.player_max_hp:
			return
			
	state = State.BUSY
	ocultar_menus()
	
	var cantidad := randi_range(valor_min, valor_max)
	
	if es_cura:
		GameManager.potions -= 1
		GameManager.player_hp = min(GameManager.player_max_hp, GameManager.player_hp + cantidad)
		player_hp_bar.value = GameManager.player_hp
		dialog_label.text = "¡Usaste una Poción y recuperaste " + str(cantidad) + " PS!"
		
		var tween := create_tween()
		tween.tween_property(player_sprite, "modulate", Color(0.4, 1, 0.4), 0.15)
		tween.tween_property(player_sprite, "modulate", Color.WHITE, 0.15)
	else:
		print("1. Jugador va a atacar...")
		if player_sprite.sprite_frames.has_animation("attack"):
			player_sprite.play("attack")
			await player_sprite.animation_finished
			player_sprite.play("player")
			
		print("2. Aplicando daño al enemigo...")
		animar_impacto(enemy_sprite)
		enemy_hp = max(0, enemy_hp - cantidad)
		enemy_hp_bar.value = enemy_hp
		dialog_label.text = "¡Usaste " + nombre + " e hiciste " + str(cantidad) + " de daño!"
		
	await get_tree().create_timer(1.3).timeout
	
	if enemy_hp <= 0:
		ganar_combate()
	else:
		print("3. Pasando al turno del enemigo...")
		turno_enemigo()

func turno_enemigo() -> void:
	state = State.ENEMY_TURN
	print("4. Enemigo atacando...")
	
	if enemy_sprite.sprite_frames.has_animation("attack"):
		enemy_sprite.play("attack")
		await enemy_sprite.animation_finished
		enemy_sprite.play("gengibre")
		
	animar_impacto(player_sprite)
	var danio := randi_range(10, 18)
	GameManager.player_hp = max(0, GameManager.player_hp - danio)
	player_hp_bar.value = GameManager.player_hp
	dialog_label.text = "¡El enemigo ataca y te saca " + str(danio) + " PS!"
	
	await get_tree().create_timer(1.2).timeout
	
	if GameManager.player_hp <= 0:
		state = State.LOSE
		dialog_label.text = "Te quedaste sin energía..."
		await get_tree().create_timer(1.5).timeout
		GameManager.game_won = false
		SceneTransition.cambiar_escena("res://escenas/EndScreen.tscn")
	else:
		turno_jugador()

func animar_impacto(sprite: AnimatedSprite2D) -> void:
	var pos_original := sprite.position
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0.25, 0.25), 0.06)
	tween.parallel().tween_property(sprite, "position:x", pos_original.x - 10, 0.05)
	tween.tween_property(sprite, "position:x", pos_original.x + 10, 0.05)
	tween.tween_property(sprite, "position:x", pos_original.x - 6, 0.05)
	tween.tween_property(sprite, "position:x", pos_original.x, 0.05)
	tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.08)

func ganar_combate() -> void:
	state = State.WIN
	if GameManager.current_enemy_id != "":
		GameManager.defeated_enemies.append(GameManager.current_enemy_id)
		
	dialog_label.text = "¡Ganaste el combate!"
	
	var tween := create_tween()
	tween.tween_property(enemy_sprite, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(enemy_sprite, "position:y", enemy_sprite.position.y + 15, 0.5)
	await tween.finished
	
	await get_tree().create_timer(0.8).timeout
	
	if GameManager.is_boss_battle:
		GameManager.game_won = true
		SceneTransition.cambiar_escena("res://escenas/EndScreen.tscn")
	else:
		volver_al_mapa()

func volver_al_mapa() -> void:
	SceneTransition.cambiar_escena("res://escenas/world.tscn")
