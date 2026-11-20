extends Node2D

@onready var tilemap: TileMapLayer = $piso
@onready var camera: Camera2D = $"character body/Camera2D"
@onready var player: CharacterBody2D = $"character body"
@onready var hp_bar: ProgressBar = $HUD/PanelContainer/VBoxContainer/PlayerHP
@onready var potions_label: Label = $HUD/PanelContainer/VBoxContainer/PotionsLabel
@onready var player_mana_bar: ProgressBar = $HUD/PanelContainer/VBoxContainer/PlayerMana
@onready var hud: CanvasLayer = $HUD

var dialogo_venganza_activo: bool = false
var capa_dialogo: CanvasLayer = null
var texto_dialogo: Label = null
var indice_linea: int = 0
var lineas_venganza: Array[String] = [
	"Maldición... Ni siquiera pude rasguñarlo. Y por mi culpa...",
	"No voy a dejar que su sacrificio sea en vano. Voy a encontrar el poder para derrotarlo y vengar al guardián."
]
var aura_creada: bool = false

func _ready() -> void:
	ajustar_limites_camara()
	actualizar_hud()
	if not GameManager.stats_changed.is_connected(actualizar_hud):
		GameManager.stats_changed.connect(actualizar_hud)
		
	if GameManager.show_revenge_dialogue:
		GameManager.show_revenge_dialogue = false
		iniciar_dialogo_venganza()
	if hud != null:
		hud.visible = true

func _process(_delta: float) -> void:
	if dialogo_venganza_activo:
		if Input.is_action_just_pressed("interactuar") or Input.is_action_just_pressed("ui_accept"):
			avanzar_dialogo_venganza()

func iniciar_dialogo_venganza() -> void:
	dialogo_venganza_activo = true
	indice_linea = 0
	if player != null:
		player.set_physics_process(false)
		
	capa_dialogo = CanvasLayer.new()
	capa_dialogo.layer = 25
	add_child(capa_dialogo)
	
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_left = 80
	panel.offset_right = -80
	panel.offset_top = -140
	panel.offset_bottom = -24
	capa_dialogo.add_child(panel)
	
	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 20)
	margen.add_theme_constant_override("margin_right", 20)
	margen.add_theme_constant_override("margin_top", 16)
	margen.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margen)
	
	texto_dialogo = Label.new()
	texto_dialogo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto_dialogo.text = lineas_venganza[0]
	margen.add_child(texto_dialogo)

func avanzar_dialogo_venganza() -> void:
	indice_linea += 1
	if indice_linea < lineas_venganza.size():
		texto_dialogo.text = lineas_venganza[indice_linea]
	else:
		dialogo_venganza_activo = false
		if capa_dialogo != null:
			capa_dialogo.queue_free()
		if player != null:
			player.set_physics_process(true)

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
	potions_label.text = "Pociones Vida: " + str(GameManager.potions) + " | Maná: " + str(GameManager.mana_potions)
	actualizar_aura_powerup()

func actualizar_aura_powerup() -> void:
	if not GameManager.player_has_powerup or aura_creada or player == null:
		return
	aura_creada = true
	
	var particulas := CPUParticles2D.new()
	particulas.name = "PowerUpAura"
	particulas.amount = 18
	particulas.lifetime = 0.85
	particulas.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particulas.emission_sphere_radius = 12.0
	particulas.gravity = Vector2(0, -28)
	particulas.initial_velocity_min = 4.0
	particulas.initial_velocity_max = 12.0
	particulas.scale_amount_min = 1.5
	particulas.scale_amount_max = 3.0
	particulas.color = Color(1.0, 0.88, 0.25, 0.9)
	particulas.z_index = -1
	player.add_child(particulas)
	
	var player_sprite := player.find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D
	if player_sprite != null:
		var tween := player.create_tween().set_loops()
		tween.tween_property(player_sprite, "modulate", Color(1.55, 1.4, 0.8), 0.75).set_trans(Tween.TRANS_SINE)
		tween.tween_property(player_sprite, "modulate", Color.WHITE, 0.75).set_trans(Tween.TRANS_SINE)
