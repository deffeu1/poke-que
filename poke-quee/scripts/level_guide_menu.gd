extends CanvasLayer

var panel: PanelContainer
var visible_menu: bool = false

func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	construir_interfaz()
	panel.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("guia_nivel"):
		var escena := get_tree().current_scene
		if escena == null or escena.name == "MainMenu" or escena.name == "NameInput" or escena.name == "EndScreen":
			return
		alternar_menu()
		get_viewport().set_input_as_handled()
	elif visible_menu and event.is_action_pressed("ui_cancel"):
		alternar_menu()
		get_viewport().set_input_as_handled()

func alternar_menu() -> void:
	visible_menu = not visible_menu
	panel.visible = visible_menu
	get_tree().paused = visible_menu

func construir_interfaz() -> void:
	panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(760, 460)
	panel.offset_left = -380
	panel.offset_right = 380
	panel.offset_top = -230
	panel.offset_bottom = 230
	add_child(panel)
	
	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 24)
	margen.add_theme_constant_override("margin_right", 24)
	margen.add_theme_constant_override("margin_top", 20)
	margen.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margen)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margen.add_child(vbox)
	
	var titulo := Label.new()
	titulo.text = "GUÍA DE DISEÑO DE NIVEL — ESTRUCTURA DE HABITACIONES"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 18)
	vbox.add_child(titulo)
	
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	
	var texto := RichTextLabel.new()
	texto.bbcode_enabled = true
	texto.fit_content = true
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.text = obtener_texto_habitaciones()
	scroll.add_child(texto)
	
	var btn_cerrar := Button.new()
	btn_cerrar.text = "Cerrar Guía [I / Esc]"
	btn_cerrar.focus_mode = Control.FOCUS_NONE
	btn_cerrar.pressed.connect(alternar_menu)
	vbox.add_child(btn_cerrar)

func obtener_texto_habitaciones() -> String:
	return """[b]Habitación 1 — Inicio, Onboarding y Obtención de Llave[/b]
• [i]Función de diseño:[/i] Introducción segura a las mecánicas base (movimiento, recolección de pociones y combate por turnos contra enemigos comunes).
• [i]Narrativa ambiental:[/i] Se presenta visualmente la llave como objetivo inmediato para desbloquear la progresión hacia el interior de la mazmorra.

[b]Habitación 2 — Zona de Transición e Interacción con NPC[/b]
• [i]Función de diseño:[/i] Punto de control narrativo y puerta bloqueada (*gating*). Requiere entregar la llave al Guardián para habilitar el acceso y sumar un aliado.

[b]Habitación 3 — Emboscada, Derrota Programada y Búsqueda del Power-Up[/b]
• [i]Función de diseño:[/i] Giro dramático (muerte del compañero en cinemática) frente a un Jefe invencible en el primer encuentro. Funciona como circuito de retorno (*loop*): obliga al jugador a retroceder, explorar esta misma sala en busca del Altar de Poder y regresar fortalecido.

[b]Habitación 4 — Confrontación Final (Revancha)[/b]
• [i]Función de diseño:[/i] Validación de la progresión. El jugador demuestra su nuevo poder (los enemigos previos huyen al sentir su aura) y enfrenta al Jefe en igualdad de condiciones hasta derrotarlo.

[b]Habitación 5 — Cámara de Recompensa (Orbe Místico)[/b]
• [i]Función de diseño:[/i] Resolución y cierre de la experiencia mediante la obtención del objetivo principal tras superar el desafío mayor."""
