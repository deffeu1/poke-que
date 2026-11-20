extends Control

enum State { START, PLAYER_TURN, ENEMY_TURN, BUSY, WIN, LOSE }
var state: State = State.START
const COSTO_BOLA_FUEGO: int = 20
var enemy_max_hp: int = 60
var enemy_hp: int = 60

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var enemy_sprite: AnimatedSprite2D = $EnemySprite
@onready var enemy_name_label: Label = $EnemyHUD/EnemyName
@onready var player_hp_bar: ProgressBar = $PlayerHUD/PlayerHP
@onready var player_mana_bar: ProgressBar = $PlayerHUD/PlayerMana
@onready var enemy_hp_bar: ProgressBar = $EnemyHUD/EnemyHP
@onready var dialog_label: Label = $BottomBar/HBoxContainer/DialogPanel/DialogLabel
@onready var action_menu: HBoxContainer = $BottomBar/HBoxContainer/MenuPanel/ActionMenu
@onready var attacks_menu: GridContainer = $BottomBar/HBoxContainer/MenuPanel/AttacksMenu
@onready var btn_bola_fuego: Button = $BottomBar/HBoxContainer/MenuPanel/AttacksMenu/BtnMove2
@onready var btn_curar: Button = $BottomBar/HBoxContainer/MenuPanel/AttacksMenu/BtnMove3
@onready var btn_mana: Button = $BottomBar/HBoxContainer/MenuPanel/AttacksMenu/BtnMana
@onready var enemy_hud: Control = $EnemyHUD

# --- NODOS DE AUDIO ---
@onready var musica_batalla: AudioStreamPlayer = $MusicaBatalla
@onready var audio_fight: AudioStreamPlayer = $AudioFight
@onready var audio_golpe_normal: AudioStreamPlayer = $AudioGolpeNormal
@onready var audio_golpe_espada: AudioStreamPlayer = $AudioGolpeEspada
@onready var audio_ataque_enemigo: AudioStreamPlayer = $AudioAtaqueEnemigo
@onready var audio_muerte_enemigo: AudioStreamPlayer = $AudioMuerteEnemigo
@onready var audio_muerte_jugador: AudioStreamPlayer = $AudioMuerteJugador

func _ready() -> void:
	enemy_name_label.text = GameManager.current_enemy_name
	enemy_max_hp = GameManager.current_enemy_max_hp
	enemy_hp = enemy_max_hp
	
	if GameManager.is_boss_battle and GameManager.current_enemy_frames != null:
		enemy_sprite.sprite_frames = GameManager.current_enemy_frames
		
	if player_sprite.sprite_frames.has_animation("attack"):
		player_sprite.sprite_frames.set_animation_loop("attack", false)
	if enemy_sprite.sprite_frames.has_animation("attack"):
		enemy_sprite.sprite_frames.set_animation_loop("attack", false)
		
	if player_sprite.sprite_frames.has_animation("player"):
		player_sprite.play("player")
	if GameManager.player_has_powerup:
		var aura := CPUParticles2D.new()
		aura.amount = 22
		aura.lifetime = 0.9
		aura.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
		aura.emission_sphere_radius = 16.0
		aura.gravity = Vector2(0, -32)
		aura.scale_amount_min = 2.0
		aura.scale_amount_max = 4.0
		aura.color = Color(1.0, 0.88, 0.25, 0.9)
		aura.z_index = -1
		player_sprite.add_child(aura)
		
		var tween_aura := create_tween().set_loops()
		tween_aura.tween_property(player_sprite, "modulate", Color(1.55, 1.4, 0.8), 0.75)
		tween_aura.tween_property(player_sprite, "modulate", Color.WHITE, 0.75)
	if enemy_sprite.sprite_frames.has_animation("gengibre"):
		enemy_sprite.play("gengibre")
	elif enemy_sprite.sprite_frames.get_animation_names().size() > 0:
		enemy_sprite.play(enemy_sprite.sprite_frames.get_animation_names()[0])
		
	if GameManager.is_boss_battle:
		enemy_sprite.scale = Vector2(7.0, 7.0)
		enemy_hud.position += Vector2(70.0, -20.0)
	else:
		enemy_sprite.scale = Vector2(4.0, 4.0)
		
	player_hp_bar.max_value = GameManager.player_max_hp
	player_hp_bar.value = GameManager.player_hp
	player_mana_bar.max_value = GameManager.player_max_mana
	player_mana_bar.value = GameManager.player_mana
	enemy_hp_bar.max_value = enemy_max_hp
	enemy_hp_bar.value = enemy_hp
	
	ocultar_menus()
	audio_fight.play()
	dialog_label.text = "¡" + GameManager.current_enemy_name + " te desafía!"
	await get_tree().create_timer(1.5).timeout
	turno_jugador()

