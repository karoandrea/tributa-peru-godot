
extends Node2D
## TRIBUTA PERÚ - NIVEL 2 / BODEGA COSTERA
## 1. Detectives de comprobantes.
## 2. Memoria tributaria.
## 3. Clasificación de comprobantes.

const ANCHO := 960.0
const ALTO := 540.0

const TINTA := Color("#183952")
const MAR := Color("#196888")
const CLARO := Color("#fff9ee")
const DORADO := Color("#fbd581")
const VERDE := Color("#18744e")
const ROJO := Color("#a44043")

var font: Font
var documentos: Array = []
var orden: Array = [3, 0, 5, 2, 1, 4]

var modo: String = "intro"
var indice: int = 0
var aciertos: int = 0
var tiempo: float = 60.0
var puntos: int = 0

var mensaje: String = ""
var mensaje_color: Color = VERDE

# Memoria tributaria
var cartas: Array = []
var abiertas: Array = []
var emparejadas: Array = []
var timer_voltear: float = 0.0

# Clasificación
var clasificados: Dictionary = {}
var orden_clasificacion: Array = []
var arrastrando: int = -1
var mouse_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	font = ThemeDB.fallback_font

	var ruta := "res://data/comprobantes_tarea2.json"

	if FileAccess.file_exists(ruta):
		var datos = JSON.parse_string(FileAccess.get_file_as_string(ruta))
		if datos is Array:
			documentos = datos

	if documentos.size() != 6:
		push_warning("Se necesitan exactamente 6 comprobantes en comprobantes_tarea2.json")

	queue_redraw()


func _process(delta: float) -> void:

	if modo == "detectives":
		tiempo -= delta

		if tiempo <= 0.0:
			tiempo = 0.0
			modo = "sin_tiempo"

	if timer_voltear > 0.0:
		timer_voltear -= delta

		if timer_voltear <= 0.0:
			abiertas.clear()

	queue_redraw()


# =========================================================
# CONTROLES
# =========================================================

func _input(event: InputEvent) -> void:

	if event is InputEventMouseMotion:
		mouse_pos = event.position
		queue_redraw()
		return

	if event is InputEventMouseButton:

		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		mouse_pos = event.position

		if event.pressed:

			if modo == "detectives":

				if Rect2(175, 410, 275, 57).has_point(mouse_pos):
					responder_documento(true)
				elif Rect2(506, 410, 275, 57).has_point(mouse_pos):
					responder_documento(false)

			elif modo == "memoria":

				for i in range(6):
					if rect_carta(i).has_point(mouse_pos):
						voltear(i)
						break

			elif modo == "clasifica":

				for posicion in range(orden_clasificacion.size()):

					var id_doc: int = int(orden_clasificacion[posicion])

					if clasificados.has(id_doc):
						continue

					if rect_clasificar(posicion).has_point(mouse_pos):
						arrastrando = id_doc
						break

		else:

			if modo == "clasifica" and arrastrando != -1:

				var seleccionado := arrastrando
				arrastrando = -1

				if Rect2(65, 405, 410, 90).has_point(mouse_pos):
					clasificar_documento(seleccionado, true)

				elif Rect2(500, 405, 410, 90).has_point(mouse_pos):
					clasificar_documento(seleccionado, false)

		queue_redraw()
		return

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	var k: int = event.keycode

	if modo in ["intro", "memoria_inicio", "clasifica_inicio"]:

		if k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:

			match modo:
				"intro":
					iniciar_detectives()
				"memoria_inicio":
					iniciar_memoria()
				"clasifica_inicio":
					iniciar_clasificacion()

	elif modo == "detectives":

		if k in [KEY_1, KEY_KP_1]:
			responder_documento(true)
		elif k in [KEY_2, KEY_KP_2]:
			responder_documento(false)

	elif modo == "respuesta_documento":

		if k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
			siguiente_documento()

	elif modo in ["sin_tiempo", "insuficientes"]:

		if k in [KEY_R, KEY_ENTER]:
			iniciar_detectives()

	elif modo == "memoria":

		var teclas := [
			KEY_1, KEY_2, KEY_3,
			KEY_4, KEY_5, KEY_6
		]

		if k in teclas:
			voltear(teclas.find(k))

	elif modo == "memoria_fin":

		if k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
			modo = "clasifica_inicio"

	elif modo == "clasifica_error":

		if k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
			modo = "clasifica"

	elif modo == "clasifica_fin":

		if k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
			terminar_tarea()

	elif modo == "victoria":

		if k == KEY_R:
			get_tree().change_scene_to_file("res://scenes/camino_costa.tscn")
		elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE]:
			get_tree().change_scene_to_file("res://main.tscn")

	if k == KEY_ESCAPE and modo != "victoria":
		get_tree().change_scene_to_file("res://main.tscn")

	queue_redraw()


