extends Node

signal stats_changed

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
var potions: int = 1 
var has_key: bool = false
var gate_unlocked: bool = false
var talked_to_guardian: bool = false
var player_max_mana: int = 50
var player_mana: int = 50
var mana_potions: int = 1
var collected_mana_potions: Array[String] = []
var guardian_following: bool = false
var guardian_dead: bool = false
var saved_player_position: Vector2 = Vector2.ZERO
var boss_first_encounter_done: bool = false
var player_has_powerup: bool = false
var show_revenge_dialogue: bool = false


func reset_game() -> void:
	player_hp = player_max_hp
	player_mana = player_max_mana
	potions = 1
	mana_potions = 1
	defeated_enemies.clear()
	collected_potions.clear()
	collected_mana_potions.clear()
	has_saved_position = false
	is_boss_battle = false
	boss_first_encounter_done = false
	show_revenge_dialogue = false
	player_has_powerup = false
	game_won = false
	has_key = false
	gate_unlocked = false
	talked_to_guardian = false
	guardian_following = false
	guardian_dead = false
