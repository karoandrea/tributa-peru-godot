extends CanvasLayer

@onready var etiqueta = $Etiqueta
@onready var oscuro = $Oscuro
@onready var mensaje = $Mensaje
var id_mensaje = 0
var cambiando = false


func _ready():
	oscuro.modulate.a = 0.0

func fundir_a_negro(duracion = 0.6):
	var t = create_tween()
	t.tween_property(oscuro, "modulate:a", 1.0, duracion)
	await t.finished

func aclarar(duracion = 0.6):
	var t = create_tween()
	t.tween_property(oscuro, "modulate:a", 0.0, duracion)
	await t.finished

func cambiar_escena(ruta, duracion = 0.4, con_estadisticas = true):
	if cambiando:
		return
	cambiando = true
	await fundir_a_negro(duracion)
	get_tree().change_scene_to_file(ruta)
	etiqueta.visible = con_estadisticas
	await get_tree().process_frame
	await get_tree().process_frame
	await aclarar(duracion)
	cambiando = false

func _process(_delta):
	etiqueta.text = "Dinero: S/ %d\nDía: %d/%d   Mes: %d/%d\nStock: %d   Clientes hoy: %d/%d\nCobro a fin de mes: S/ %d" % [
		GameState.dinero,
		GameState.dia, GameState.DIAS_POR_MES,
		GameState.mes, GameState.MESES_PARA_GANAR,
		GameState.stock,
		GameState.ventas_hoy, GameState.CLIENTES_POR_DIA,
		GameState.cobro_mes
	]

func mostrar_mensaje(texto, duracion = 2.0):
	mensaje.text = texto
	id_mensaje += 1
	var mi_id = id_mensaje
	await get_tree().create_timer(duracion).timeout
	if mi_id == id_mensaje:
		mensaje.text = ""

func ocultar_mensaje():
	id_mensaje += 1
	mensaje.text = ""