# =========================================================
# MINIJUEGO 1: DETECTIVES
# =========================================================

func iniciar_detectives() -> void:

	indice = 0
	aciertos = 0
	puntos = 0
	tiempo = 60.0
	mensaje = ""
	mensaje_color = VERDE
	modo = "detectives"


func responder_documento(es_valido: bool) -> void:

	if modo != "detectives" or documentos.size() != 6:
		return

	var doc: Dictionary = documentos[int(orden[indice])]
	var correcto: bool = es_valido == bool(doc["valido"])

	if correcto:
		aciertos += 1
		puntos += 20
		mensaje = "¡Correcto! " + str(doc["explicacion"])
		mensaje_color = VERDE
	else:
		puntos = maxi(0, puntos - 5)
		mensaje = "Revisa los datos: " + str(doc["explicacion"])
		mensaje_color = ROJO

	modo = "respuesta_documento"


func siguiente_documento() -> void:

	indice += 1

	if indice >= 6:
		if aciertos >= 4:
			modo = "memoria_inicio"
		else:
			modo = "insuficientes"
		return

	modo = "detectives"


# =========================================================
# MINIJUEGO 2: MEMORIA TRIBUTARIA
# =========================================================

func iniciar_memoria() -> void:

	cartas = [
		{"clave":"boleta", "texto":"BOLETA\nB001-000125"},
		{"clave":"boleta", "texto":"CONSUMO\nFINAL"},
		{"clave":"factura", "texto":"FACTURA\nF001-000083"},
		{"clave":"factura", "texto":"COMPRA\nEMPRESARIAL"},
		{"clave":"ruc", "texto":"RUC DEL\nEMISOR"},
		{"clave":"ruc", "texto":"IDENTIFICA AL\nVENDEDOR"}
	]

	cartas.shuffle()
	abiertas.clear()
	emparejadas.clear()
	timer_voltear = 0.0
	modo = "memoria"


func rect_carta(i: int) -> Rect2:

	var columna := i % 3
	var fila := int(i / 3)

	return Rect2(
		75 + columna * 280,
		180 + fila * 145,
		250,
		115
	)


func voltear(i: int) -> void:

	if modo != "memoria":
		return

	if timer_voltear > 0.0:
		return

	if i < 0 or i >= cartas.size():
		return

	if emparejadas.has(i) or abiertas.has(i):
		return

	abiertas.append(i)

	if abiertas.size() == 2:

		var a: int = int(abiertas[0])
		var b: int = int(abiertas[1])

		if cartas[a]["clave"] == cartas[b]["clave"]:

			emparejadas.append(a)
			emparejadas.append(b)
			abiertas.clear()

			puntos += 15

			if emparejadas.size() == 6:
				modo = "memoria_fin"

		else:
			timer_voltear = 0.85


# =========================================================
# DIBUJO DE MEMORIA
# =========================================================

