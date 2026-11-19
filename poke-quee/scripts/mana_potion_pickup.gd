extends Area2D

func _ready() -> void:
	if name in GameManager.collected_mana_potions:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.mana_potions += 1
		GameManager.collected_mana_potions.append(name)
		queue_free()
