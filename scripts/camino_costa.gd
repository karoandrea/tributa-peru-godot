extends Node2D
## Tarea 2 · Transición jugable de la Plaza a la Bodega.
## Plataforma horizontal con 2.5D ilustrado; conserva los personajes originales.

const W := 960.0
const H := 540.0
const MUNDO := 2910.0
const SUELO := 411.0
const VELOCIDAD := 260.0
const GRAVEDAD := 1540.0
const SALTO := -660.0
const AZUL := Color("#123854")
const DORADO := Color("#ffe29a")
const BLANCO := Color("#fff9eb")
const COCO := Color("#8e5527")

var fuente: Font
var sprite: Texture2D
var px: float = 90.0
var pies: float = SUELO
var vy: float = 0.0
var cam: float = 0.0
var vidas: int = 3
var invulnerable: float = 0.0
var avatar_camino: bool = false
var dir_izq: bool = false
var tiempo: float = 0.0
var inicio: bool = true
var recogidas: Dictionary = {}
var aviso: String = ""
var aviso_t: float = 0.0
var bandera: float = 90.0
var cocos: Array = [310.0, 575.0, 845.0, 1090.0, 1350.0, 1615.0, 1900.0, 2150.0, 2455.0]
# Movimiento de los cocos
var cocos_inicio: Array = []
var cocos_direccion: Array = []
var cocos_velocidad: float = 75.0
var cocos_limite: float = 65.0
var cocos_rango: float = 65.0
var estrellas: Array = [195.0, 440.0, 700.0, 975.0, 1220.0, 1490.0, 1775.0, 2020.0, 2310.0, 2590.0]

func _ready() -> void:
	fuente = ThemeDB.fallback_font
	sprite = load("res://assets/heroes/%s.png" % RutaT2.personaje)

	cocos_inicio = cocos.duplicate()

	for i in range(cocos.size()):
		cocos_direccion.append(1.0 if i % 2 == 0 else -1.0)

	queue_redraw()

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var k: int = event.keycode
	if inicio:
		if k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
			inicio = false
		return
	if k in [KEY_SPACE, KEY_W, KEY_UP]:
		if pies >= SUELO - 0.5:
			vy = SALTO
	elif k == KEY_R:
		reiniciar_tramo()
	elif k == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://main.tscn")
	queue_redraw()

func _process(delta: float) -> void:
	tiempo += delta
	
	# Movimiento horizontal de los cocos
	for i in range(cocos.size()):
		cocos[i] += cocos_direccion[i] * cocos_velocidad * delta

		if cocos[i] >= cocos_inicio[i] + cocos_rango:
			cocos[i] = cocos_inicio[i] + cocos_rango
			cocos_direccion[i] = -1.0

		elif cocos[i] <= cocos_inicio[i] - cocos_rango:
			cocos[i] = cocos_inicio[i] - cocos_rango
			cocos_direccion[i] = 1.0

	if aviso_t > 0.0:
		aviso_t -= delta
	invulnerable = maxf(0.0, invulnerable - delta)
	if inicio:
		queue_redraw()
		return
	var eje := 0.0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		eje += 1.0
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		eje -= 1.0
	avatar_camino = absf(eje) > 0.0
	if eje < 0.0:
		dir_izq = true
	elif eje > 0.0:
		dir_izq = false
	px = clampf(px + eje * VELOCIDAD * delta, 37.0, MUNDO - 58.0)
	vy += GRAVEDAD * delta
	pies = minf(SUELO, pies + vy * delta)
	if pies >= SUELO:
		vy = 0.0
	# El siguiente punto de control evita repetir todo el camino.
	if px > 1480.0:
		bandera = 1470.0
	if invulnerable == 0.0:
		for cx in cocos:
			if absf(px - float(cx)) < 24.0 and pies > SUELO - 47.0:
				chocar()
				break
	for i in range(estrellas.size()):
		if recogidas.has(str(i)):
			continue
		var sx: float = estrellas[i]
		var sy: float = SUELO - (30.0 if i % 2 == 0 else 91.0)
		if Vector2(px, pies - 22.0).distance_to(Vector2(sx, sy)) < 42.0:
			recogidas[str(i)] = true
			RutaT2.estrellas += 1
			RutaT2.monedas += 10
			aviso = "+10 puntos: estrella de mar"
			aviso_t = 1.4
			RutaT2.guardar()
	cam = clampf(px - 230.0, 0.0, MUNDO - W)
	if px >= MUNDO - 105.0:
		RutaT2.camino_completado = true
		RutaT2.guardar()
		get_tree().change_scene_to_file("res://scenes/bodega_t2.tscn")
		return
	queue_redraw()

