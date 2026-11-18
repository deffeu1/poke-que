extends Control

@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var sub_label: Label = $CenterContainer/VBoxContainer/SubLabel

func _ready() -> void:
	if GameManager.game_won:
		title_label.text = "¡VICTORIA!"
		sub_label.text = "Derrotaste al jefe y completaste la mazmorra."
	else:
		title_label.text = "FIN DEL JUEGO"
		sub_label.text = "Te quedaste sin energía en el camino."

func _on_btn_reintentar_pressed() -> void:
	GameManager.reset_game()
	SceneTransition.cambiar_escena("res://escenas/world.tscn")

func _on_btn_menu_pressed() -> void:
	GameManager.reset_game()
	SceneTransition.cambiar_escena("res://escenas/MainMenu.tscn")