func dibujar_memoria() -> void:

	# Fondo del minijuego.
	draw_rect(
		Rect2(0, 74, ANCHO, 436),
		Color("#f4dfb8")
	)

	# Encabezado.
	texto(
		Vector2(65, 112),
		"RETO 02  /  MEMORIA TRIBUTARIA",
		14,
		MAR
	)

	texto(
		Vector2(65, 148),
		"ENCUENTRA LAS 3 PAREJAS",
		25,
		TINTA
	)

	texto(
		Vector2(65, 170),
		"Voltea dos cartas y relaciona los conceptos correctamente.",
		14,
		MAR
	)

	# Progreso.
	var parejas: int = int(emparejadas.size() / 2)

	texto(
		Vector2(755, 112),
		"PAREJAS: %d / 3" % parejas,
		17,
		VERDE
	)

	draw_rect(
		Rect2(755, 125, 155, 10),
		Color("#d8d8cf")
	)

	if parejas > 0:
		draw_rect(
			Rect2(755, 125, 155.0 * parejas / 3.0, 10),
			Color("#35a878")
		)

	# Las seis cartas.
	for i in range(6):

		var r: Rect2 = rect_carta(i)

		var esta_abierta: bool = abiertas.has(i)
		var esta_emparejada: bool = emparejadas.has(i)

		# Carta encontrada.
		if esta_emparejada:

			cajita(
				r,
				Color("#d8f2df"),
				Color("#29945d")
			)

			draw_rect(
				Rect2(r.position.x + 2, r.position.y + 2, 246, 7),
				Color("#29945d")
			)

			texto(
				r.position + Vector2(17, 35),
				"✓ PAREJA ENCONTRADA",
				14,
				VERDE
			)

			var lineas: PackedStringArray = str(
				cartas[i]["texto"]
			).split("\n")

			for j in range(lineas.size()):
				texto(
					r.position + Vector2(17, 67 + j * 23),
					lineas[j],
					15,
					TINTA
				)

		# Carta descubierta.
		elif esta_abierta:

			cajita(
				r,
				Color("#fffdf6"),
				Color("#d29a45")
			)

			texto(
				r.position + Vector2(17, 29),
				"DOCUMENTO TRIBUTARIO",
				12,
				MAR
			)

			var clave: String = str(cartas[i]["clave"]).to_upper()

			texto(
				r.position + Vector2(17, 59),
				clave,
				20,
				TINTA
			)

			var lineas: PackedStringArray = str(
				cartas[i]["texto"]
			).split("\n")

			for j in range(lineas.size()):
				texto(
					r.position + Vector2(17, 85 + j * 19),
					lineas[j],
					13,
					MAR
				)

		# Carta oculta.
		else:

			cajita(
				r,
				Color("#175d78"),
				Color("#0d405b")
			)

			cajita(
				Rect2(
					r.position.x + 9,
					r.position.y + 9,
					232,
					97
				),
				Color("#246f86"),
				Color("#77b4c2")
			)

			texto(
				r.position + Vector2(107, 64),
				"?",
				43,
				DORADO
			)

			texto(
				r.position + Vector2(17, 29),
				"CARTA OCULTA",
				11,
				CLARO
			)

			texto(
				r.position + Vector2(17, 96),
				"N.º %02d" % (i + 1),
				12,
				CLARO
			)

	# Instrucciones.
	texto(
		Vector2(190, 485),
		"HAZ CLIC EN DOS CARTAS PARA DESCUBRIR SI SON PAREJA",
		15,
		TINTA
	)

	texto(
		Vector2(385, 508),
		"Encuentra BOLETA, FACTURA y RUC.",
		13,
		MAR
	)


# =========================================================
# MINIJUEGO 3: CLASIFICACIÓN
# =========================================================

func iniciar_clasificacion() -> void:

	clasificados.clear()
	orden_clasificacion.clear()
	arrastrando = -1
	mensaje = ""

	for i in range(documentos.size()):
		orden_clasificacion.append(i)

	orden_clasificacion.shuffle()
	modo = "clasifica"


func rect_clasificar(posicion: int) -> Rect2:

	var columna := posicion % 2
	var fila := int(posicion / 2)

	return Rect2(
		65 + columna * 435,
		174 + fila * 68,
		400,
		58
	)


func clasificar_documento(i: int, destino_correcto: bool) -> void:

	if modo != "clasifica":
		return

	if i < 0 or i >= documentos.size():
		return

	if clasificados.has(i):
		return

	var doc: Dictionary = documentos[i]
	var es_valido: bool = bool(doc["valido"])

	if destino_correcto == es_valido:

		clasificados[i] = true
		puntos += 10

		mensaje = "¡Correcto! " + str(doc["explicacion"])
		mensaje_color = VERDE

		if clasificados.size() >= documentos.size():
			modo = "clasifica_fin"
		else:
			modo = "clasifica"

	else:

		mensaje = "¡Clasificación incorrecta! Revisa los datos del comprobante."
		mensaje_color = ROJO
		modo = "clasifica_error"


func dibujar_tarjeta(i: int, posicion: int) -> void:

	var doc: Dictionary = documentos[i]
	var r: Rect2 = rect_clasificar(posicion)

	var fondo := Color("#ffffff")
	var borde := Color("#9ab9c7")

	if clasificados.has(i):
		fondo = Color("#dff4e6")
		borde = VERDE

	cajita(r, fondo, borde)

	draw_rect(
		Rect2(r.position.x, r.position.y + 8, 5, 42),
		borde
	)

	texto(
		r.position + Vector2(17, 23),
		str(doc["tipo"]).to_upper(),
		14,
		TINTA
	)

	texto(
		r.position + Vector2(17, 44),
		"RUC: " + str(doc["ruc"]) +
		" | SERIE: " + str(doc["serie"]) +
		" | N°: " + str(doc["numero"]),
		12,
		MAR
	)

	if clasificados.has(i):
		texto(
			r.position + Vector2(345, 35),
			"OK",
			15,
			VERDE
		)


