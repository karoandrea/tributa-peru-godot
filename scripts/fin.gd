extends Control

func _ready():
	$Motivo.text = GameState.motivo_fin
	$Boton.pressed.connect(_on_boton_pressed)

func _on_boton_pressed():
	GameState.reiniciar()
	HUD.cambiar_escena("res://esenas/mundo.tscn")
