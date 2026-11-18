extends Area2D

@export var next_scene_path: String
@export var spawn_destino: Vector2

func _on_body_entered(body):
	if body.name == "Player":
		GameState.spawn_pos = spawn_destino
		GameState.tiene_spawn = true
		HUD.cambiar_escena(next_scene_path)