func dibujar_clasificacion() -> void:

	texto(
		Vector2(65, 112),
		"RETO 03 / ARCHIVO DE COMPROBANTES",
		14,
		MAR
	)

	texto(
		Vector2(65, 145),
		"CLASIFICACIÓN DE DOCUMENTOS",
		25,
		TINTA
	)

	texto(
		Vector2(65, 165),
		"Analiza los datos y decide dónde corresponde cada comprobante.",
		14,
		MAR
	)

	texto(
		Vector2(720, 112),
		"PROGRESO: %d / %d" % [
			clasificados.size(),
			documentos.size()
		],
		15,
		VERDE
	)

	draw_rect(
		Rect2(720, 123, 190, 10),
		Color("#d8e2e5")
	)

	var proporcion := float(clasificados.size()) / maxf(
		1.0,
		float(documentos.size())
	)

	if proporcion > 0.0:
		draw_rect(
			Rect2(720, 123, 190 * proporcion, 10),
			Color("#35a878")
		)

	for posicion in range(orden_clasificacion.size()):

		var id_doc: int = int(orden_clasificacion[posicion])

		if arrastrando == id_doc:
			continue

		dibujar_tarjeta(id_doc, posicion)

	# Caja de válidos.
	cajita(
		Rect2(65, 405, 410, 90),
		Color("#d9f2e2"),
		Color("#29945d")
	)

	texto(Vector2(105, 443), "✓", 29, VERDE)
	texto(Vector2(155, 438), "COMPROBANTES VÁLIDOS", 18, VERDE)
	texto(Vector2(155, 464), "Documentos que cumplen los requisitos", 12, TINTA)

	# Caja de inválidos.
	cajita(
		Rect2(500, 405, 410, 90),
		Color("#ffe2df"),
		Color("#c64e4e")
	)

	texto(Vector2(540, 443), "X", 29, ROJO)
	texto(Vector2(590, 438), "COMPROBANTES INVÁLIDOS", 18, ROJO)
	texto(Vector2(590, 464), "Documentos con errores o datos faltantes", 12, TINTA)

	# Tarjeta arrastrada.
	if arrastrando != -1:

		var doc: Dictionary = documentos[arrastrando]

		var r := Rect2(
			mouse_pos - Vector2(200, 29),
			Vector2(400, 58)
		)

		cajita(r, Color("#fff0bd"), DORADO)

		texto(
			r.position + Vector2(17, 23),
			str(doc["tipo"]).to_upper(),
			15,
			TINTA
		)

		texto(
			r.position + Vector2(17, 44),
			"RUC: " + str(doc["ruc"]) + " | SERIE: " + str(doc["serie"]),
			12,
			MAR
		)

	texto(
		Vector2(260, 520),
		"ARRASTRA LOS DOCUMENTOS A LA CATEGORÍA CORRESPONDIENTE",
		13,
		TINTA
	)


# =========================================================
# FINALIZAR TAREA
# =========================================================

func terminar_tarea() -> void:

	modo = "victoria"

	RutaT2.bodega_completada = true
	RutaT2.puntuacion_comprobantes = puntos
	RutaT2.monedas += puntos
	RutaT2.guardar()


# =========================================================
# FUNCIONES DE DIBUJO
# =========================================================

func texto(
	pos: Vector2,
	t: String,
	size: int = 19,
	c: Color = TINTA
) -> void:

	draw_string(
		font,
		pos,
		t,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		size,
		c
	)


func cajita(
	r: Rect2,
	color: Color,
	borde: Color = MAR
) -> void:

	draw_rect(r, color)
	draw_rect(r, borde, false, 2.0)


func multilinea(
	pos: Vector2,
	content: String,
	size: int,
	limit: int,
	color: Color,
	altura: int = 25
) -> void:

	var partes: PackedStringArray = content.split(" ")
	var linea := ""
	var n := 0

	for p in partes:

		var palabra: String = str(p)

		if linea.length() + palabra.length() + 1 > limit:

			texto(
				pos + Vector2(0, n * altura),
				linea,
				size,
				color
			)

			n += 1
			linea = palabra

		else:

			linea += (" " if linea != "" else "") + palabra

	if linea != "":
		texto(
			pos + Vector2(0, n * altura),
			linea,
			size,
			color
		)


