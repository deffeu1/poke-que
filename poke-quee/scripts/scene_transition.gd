extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

func _ready() -> void:
	fade_rect.color = Color(0, 0, 0, 0)

func cambiar_escena(ruta: String) -> void:
	var tween := create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 0.35)
	await tween.finished
	
	get_tree().change_scene_to_file(ruta)
	
	var tween_in := create_tween()
	tween_in.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.35)

func transicion_combate(ruta: String) -> void:
	var tween := create_tween()
	tween.tween_property(fade_rect, "color", Color(1, 1, 1, 0.85), 0.08)
	tween.tween_property(fade_rect, "color", Color(1, 1, 1, 0.0), 0.08)
	tween.tween_property(fade_rect, "color", Color(1, 1, 1, 0.85), 0.08)
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1.0), 0.3)
	await tween.finished
	
	get_tree().change_scene_to_file(ruta)
	
	var tween_in := create_tween()
	tween_in.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.35)
