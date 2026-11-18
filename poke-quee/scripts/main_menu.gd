extends Control

func _on_btn_jugar_pressed() -> void:
	GameManager.reset_game()
	SceneTransition.cambiar_escena("res://escenas/world.tscn")

func _on_btn_salir_pressed() -> void:
	get_tree().quit()