# =========================================================
# FONDO DE BODEGA
# =========================================================

func fondo_bodega() -> void:

	draw_rect(
		Rect2(0, 0, ANCHO, ALTO),
		Color("#f1d39d")
	)

	draw_rect(
		Rect2(0, 0, ANCHO, 74),
		Color("#145b78")
	)

	texto(
		Vector2(20, 31),
		"TRIBUTA PERÚ  ·  NIVEL 2 / BODEGA COSTERA",
		22,
		DORADO
	)

	texto(
		Vector2(20, 57),
		"Tres minijuegos: detectives + memoria + clasificación",
		15,
		CLARO
	)

	draw_rect(
		Rect2(0, 510, ANCHO, 30),
		Color("#cda36b")
	)

	# Ocultar estantes durante los minijuegos que necesitan espacio.
	if modo not in [
		"memoria",
		"memoria_inicio",
		"memoria_fin",
		"clasifica",
		"clasifica_error",
		"clasifica_inicio",
		"clasifica_fin"
	]:

		for i in range(7):

			cajita(
				Rect2(20 + i * 137, 92, 107, 35),
				Color("#a56d45"),
				Color("#c08c5c")
			)

			for j in range(4):

				draw_rect(
					Rect2(
						24 + i * 137 + j * 25,
						99,
						16,
						20
					),
					Color("#e66b52") if (i + j) % 2 == 0 else Color("#78b58a")
				)

	texto(
		Vector2(754, 56),
		"★ %d pts" % puntos,
		18,
		DORADO
	)


# =========================================================
# COMPROBANTE DE DETECTIVES
# =========================================================

func comprobante(doc: Dictionary) -> void:

	cajita(
		Rect2(221, 135, 519, 267),
		CLARO,
		Color("#6f8591")
	)

	texto(Vector2(238, 163), str(doc["tipo"]), 19, TINTA)
	texto(Vector2(238, 191), str(doc["emisor"]), 16, TINTA)

	var ruc: String = str(doc["ruc"])
	var serie: String = str(doc["serie"])
	var num: String = str(doc["numero"])

	texto(
		Vector2(238, 221),
		"RUC: " + ruc,
		18,
		ROJO if ruc == "—" else VERDE
	)

	texto(
		Vector2(238, 251),
		"Serie y número: " + serie + " - " + num,
		18,
		ROJO if serie == "—" else VERDE
	)

	texto(Vector2(238, 281), "Fecha: " + str(doc["fecha"]), 18)
	texto(Vector2(238, 313), "Venta: " + str(doc["detalle"]), 18)
	texto(Vector2(238, 352), "TOTAL: " + str(doc["total"]), 20, MAR)
	texto(Vector2(614, 386), str(doc["id"]), 15, MAR)


func mostrar_detectives() -> void:

	texto(Vector2(31, 158), "DETECTIVES", 20, TINTA)
	texto(Vector2(31, 189), "Documento", 15)
	texto(Vector2(31, 215), "%d de 6" % (indice + 1), 22, MAR)
	texto(Vector2(31, 261), "Aciertos: %d" % aciertos, 17, TINTA)
	texto(Vector2(31, 296), "TIEMPO", 17, TINTA)

	texto(
		Vector2(31, 326),
		"%02d s" % int(ceil(tiempo)),
		27,
		ROJO if tiempo < 12 else MAR
	)

	draw_rect(Rect2(26, 344, 164, 9), Color("#d2d8d2"))
	draw_rect(Rect2(26, 344, 164 * tiempo / 60.0, 9), VERDE)

	comprobante(documentos[int(orden[indice])])

	cajita(Rect2(175, 410, 275, 57), Color("#a7e3c5"))
	cajita(Rect2(506, 410, 275, 57), Color("#ffb9ae"))

	texto(Vector2(218, 445), "1 · VÁLIDO", 22, TINTA)
	texto(Vector2(546, 445), "2 · INVÁLIDO", 22, TINTA)

	texto(
		Vector2(257, 496),
		"Examínalo y decide antes de que se acabe el tiempo",
		16,
		TINTA
	)


# =========================================================
# PANTALLAS GENERALES
# =========================================================

