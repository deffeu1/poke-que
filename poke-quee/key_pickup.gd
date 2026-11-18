extends Area2D

func _ready() -> void:
	if GameManager.has_key or GameManager.gate_unlocked:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.has_key = true
		queue_free()