func chocar() -> void:
	vidas -= 1
	invulnerable = 1.5
	aviso = "¡Cuidado con los cocos! Regresas al punto de control."
	aviso_t = 2.3
	px = bandera
	pies = SUELO
	vy = 0.0
	if vidas <= 0:
		vidas = 3
		aviso = "¡Nueva oportunidad! Intenta calcular el salto."

func reiniciar_tramo() -> void:
	px = 90.0
	pies = SUELO
	vy = 0.0
	vidas = 3
	bandera = 90.0
	aviso = "Recorrido reiniciado. ¡Vamos!"
	aviso_t = 1.8

func texto(pos: Vector2, t: String, tam: int = 20, color: Color = AZUL) -> void:
	draw_string(fuente, pos, t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, color)

func rect(r: Rect2, c: Color) -> void:
	draw_rect(r, c)

func estrella(pos: Vector2, r: float, c: Color) -> void:
	var puntos := PackedVector2Array()
	for n in range(10):
		var ang: float = -PI / 2.0 + TAU * float(n) / 10.0
		var rad: float = r if n % 2 == 0 else r * 0.44
		puntos.append(pos + Vector2(cos(ang), sin(ang)) * rad)
	draw_colored_polygon(puntos, c)

func palmera(x: float) -> void:
	var sx: float = x - cam
	if sx < -100 or sx > W + 100:
		return
	rect(Rect2(sx - 8, 196, 16, 196), Color("#81572f"))
	for d in [-1, 0, 1]:
		draw_line(Vector2(sx, 198), Vector2(sx + d * 69, 166 + abs(d) * 12), Color("#248d6a"), 15.0)
		draw_line(Vector2(sx, 198), Vector2(sx + d * 53, 132), Color("#30a875"), 11.0)

