extends Node


var game_won: bool = false
var current_enemy_name: String = "Hombre de Jengibre"
var current_enemy_max_hp: int = 60
var current_enemy_min_dmg: int = 10
var current_enemy_max_dmg: int = 18
var current_enemy_frames: SpriteFrames = null
var is_boss_battle: bool = false
var defeated_enemies: Array[String] = []
var collected_potions: Array[String] = [] # Guarda las pociones ya agarradas
var current_enemy_id: String = ""
var last_player_position: Vector2 = Vector2.ZERO
var has_saved_position: bool = false
var player_max_hp: int = 100
var player_hp: int = 100
var potions: int = 1 # Cantidad inicial de pociones (poné 0 si querés arrancar sin nada)
var has_key: bool = false
var gate_unlocked: bool = false


func reset_game() -> void:
	player_hp = player_max_hp
	potions = 1
	defeated_enemies.clear()
	collected_potions.clear()
	has_saved_position = false
	is_boss_battle = false
	game_won = false
	has_key = false
	gate_unlocked = false
