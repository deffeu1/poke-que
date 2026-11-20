extends Area2D

@export var sonido_pocion: AudioStream
@export var volumen_db: float = -10.0 # <--- Ajustá este número desde el Inspector (más negativo = más bajo)

func _ready() -> void:
	if GameManager.collected_potions.has(name):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.potions += 1
		GameManager.collected_potions.append(name)
		
		if sonido_pocion != null:
			var audio := AudioStreamPlayer.new()
			audio.stream = sonido_pocion
			audio.volume_db = volumen_db # <--- Aplica el volumen elegido
			get_tree().current_scene.add_child(audio)
			audio.play()
			audio.finished.connect(audio.queue_free)
		
		get_tree().call_group("world_hud", "actualizar_hud")
		queue_free()
