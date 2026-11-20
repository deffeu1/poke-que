extends Area2D
@export var sonido_llave: AudioStream # <--- Arrastrá SONIDO AGARRAR LA LLAVE en el Inspector
@export var volumen_db: float = -10.0

func _ready() -> void:
	if GameManager.has_key or GameManager.gate_unlocked:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.has_key = true
		
		# --- NUEVO: Reproduce el sonido en la escena principal antes de borrar la llave ---
		if sonido_llave != null:
			var audio := AudioStreamPlayer.new()
			audio.stream = sonido_llave
			audio.volume_db = volumen_db
			get_tree().current_scene.add_child(audio)
			audio.play()
			audio.finished.connect(audio.queue_free)
			
		queue_free()
