extends Area2D

var jugador_cerca = false
var durmiendo = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		jugador_cerca = true
		HUD.mostrar_mensaje("Presiona E para dormir", 60.0)

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		HUD.ocultar_mensaje()

func _unhandled_input(event):
	if jugador_cerca and not durmiendo and event.is_action_pressed("INTERACTUAR"):
		dormir()

func dormir():
	durmiendo = true
	HUD.ocultar_mensaje()
	await HUD.fundir_a_negro()
	var resultado = GameState.pasar_dia()

	if resultado == GameState.Resultado.GAME_OVER:
		durmiendo = false
		HUD.cambiar_escena("res://esenas/game_over.tscn", 0.4, false)
		return
	if resultado == GameState.Resultado.VICTORIA:
		durmiendo = false
		HUD.cambiar_escena("res://esenas/victoria.tscn", 0.4, false)
		return

	await HUD.aclarar()
	durmiendo = false

	if resultado == GameState.Resultado.COBRO:
		HUD.mostrar_mensaje("La SUNAT cobró S/ %d. Empieza el mes %d" % [GameState.cobro_mes, GameState.mes], 4.0)
	else:
		HUD.mostrar_mensaje("Día %d" % GameState.dia)
