extends Area2D

const MENU = preload("res://esenas/menu_compra.tscn")
var jugador_cerca = false

@onready var sprite = $AnimatedSprite2D
@onready var cofre = $AnimatedSprite2D2

func _ready():
	sprite.play("Idle")
	cofre.play("cofre")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		jugador_cerca = true
		HUD.mostrar_mensaje("Presiona E para hablar con el proveedor", 60.0)

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		HUD.ocultar_mensaje()

func _unhandled_input(event):
	if jugador_cerca and event.is_action_pressed("INTERACTUAR"):
		HUD.ocultar_mensaje()
		get_tree().current_scene.add_child(MENU.instantiate())