func ocultar_menus() -> void:
	action_menu.visible = false
	attacks_menu.visible = false

func turno_jugador() -> void:
	state = State.PLAYER_TURN
	dialog_label.text = "¿Qué va a hacer " + GameManager.player_name + "?"
	action_menu.visible = true
	attacks_menu.visible = false

func _on_btn_atacar_pressed() -> void:
	if state != State.PLAYER_TURN:
		return
	action_menu.visible = false
	attacks_menu.visible = true
	
	btn_bola_fuego.text = "Bola de Fuego (" + str(COSTO_BOLA_FUEGO) + " PM)"
	btn_bola_fuego.disabled = GameManager.player_mana < COSTO_BOLA_FUEGO
	
	btn_curar.text = "Poción Vida (" + str(GameManager.potions) + ")"
	btn_curar.disabled = GameManager.potions <= 0 or GameManager.player_hp >= GameManager.player_max_hp
	
	btn_mana.text = "Poción Maná (" + str(GameManager.mana_potions) + ")"
	btn_mana.disabled = GameManager.mana_potions <= 0 or GameManager.player_mana >= GameManager.player_max_mana
	
	dialog_label.text = "Elegí un movimiento:"

func _on_btn_huir_pressed() -> void:
	if state != State.PLAYER_TURN:
		return
	if GameManager.is_boss_battle:
		dialog_label.text = "¡No podés huir de un Jefe!"
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
	if state != State.PLAYER_TURN or GameManager.player_mana < COSTO_BOLA_FUEGO:
		return
	GameManager.player_mana -= COSTO_BOLA_FUEGO
	player_mana_bar.value = GameManager.player_mana
	ejecutar_movimiento("Bola de Fuego", 25, 36, false)

func _on_btn_move_3_pressed() -> void:
	ejecutar_movimiento("Poción de Vida", 25, 25, true)

func _on_btn_mana_pressed() -> void:
	if state != State.PLAYER_TURN or GameManager.mana_potions <= 0 or GameManager.player_mana >= GameManager.player_max_mana:
		return
	state = State.BUSY
	ocultar_menus()
	
	GameManager.mana_potions -= 1
	GameManager.player_mana = min(GameManager.player_max_mana, GameManager.player_mana + 30)
	player_mana_bar.value = GameManager.player_mana
	dialog_label.text = "¡Usaste una Poción de Maná y recuperaste 30 PM!"
	
	var tween := create_tween()
	tween.tween_property(player_sprite, "modulate", Color(0.4, 0.7, 1.0), 0.15)
	tween.tween_property(player_sprite, "modulate", Color.WHITE, 0.15)
	
	await get_tree().create_timer(1.3).timeout
	turno_enemigo()

