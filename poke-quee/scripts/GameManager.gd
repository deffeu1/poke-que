extends Node

# Guarda los nombres únicos de los enemigos derrotados
var defeated_enemies: Array[String] = []
var current_enemy_id: String = ""

# Guarda la última posición del jugador antes de entrar al combate
var last_player_position: Vector2 = Vector2.ZERO
var has_saved_position: bool = false
