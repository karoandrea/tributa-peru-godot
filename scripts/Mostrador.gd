extends Area2D

@export var precio = 15
var jugador_cerca = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		jugador_cerca = true
		HUD.mostrar_mensaje("Presiona E para vender", 60.0)

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		HUD.ocultar_mensaje()

func _unhandled_input(event):
	if jugador_cerca and event.is_action_pressed("INTERACTUAR"):
		if GameState.stock <= 0:
			HUD.mostrar_mensaje("No tienes stock")
		elif GameState.ventas_hoy >= GameState.CLIENTES_POR_DIA:
			HUD.mostrar_mensaje("Ya no hay más clientes hoy. Ve a dormir")
		elif GameState.vender(precio):
			HUD.mostrar_mensaje("Boleta emitida: +S/ %d" % precio)
