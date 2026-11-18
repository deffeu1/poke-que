extends Node2D

@onready var tilemap: TileMapLayer = $piso # Cambiá el nombre si tu nodo se llama distinto
@onready var camera: Camera2D = $"character body/Camera2D"

func _ready() -> void:
	ajustar_limites_camara()

func ajustar_limites_camara() -> void:
	# Obtiene el rectángulo ocupado por los tiles en celdas
	var map_rect: Rect2i = tilemap.get_used_rect()
	# Obtiene el tamaño de cada tile en píxeles (ej. 16x16 o 32x32)
	var tile_size: Vector2i = tilemap.tile_set.tile_size
	
	# Convierte celdas a píxeles y los asigna a la cámara
	camera.limit_left = map_rect.position.x * tile_size.x
	camera.limit_top = map_rect.position.y * tile_size.y
	camera.limit_right = map_rect.end.x * tile_size.x
	camera.limit_bottom = map_rect.end.y * tile_size.y
