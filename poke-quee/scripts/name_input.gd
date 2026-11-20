extends Control

@onready var name_input: LineEdit = $VBoxContainer/NameLineEdit

func _ready() -> void:
	name_input.grab_focus()

func confirmar_nombre() -> void:
	var texto_limpio := name_input.text.strip_edges()
	if texto_limpio == "":
		GameManager.player_name = "Héroe"
	else:
		GameManager.player_name = texto_limpio
	SceneTransition.cambiar_escena("res://escenas/world.tscn")

func _on_confirm_button_pressed() -> void:
	confirmar_nombre()

func _on_name_line_edit_text_submitted(_new_text: String) -> void:
	confirmar_nombre()