func ejecutar_movimiento(nombre: String, valor_min: int, valor_max: int, es_cura: bool) -> void:
	if state != State.PLAYER_TURN:
		return
		
	if es_cura:
		if GameManager.potions <= 0 or GameManager.player_hp >= GameManager.player_max_hp:
			return
			
	state = State.BUSY
	ocultar_menus()
	
	var cantidad := randi_range(valor_min, valor_max)
	if not es_cura:
		if GameManager.is_boss_battle and not GameManager.player_has_powerup:
			cantidad = 1
		elif GameManager.player_has_powerup:
			cantidad = int(cantidad * 1.5)
	
	if es_cura:
		GameManager.potions -= 1
		GameManager.player_hp = min(GameManager.player_max_hp, GameManager.player_hp + cantidad)
		player_hp_bar.value = GameManager.player_hp
		dialog_label.text = "¡Usaste una Poción y recuperaste " + str(cantidad) + " PS!"
		
		var tween := create_tween()
		tween.tween_property(player_sprite, "modulate", Color(0.4, 1, 0.4), 0.15)
		tween.tween_property(player_sprite, "modulate", Color.WHITE, 0.15)
	else:
		if GameManager.player_has_powerup:
			audio_golpe_espada.play()
		else:
			audio_golpe_normal.play()
			
		if player_sprite.sprite_frames.has_animation("attack"):
			player_sprite.play("attack")
			await player_sprite.animation_finished
			player_sprite.play("player")
			
		animar_impacto(enemy_sprite)
		enemy_hp = max(0, enemy_hp - cantidad)
		enemy_hp_bar.value = enemy_hp
		dialog_label.text = "¡Usaste " + nombre + " e hiciste " + str(cantidad) + " de daño!"
		
	await get_tree().create_timer(1.3).timeout
	
	if enemy_hp <= 0:
		ganar_combate()
	else:
		turno_enemigo()

func turno_enemigo() -> void:
	state = State.ENEMY_TURN
	audio_ataque_enemigo.play()
	
	if enemy_sprite.sprite_frames.has_animation("attack"):
		enemy_sprite.play("attack")
		await enemy_sprite.animation_finished
		if enemy_sprite.sprite_frames.has_animation("gengibre"):
			enemy_sprite.play("gengibre")
		elif enemy_sprite.sprite_frames.get_animation_names().size() > 0:
			enemy_sprite.play(enemy_sprite.sprite_frames.get_animation_names()[0])
		
	var danio := randi_range(GameManager.current_enemy_min_dmg, GameManager.current_enemy_max_dmg)
	var mensaje_ataque := "¡" + GameManager.current_enemy_name + " ataca y te saca " + str(danio) + " PS!"
	
	if GameManager.is_boss_battle and randf() < 0.35:
		danio = int(danio * 1.4)
		mensaje_ataque = "¡" + GameManager.current_enemy_name + " usa Golpe Devastador y te saca " + str(danio) + " PS!"
		
	animar_impacto(player_sprite)
	GameManager.player_hp = max(0, GameManager.player_hp - danio)
	player_hp_bar.value = GameManager.player_hp
	dialog_label.text = mensaje_ataque
	
	await get_tree().create_timer(1.2).timeout
	
	if GameManager.player_hp <= 0:
		state = State.LOSE
		audio_muerte_jugador.play()
		
		if GameManager.is_boss_battle and not GameManager.boss_first_encounter_done:
			GameManager.boss_first_encounter_done = true
			GameManager.show_revenge_dialogue = true
			GameManager.is_boss_battle = false
			GameManager.player_hp = 1
			dialog_label.text = "Su poder es abrumador... ¡Lograste arrastrarte fuera de la sala antes de caer!"
			await get_tree().create_timer(2.2).timeout
			SceneTransition.cambiar_escena("res://escenas/world.tscn")
		else:
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
	musica_batalla.stop()
	audio_muerte_enemigo.play()
	
	if GameManager.current_enemy_id != "":
		GameManager.defeated_enemies.append(GameManager.current_enemy_id)
		
	if GameManager.is_boss_battle:
		GameManager.is_boss_battle = false
		dialog_label.text = "¡Derrotaste al " + GameManager.current_enemy_name + "! El Orbe Místico ahora está libre."
	else:
		dialog_label.text = "¡Ganaste el combate!"
	
	var tween := create_tween()
	tween.tween_property(enemy_sprite, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(enemy_sprite, "position:y", enemy_sprite.position.y + 15, 0.5)
	await tween.finished
	
	await get_tree().create_timer(1.0).timeout
	volver_al_mapa()

func volver_al_mapa() -> void:
	SceneTransition.cambiar_escena("res://escenas/world.tscn")