func _draw() -> void:
	# Atmósfera de la costa peruana: cielo cálido, horizonte marino, malecón y palmeras.
	rect(Rect2(0, 0, W, H), Color("#9cd8ed"))
	rect(Rect2(0, 92, W, 62), Color("#aedce9"))
	rect(Rect2(0, 154, W, 67), Color("#bde6e7"))
	draw_circle(Vector2(825, 100), 43, Color("#fff0a2"))
	rect(Rect2(0, 213, W, 161), Color("#42bad1"))
	for i in range(18):
		var x: float = fposmod(float(i) * 83.0 - cam * 0.18, W + 80.0) - 40.0
		draw_line(Vector2(x, 252 + (i % 3) * 23), Vector2(x + 53, 252 + (i % 3) * 23), Color("#e9ffff"), 3)
	rect(Rect2(0, 366, W, 174), Color("#efcf87"))
	rect(Rect2(0, 413, W, 127), Color("#dcae61"))
	rect(Rect2(0, 408, W, 7), Color("#ffdf9c"))
	for i in range(24):
		var x: float = float(i) * 126.0 - cam
		if x > -30 and x < W + 30:
			draw_circle(Vector2(x, 490 + i % 3 * 11), 3, Color("#c58e52"))
	for p in [220.0, 805.0, 1438.0, 2240.0, 2660.0]:
		palmera(p)
	# Puesto del malecón e indicaciones visuales.
	var bx: float = MUNDO - 115.0 - cam
	if bx > -150 and bx < W + 100:
		rect(Rect2(bx - 85, 281, 155, 132), Color("#f7f1d7"))
		rect(Rect2(bx - 95, 271, 174, 24), Color("#ef785a"))
		rect(Rect2(bx - 64, 303, 114, 38), Color("#276e83"))
		texto(Vector2(bx - 44, 330), "BODEGA", 17, BLANCO)
		rect(Rect2(bx - 22, 345, 45, 67), Color("#95633a"))
	for cx in cocos:
		var sx: float = float(cx) - cam
		if sx < -35 or sx > W + 35:
			continue
		draw_circle(Vector2(sx, SUELO - 13), 17, COCO)
		draw_circle(Vector2(sx - 5, SUELO - 16), 4, Color("#b77a42"))
		draw_circle(Vector2(sx + 5, SUELO - 9), 3, Color("#4b2e20"))
	for i in range(estrellas.size()):
		if recogidas.has(str(i)):
			continue
		var sx: float = float(estrellas[i]) - cam
		if sx < -40 or sx > W + 40:
			continue
		var sy: float = SUELO - (30.0 if i % 2 == 0 else 91.0)
		estrella(Vector2(sx, sy) + Vector2(0, sin(tiempo * 4.0 + i) * 4.0), 16.0, Color("#ffdc57"))
		draw_circle(Vector2(sx - 4, sy - 3), 2, Color("#fb844f"))
	if bandera > 1000.0:
		var chk: float = bandera - cam
		draw_line(Vector2(chk, 410), Vector2(chk, 296), Color("#b5793d"), 6)
		rect(Rect2(chk + 2, 299, 49, 30), Color("#e53935"))
	# Sprite: atlas 3 columnas x 4 filas. Abajo, izquierda, derecha, arriba.
	if sprite:
		var frame: int = 1 if not avatar_camino else (0 if int(tiempo * 9.0) % 2 == 0 else 2)
		var row: int = 1 if dir_izq else 2
		var tint: Color = Color(1, 1, 1, 0.45) if invulnerable > 0.0 and int(tiempo * 13.0) % 2 == 0 else Color.WHITE
		draw_texture_rect_region(sprite, Rect2(px - cam - 33.0, pies - 78.0, 66, 78), Rect2(frame * 96, row * 96, 96, 96), tint)
	rect(Rect2(0, 0, W, 64), AZUL)
	texto(Vector2(22, 30), "TRIBUTA PERÚ  /  CAMINO A LA BODEGA", 21, DORADO)
	texto(Vector2(22, 55), "♥ %d    ★ %d recolectadas    +10 por cada estrella" % [vidas, recogidas.size()], 16, BLANCO)
	texto(Vector2(679, 29), "PROGRESO: %d%%" % int(100.0 * px / MUNDO), 17, BLANCO)
	draw_rect(Rect2(685, 40, 241, 9), Color("#3a657b"))
	draw_rect(Rect2(685, 40, 241.0 * px / MUNDO, 9), Color("#ffcf65"))
	texto(Vector2(18, 522), "A / D o ← / → mover  ·  ESPACIO saltar  ·  R reiniciar  ·  ESC salir", 15, AZUL)
	if aviso_t > 0.0:
		rect(Rect2(128, 76, 700, 48), Color("#23485e"))
		texto(Vector2(146, 106), aviso, 17, BLANCO)
	if inicio:
		rect(Rect2(113, 111, 735, 321), Color("#133c5c"))
		draw_rect(Rect2(113, 111, 735, 321), DORADO, false, 4)
		texto(Vector2(204, 162), "¡LA PLAZA QUEDÓ ATRÁS!", 28, DORADO)
		texto(Vector2(169, 216), "MISIÓN: LLEGA A LA BODEGA DE LA COSTA", 21, BLANCO)
		texto(Vector2(168, 259), "Salta cocos, recoge estrellas de mar y avanza", 20, BLANCO)
		texto(Vector2(168, 292), "por el malecón. Las estrellas suman puntos.", 20, BLANCO)
		texto(Vector2(168, 345), "Los retos de la bodega serán DISTINTOS al Nivel 1.", 18, DORADO)
		texto(Vector2(312, 400), "ENTER PARA COMENZAR", 24, DORADO)
