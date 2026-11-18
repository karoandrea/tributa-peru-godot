extends CanvasLayer

const PACK_PEQUENO = {"cantidad": 5, "costo": 25}
const PACK_GRANDE = {"cantidad": 10, "costo": 45}

@onready var info = $Panel/VBox/Info
@onready var mensaje = $Panel/VBox/Mensaje
@onready var btn_pequeno = $Panel/VBox/BtnPequeno
@onready var btn_grande = $Panel/VBox/BtnGrande
@onready var btn_cerrar = $Panel/VBox/BtnCerrar

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	btn_pequeno.text = "Comprar %d unidades (S/ %d)" % [PACK_PEQUENO.cantidad, PACK_PEQUENO.costo]
	btn_grande.text = "Comprar %d unidades (S/ %d)" % [PACK_GRANDE.cantidad, PACK_GRANDE.costo]

	btn_pequeno.pressed.connect(_comprar.bind(PACK_PEQUENO))
	btn_grande.pressed.connect(_comprar.bind(PACK_GRANDE))
	btn_cerrar.pressed.connect(_cerrar)
	_actualizar()

func _comprar(pack):
	if GameState.comprar(pack.cantidad, pack.costo):
		mensaje.text = "Compraste %d unidades" % pack.cantidad
	else:
		mensaje.text = "No te alcanza el dinero"
	_actualizar()

func _actualizar():
	info.text = "Dinero: S/ %d     Stock: %d" % [GameState.dinero, GameState.stock]

func _cerrar():
	get_tree().paused = false
	queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_cerrar()
