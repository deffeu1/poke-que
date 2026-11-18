extends Area2D

func _ready() -> void:
	# Si esta poción ya fue agarrada antes, desaparece al cargar el mapa
	if GameManager.collected_potions.has(name):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.potions += 1
		GameManager.collected_potions.append(name)
		
		# Avisa al mundo que actualice el contador del HUD al instante
		get_tree().call_group("world_hud", "actualizar_hud")
		queue_free()
