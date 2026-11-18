extends CanvasLayer

const BONO = 20

const PREGUNTAS = [
{"pregunta": "¿Qué entidad recauda los tributos del Gobierno Central en el Perú?", "opciones": ["La SUNAT", "El INDECOPI", "La SUNARP"]},
{"pregunta": "¿Quién cobra los arbitrios?", "opciones": ["La municipalidad", "La SUNAT", "El Ministerio de Salud"]},
{"pregunta": "¿Por qué servicios se pagan los arbitrios?", "opciones": ["Limpieza pública, parques y serenazgo", "Vuelos internacionales", "Estudios universitarios"]},
{"pregunta": "¿Qué debes entregar al cliente cuando le vendes un producto?", "opciones": ["Un comprobante de pago (boleta o factura)", "Una tarjeta de saludo", "Nada, si paga en efectivo"]},
{"pregunta": "¿Qué significa RUC?", "opciones": ["Registro Único de Contribuyentes", "Registro Universal de Comercio", "Régimen Único de Compras"]},
{"pregunta": "¿Cuál es la tasa total del IGV en el Perú (incluyendo el IPM)?", "opciones": ["18%", "10%", "25%"]},
{"pregunta": "¿Qué puede pasar si no entregas comprobante de pago?", "opciones": ["Multa e incluso cierre del local", "Nada, es opcional", "Te dan un premio"]},
{"pregunta": "¿Para qué sirven los impuestos que pagamos?", "opciones": ["Para financiar colegios, hospitales y carreteras", "Solo para pagar a los políticos", "Para nada en particular"]},
{"pregunta": "¿Cómo se llama no pagar impuestos de forma ilegal?", "opciones": ["Evasión tributaria", "Donación", "Ahorro empresarial"]},
]

@onready var pregunta_label = $Panel/VBox/Pregunta
@onready var botones = [$Panel/VBox/Btn1, $Panel/VBox/Btn2, $Panel/VBox/Btn3]
@onready var resultado = $Panel/VBox/Resultado
@onready var btn_cerrar = $Panel/VBox/BtnCerrar

var correcta = ""

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	var p = PREGUNTAS.pick_random()
	correcta = p.opciones[0]
	var opciones = p.opciones.duplicate()
	opciones.shuffle()

	pregunta_label.text = p.pregunta
	for i in 3:
		botones[i].text = opciones[i]
		botones[i].pressed.connect(_responder.bind(opciones[i]))

	btn_cerrar.visible = false
	btn_cerrar.pressed.connect(_cerrar)

func _responder(elegida):
	for b in botones:
		b.disabled = true
	GameState.trivia_hecha_hoy = true
	if elegida == correcta:
		GameState.dinero += BONO
		resultado.text = "¡Correcto! Ganaste S/ %d de bono." % BONO
	else:
		resultado.text = "Incorrecto. La respuesta correcta era: " + correcta
	btn_cerrar.visible = true

func _cerrar():
	get_tree().paused = false
	queue_free()
