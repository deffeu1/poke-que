extends Area2D

@export var sonido_pocion: AudioStream
@export var volumen_db: float = -10.0 # <--- Ajustá este número desde el Inspector

func _ready() -> void:
	if name in GameManager.collected_mana_potions:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.mana_potions += 1
		GameManager.collected_mana_potions.append(name)
		
		if sonido_pocion != null:
			var audio := AudioStreamPlayer.new()
			audio.stream = sonido_pocion
			audio.volume_db = volumen_db # <--- Aplica el volumen elegido
			get_tree().current_scene.add_child(audio)
			audio.play()
			audio.finished.connect(audio.queue_free)
			
		queue_free()
