extends Node2D

const MENU = preload("res://esenas/MenuTrivia.tscn")

@export var id_npc = 0
@export var frames: SpriteFrames                      
@export_enum("Abajo", "Arriba", "Izquierda", "Derecha") var direccion = "Abajo"
@export var quieto = true                             
@export var espejar = false                           

var jugador_cerca = false

@onready var area = $Area2D
@onready var sprite = $Area2D/AnimatedSprite2D
@onready var marca = $Marca

func _ready():
	if frames:
		sprite.sprite_frames = frames
	sprite.flip_h = espejar
	_mirar(direccion)

	marca.play("Exclamation")

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _mirar(nombre: String):
	var sf = sprite.sprite_frames
	if sf == null:
		return
	if not sf.has_animation(nombre):
		var lista = sf.get_animation_names()
		if lista.is_empty():
			return
		nombre = lista[0]
	sprite.animation = nombre
	sprite.frame = 0
	if quieto:
		sprite.stop()
	else:
		sprite.play(nombre)

func _process(_delta):
	marca.visible = _esta_disponible()

func _esta_disponible() -> bool:
	return GameState.npc_trivia_activo() == id_npc and not GameState.trivia_hecha_hoy

func _on_body_entered(body):
	if body.name == "Player":
		jugador_cerca = true
		if _esta_disponible():
			HUD.mostrar_mensaje("Presiona E para hablar", 60.0)

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		HUD.ocultar_mensaje()

func _unhandled_input(event):
	if not jugador_cerca or not event.is_action_pressed("INTERACTUAR"):
		return
	if _esta_disponible():
		HUD.ocultar_mensaje()
		get_tree().current_scene.add_child(MENU.instantiate())
	elif GameState.npc_trivia_activo() == id_npc:
		HUD.mostrar_mensaje("Ya completaste la trivia de hoy. ¡Vuelve mañana!")
	else:
		HUD.mostrar_mensaje("Hoy no tengo trivia para ti. Otro vecino te espera.")
