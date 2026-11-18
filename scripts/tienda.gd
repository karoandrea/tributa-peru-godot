extends Node2D

func _ready():
	if GameState.tiene_spawn:
		$Player.global_position = GameState.spawn_pos
		GameState.tiene_spawn = false
