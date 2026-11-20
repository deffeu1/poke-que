extends CanvasLayer

@onready var panel: PanelContainer = $Panel
@onready var btn_vida: Button = $Panel/VBoxContainer/BtnUsarVida
@onready var btn_mana: Button = $Panel/VBoxContainer/BtnUsarMana
@onready var llave_label: Label = $Panel/VBoxContainer/LlaveLabel

func _ready() -> void:
	panel.visible = false
	btn_vida.focus_mode = Control.FOCUS_NONE
	btn_mana.focus_mode = Control.FOCUS_NONE

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventario"):
		var escena := get_tree().current_scene
		if escena == null or escena.name == "BattleScene" or escena.name == "MainMenu" or escena.name == "EndScreen":
			return
		panel.visible = not panel.visible
		if panel.visible:
			actualizar_ui()
		get_viewport().set_input_as_handled()

func actualizar_ui() -> void:
	btn_vida.text = "Poción de Vida (" + str(GameManager.potions) + ") - PS: " + str(GameManager.player_hp) + "/" + str(GameManager.player_max_hp)
	btn_vida.disabled = GameManager.potions <= 0 or GameManager.player_hp >= GameManager.player_max_hp
	
	btn_mana.text = "Poción de Maná (" + str(GameManager.mana_potions) + ") - PM: " + str(GameManager.player_mana) + "/" + str(GameManager.player_max_mana)
	btn_mana.disabled = GameManager.mana_potions <= 0 or GameManager.player_mana >= GameManager.player_max_mana
	
	if GameManager.has_key:
		llave_label.text = "Objetos clave: Llave de la mazmorra"
	else:
		llave_label.text = "Objetos clave: Ninguno"

func _on_btn_usar_vida_pressed() -> void:
	if GameManager.potions > 0 and GameManager.player_hp < GameManager.player_max_hp:
		GameManager.potions -= 1
		GameManager.player_hp = min(GameManager.player_max_hp, GameManager.player_hp + 35)
		GameManager.stats_changed.emit()
		actualizar_ui()

func _on_btn_usar_mana_pressed() -> void:
	if GameManager.mana_potions > 0 and GameManager.player_mana < GameManager.player_max_mana:
		GameManager.mana_potions -= 1
		GameManager.player_mana = min(GameManager.player_max_mana, GameManager.player_mana + 30)
		GameManager.stats_changed.emit()
		actualizar_ui()
