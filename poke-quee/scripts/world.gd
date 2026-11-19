extends Node2D

@onready var tilemap: TileMapLayer = $piso
@onready var camera: Camera2D = $"character body/Camera2D"
@onready var hp_bar: ProgressBar = $HUD/PanelContainer/VBoxContainer/PlayerHP
@onready var potions_label: Label = $HUD/PanelContainer/VBoxContainer/PotionsLabel
@onready var player_mana_bar: ProgressBar = $HUD/PanelContainer/VBoxContainer/PlayerMana

func _ready() -> void:
	ajustar_limites_camara()
	actualizar_hud()
	if not GameManager.stats_changed.is_connected(actualizar_hud):
		GameManager.stats_changed.connect(actualizar_hud)

func ajustar_limites_camara() -> void:
	var map_rect: Rect2i = tilemap.get_used_rect()
	var tile_size: Vector2i = tilemap.tile_set.tile_size
	
	camera.limit_left = map_rect.position.x * tile_size.x
	camera.limit_top = map_rect.position.y * tile_size.y
	camera.limit_right = map_rect.end.x * tile_size.x
	camera.limit_bottom = map_rect.end.y * tile_size.y

func actualizar_hud() -> void:
	hp_bar.max_value = GameManager.player_max_hp
	hp_bar.value = GameManager.player_hp
	player_mana_bar.max_value = GameManager.player_max_mana
	player_mana_bar.value = GameManager.player_mana
	potions_label.text = "Pociones: " + str(GameManager.potions)