func pantalla(
	titulo: String,
	cuerpo: String,
	pie: String,
	color: Color = TINTA
) -> void:

	cajita(
		Rect2(103, 143, 754, 321),
		Color("#fffcf5"),
		MAR
	)

	texto(Vector2(163, 202), titulo, 28, color)
	multilinea(Vector2(157, 257), cuerpo, 20, 63, TINTA, 28)
	texto(Vector2(244, 426), pie, 19, MAR)


# =========================================================
# DIBUJAR TODAS LAS PANTALLAS
# =========================================================

func _draw() -> void:

	fondo_bodega()

	match modo:

		"intro":

			pantalla(
				"¡BIENVENIDO A LA BODEGA!",
				"Terminaste el camino del malecón. Ahora deberás revisar comprobantes en 60 segundos, hacer memoria y clasificar documentos. Son retos diferentes a los de la Plaza.",
				"PRESIONA ENTER PARA EMPEZAR"
			)

		"detectives", "respuesta_documento":

			mostrar_detectives()

			if modo == "respuesta_documento":

				cajita(
					Rect2(84, 354, 795, 145),
					CLARO,
					mensaje_color
				)

				multilinea(
					Vector2(108, 392),
					mensaje,
					18,
					78,
					mensaje_color,
					26
				)

				texto(
					Vector2(338, 473),
					"ENTER · siguiente comprobante",
					17,
					TINTA
				)

		"sin_tiempo":

			pantalla(
				"¡SE ACABARON LOS 60 SEGUNDOS!",
				"Revisaste %d de 6 documentos y acertaste %d. Repasa los campos RUC, serie, número y fecha para continuar." % [
					indice,
					aciertos
				],
				"PULSA R O ENTER PARA REINTENTAR",
				ROJO
			)

		"insuficientes":

			pantalla(
				"¡NECESITAMOS REVISAR OTRA VEZ!",
				"Lograste %d de 6. Debes conseguir al menos 4 aciertos para abrir el minijuego de memoria. Equivocarse también es parte del aprendizaje." % aciertos,
				"PULSA R O ENTER PARA REINTENTAR",
				ROJO
			)

		"memoria_inicio":

			pantalla(
				"¡PRIMER RETO SUPERADO!",
				"Detectaste %d de 6 comprobantes. Ahora encontrarás tres parejas entre conceptos y características tributarias. No hay cronómetro en esta parte." % aciertos,
				"ENTER · JUGAR MEMORIA",
				VERDE
			)

		"memoria":

			dibujar_memoria()

		"memoria_fin":

			pantalla(
				"¡MEMORIA SUPERADA!",
				"Encontraste las tres parejas de boleta, factura y RUC. Ahora tendrás que analizar seis documentos y clasificarlos correctamente.",
				"ENTER · CLASIFICAR COMPROBANTES",
				VERDE
			)

		"clasifica_inicio":

			pantalla(
				"¡ÚLTIMO RETO: CLASIFICACIÓN!",
				"Analiza los datos de seis comprobantes. Arrastra cada tarjeta a la categoría de VÁLIDOS o INVÁLIDOS. Los documentos aparecerán mezclados y tendrás que revisar sus datos.",
				"ENTER · COMENZAR"
			)

		"clasifica":

			dibujar_clasificacion()

		"clasifica_error":

			dibujar_clasificacion()

			cajita(
				Rect2(205, 365, 550, 32),
				Color("#fff0ed"),
				ROJO
			)

			texto(
				Vector2(240, 387),
				"¡Categoría incorrecta! Presiona ENTER para intentarlo otra vez.",
				14,
				ROJO
			)

		"clasifica_fin":

			pantalla(
				"¡CLASIFICACIÓN SUPERADA!",
				"¡Excelente! Clasificaste correctamente los seis comprobantes. Has completado los tres minijuegos de la Bodega.",
				"ENTER · FINALIZAR NIVEL 2",
				VERDE
			)

		"victoria":

			cajita(
				Rect2(90, 125, 787, 351),
				Color("#fff9ec"),
				DORADO
			)

			texto(Vector2(167, 180), "¡TAREA 2 COMPLETADA!", 32, VERDE)
			texto(Vector2(155, 234), "Detectives + Memoria + Clasificación", 21, MAR)
			texto(Vector2(222, 288), "PUNTOS EN BODEGA: %d" % puntos, 25, TINTA)
			texto(Vector2(152, 341), "Siguiente destino: SUNAT (Nivel 3).", 21, TINTA)
			texto(Vector2(140, 394), "¡Has superado los tres minijuegos!", 19, MAR)
			texto(Vector2(181, 450), "ENTER: volver al mapa · R: repetir camino", 17, MAR)
