extends Node2D
## Arte local dibujado en una cuadrícula de píxeles; sin dependencias externas.
const SIZE := Vector2(1920, 1280)
const BUILDINGS := [
	{"rect": Rect2(105, 170, 240, 160), "label": "BARRIO · CASAS DEL RÍO", "color": "#a9633e", "type": "home"},
	{"rect": Rect2(455, 195, 190, 135), "label": "VIVIENDA", "color": "#c68147", "type": "home"},
	{"rect": Rect2(840, 140, 300, 190), "label": "ESCUELA · NUEVA SEMILLA", "color": "#c89955", "type": "school"},
	{"rect": Rect2(180, 660, 220, 140), "label": "BETO · OFERTAS", "color": "#c06c43", "type": "shop"},
	{"rect": Rect2(510, 640, 240, 160), "label": "ROSA · LIBRERÍA", "color": "#478f79", "type": "shop"},
	{"rect": Rect2(1290, 740, 230, 150), "label": "CONTROL DE MERCANCÍAS", "color": "#6e91a0", "type": "control"}]
const POINTS := [
	["ana", "Ana · vecina", Vector2(260, 380), "npc", "mara"],
	["docente", "Docente Sol", Vector2(980, 375), "npc", "elena"],
	["beto", "Beto · ofertas", Vector2(290, 845), "npc", "alcalde"],
	["rosa", "Rosa · librería", Vector2(630, 845), "npc", "rosa"],
	["elena", "Elena · plaza", Vector2(1090, 680), "npc", "elena"],
	["service_light", "Alumbrado", Vector2(935, 555), "light", ""],
	["service_water", "Punto de agua", Vector2(1030, 780), "water", ""],
	["service_school", "Techo escolar", Vector2(1165, 365), "notice", ""],
	["estibador", "Diego · estibador", Vector2(1450, 1015), "npc", "luis"],
	["control", "Lucía · control", Vector2(1390, 935), "npc", "mara"],
	["clue_cargo", "Cajas de carga", Vector2(1590, 978), "cargo", ""],
	["clue_manifest", "Lista de carga", Vector2(1720, 1000), "paper", ""],
	["clue_route", "Nota de ruta", Vector2(1460, 1130), "paper", ""],
	["capitana", "Capitana Inés · Costa", Vector2(1540, 1160), "npc", "elena"],
	["recycle_paper", "Papel usado", Vector2(435, 395), "paper", ""],
	["recycle_plastic", "Botella", Vector2(450, 915), "plastic", ""],
	["recycle_organic", "Cáscara", Vector2(1160, 1050), "organic", ""],
	["bin_paper", "Papel", Vector2(980, 885), "bin", "#66a6cf"],
	["bin_plastic", "Plástico", Vector2(1080, 885), "bin", "#e0b04b"],
	["bin_organic", "Orgánico", Vector2(1180, 885), "bin", "#ae8354"],
	["crossing", "Cruce seguro", Vector2(800, 550), "crossing", ""],
	["trivia", "Tomi · trivia", Vector2(1100, 1110), "npc", "alcalde"]]
var obstacles: Array[Rect2] = []
var palms: Array[Vector2] = []
var elapsed := 0.0
var pedestrian_green := false

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for building in BUILDINGS:
		var r: Rect2 = building["rect"]
		block(Rect2(r.position + Vector2(4, 25), r.size - Vector2(8, 25)))
	# Río, excepto puente y muelle. Las piezas forman una orilla continua.
	for r in [Rect2(1600, 0, 320, 610), Rect2(1600, 690, 320, 250), Rect2(1800, 940, 120, 120), Rect2(1600, 1060, 320, 220)]: block(r)
	for r in [Rect2(-30, -30, 1980, 30), Rect2(-30, 1280, 1980, 30), Rect2(-30, 0, 30, 1280), Rect2(1920, 0, 30, 1280)]: block(r)
	palms = [Vector2(65, 130), Vector2(390, 180), Vector2(720, 230), Vector2(1205, 195), Vector2(1440, 180), Vector2(1500, 370), Vector2(85, 590), Vector2(450, 605), Vector2(1260, 580), Vector2(100, 1010), Vector2(260, 1160), Vector2(670, 1100), Vector2(840, 1020), Vector2(1280, 1165), Vector2(65, 1200), Vector2(1510, 610), Vector2(1200, 70), Vector2(620, 75)]
	for p in palms: block(Rect2(p - Vector2(9, 8), Vector2(18, 18)))
	queue_redraw()

func block(rect: Rect2) -> void:
	obstacles.append(rect)
	var body := StaticBody2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.position = rect.get_center()
	body.add_child(collision)
	add_child(body)

func is_walkable(pos: Vector2, margin: float = 11.0) -> bool:
	if not Rect2(Vector2(margin, margin), SIZE - Vector2.ONE * margin * 2).has_point(pos): return false
	for r in obstacles:
		if r.grow(margin).has_point(pos): return false
	return true

func _process(delta: float) -> void:
	elapsed += delta
	# Tres segundos de espera, siete para cruzar; el reloj se pausa con diálogos.
	pedestrian_green = fmod(elapsed, 10.0) >= 3.0
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("#397b4a"))
	# Textura de suelo determinista: matas, hojas y flores sobre retícula de 4 px.
	for y in range(0, 1280, 32):
		for x in range(0, 1600, 32):
			var seed_value := (x * 37 + y * 79) % 113
			var shade := Color("#408950") if seed_value < 55 else Color("#367345")
			draw_rect(Rect2(x, y, 32, 32), shade)
			if seed_value % 4 == 0:
				draw_rect(Rect2(x + 8, y + 20, 3, 7), Color("#65a05b"))
				draw_rect(Rect2(x + 13, y + 16, 3, 10), Color("#5d9854"))
			if seed_value % 19 == 0:
				draw_rect(Rect2(x + 20, y + 8, 4, 4), Color("#e9b877"))
	for r in [Rect2(210, 320, 100, 860), Rect2(580, 330, 100, 830), Rect2(210, 350, 1350, 70), Rect2(180, 825, 1375, 70), Rect2(210, 1100, 1350, 75), Rect2(1350, 360, 105, 820), Rect2(960, 330, 100, 530), Rect2(1400, 610, 200, 80), Rect2(1390, 940, 220, 120)]: path(r)
	# Vía y aceras: el paso peatonal es la ruta de la actividad de ciudadanía.
	draw_rect(Rect2(0, 425, 1540, 90), Color("#859285"))
	draw_rect(Rect2(0, 435, 1540, 70), Color("#626e69"))
	for x in range(0, 1540, 90): draw_rect(Rect2(x, 468, 36, 4), Color("#c7c3a1"))
	for y in range(437, 502, 13): draw_rect(Rect2(770, y, 65, 7), Color("#f3edcc"))
	# Plaza con mosaicos, bancos, jardín y fuente.
	draw_rect(Rect2(890, 535, 320, 295), Color("#c6b990"))
	for y in range(540, 830, 20):
		for x in range(895, 1210, 20):
			if (x + y) % 40 == 15: draw_rect(Rect2(x, y, 18, 18), Color("#d3c8a2"))
	draw_rect(Rect2(970, 575, 150, 48), Color("#517c48"))
	for x in range(982, 1110, 16): draw_rect(Rect2(x, 586, 7, 7), Color("#e7c46f"))
	bench(Vector2(1130, 740))
	bench(Vector2(930, 700))
	# Río animado y ribera de arena húmeda.
	draw_rect(Rect2(1576, 0, 24, 1280), Color("#c2b77a"))
	draw_rect(Rect2(1600, 0, 320, 1280), Color("#287e91"))
	for y in range(0, 1280, 32):
		for x in range(1610, 1920, 48):
			var offset := int(elapsed * 9.0 + y * 0.25) % 40
			draw_rect(Rect2(x + offset, y, 22, 3), Color("#4097a4"))
	wood_deck(Rect2(1515, 610, 405, 80))
	wood_deck(Rect2(1500, 940, 300, 120))
	for x in range(1520, 1920, 64):
		draw_rect(Rect2(x, 605, 7, 16), Color("#664b35"))
		draw_rect(Rect2(x, 681, 7, 16), Color("#664b35"))
	draw_rect(Rect2(1515, 609, 405, 4), Color("#d5b67d"))
	draw_rect(Rect2(1515, 685, 405, 4), Color("#d5b67d"))
	boat(Vector2(1690, 1110))
	boat(Vector2(1805, 805))
	for building in BUILDINGS: house(building)
	# Mercado abierto: toldos, mesas, cajones y productos.
	stall(Vector2(180, 550), Color("#d6a846"), "FRUTAS")
	stall(Vector2(515, 550), Color("#b86c54"), "MERCADO")
	for p in palms: palm(p)
	# Cercas bajas decorativas, sin encerrar entradas.
	for x in range(870, 1150, 28):
		draw_rect(Rect2(x, 110, 7, 28), Color("#d2b27b"))
	draw_rect(Rect2(870, 117, 282, 5), Color("#a98453"))
	label_at(Vector2(105, 80), "NUEVA SEMILLA · SELVA PERUANA", 23, Color("#f9e6b2"))
	label_at(Vector2(200, 1030), "MERCADO LOCAL", 18)
	label_at(Vector2(920, 990), "PLAZA COMUNITARIA", 18)
	label_at(Vector2(1300, 1210), "EMBARCADERO → COSTA", 18)
	label_at(Vector2(1670, 570), "PUENTE DEL RÍO", 14)
	# Semáforo: icono y texto además del color.
	draw_rect(Rect2(850, 514, 5, 43), Color("#544d3b"))
	draw_rect(Rect2(840, 510, 26, 29), Color("#173c35"))
	draw_circle(Vector2(853, 524), 8, Color("#99e394") if pedestrian_green else Color("#f08069"))
	label_at(Vector2(870, 532), "PASA" if pedestrian_green else "ESPERA", 12)

func path(r: Rect2) -> void:
	draw_rect(r.grow(5), Color("#6e9052"))
	draw_rect(r, Color("#bb9a62"))
	for x in range(int(r.position.x + 8), int(r.end.x - 8), 38):
		for y in range(int(r.position.y + 10), int(r.end.y - 8), 32):
			draw_rect(Rect2(x, y, 6, 3), Color("#a78b59"))

func label_at(pos: Vector2, text: String, size: int = 14, color: Color = Color("#fcf0cb")) -> void:
	var font := ThemeDB.fallback_font
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_rect(Rect2(pos + Vector2(-6, -size - 3), Vector2(width + 12, size + 10)), Color("#244e3c"))
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func house(b: Dictionary) -> void:
	var r: Rect2 = b["rect"]
	var c := Color(b["color"])
	draw_rect(Rect2(r.position + Vector2(10, 17), r.size), Color(0.08, 0.2, 0.1, 0.3))
	draw_rect(r, Color("#674d34"))
	var wall := Rect2(r.position + Vector2(8, 45), r.size - Vector2(16, 45))
	draw_rect(wall, c)
	for y in range(int(wall.position.y), int(wall.end.y), 10):
		draw_line(Vector2(wall.position.x, y), Vector2(wall.end.x, y), c.darkened(0.18), 2)
	# Alero a dos aguas, capas de palma tejida con bordes escalonados.
	var roof := PackedVector2Array([r.position + Vector2(-14, 50), r.position + Vector2(16, 2), r.position + Vector2(r.size.x - 16, 2), r.position + Vector2(r.size.x + 14, 50)])
	draw_colored_polygon(roof, Color("#745139"))
	for y in range(8, 49, 8):
		var inset := 16 - int(y / 2.0)
		draw_rect(Rect2(r.position.x + inset, r.position.y + y, r.size.x - inset * 2, 5), Color("#b58b4d") if y % 16 == 0 else Color("#9a713e"))
	var door := Rect2(r.position + Vector2(r.size.x / 2 - 20, r.size.y - 62), Vector2(40, 62))
	draw_rect(door.grow(4), Color("#ddc38b"))
	draw_rect(door, Color("#483f32"))
	draw_rect(Rect2(door.position + Vector2(6, 8), Vector2(26, 50)), Color("#765a3d"))
	draw_rect(Rect2(door.position + Vector2(28, 30), Vector2(4, 4)), Color("#dfbd6c"))
	for x in [r.position.x + 27, r.end.x - 69]:
		var w := Rect2(x, r.position.y + 70, 43, 35)
		draw_rect(w.grow(4), Color("#e2c58b"))
		draw_rect(w, Color("#326071"))
		draw_rect(Rect2(x + 19, w.position.y, 4, 35), Color("#d2b982"))
		draw_rect(Rect2(x, w.position.y + 16, 43, 3), Color("#d2b982"))
	if b["type"] == "shop":
		for i in range(8): draw_rect(Rect2(r.position.x - 8 + i * (r.size.x + 16) / 8, r.position.y + 50, (r.size.x + 16) / 8, 20), Color("#e8d6a2") if i % 2 else c.lightened(0.2))
	if b["type"] == "school":
		draw_rect(Rect2(r.position + Vector2(r.size.x / 2 - 42, 60), Vector2(84, 22)), Color("#2c655b"))
		draw_string(ThemeDB.fallback_font, r.position + Vector2(r.size.x / 2 - 34, 76), "ESCUELA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f8eac0"))
	label_at(r.position + Vector2(5, -12), b["label"], 13)

func wood_deck(r: Rect2) -> void:
	draw_rect(r.grow(5), Color("#664d34"))
	draw_rect(r, Color("#bc945f"))
	for x in range(int(r.position.x), int(r.end.x), 16):
		draw_rect(Rect2(x, r.position.y, 2, r.size.y), Color("#836342"))
		for y in [r.position.y + 8, r.end.y - 10]: draw_rect(Rect2(x + 6, y, 3, 3), Color("#685441"))

func palm(p: Vector2) -> void:
	draw_circle(p + Vector2(12, 2), 29, Color(0.1, 0.2, 0.12, 0.18))
	draw_rect(Rect2(p.x - 7, p.y - 68, 14, 74), Color("#82613e"))
	for y in range(-64, 0, 10): draw_rect(Rect2(p.x - 7, p.y + y, 14, 3), Color("#b08d54"))
	for i in range(7):
		var angle := i * TAU / 7.0
		var center := p + Vector2(0, -70)
		var direction := Vector2.from_angle(angle)
		var side := direction.orthogonal() * 15
		var leaves := PackedVector2Array([center, center + direction * 25 + side, center + direction * 62 + Vector2(0, 13), center + direction * 31 - side])
		draw_colored_polygon(leaves, Color("#245c38") if i % 2 else Color("#2f7142"))
		draw_line(center, center + direction * 52 + Vector2(0, 8), Color("#4d8a48"), 2)
	draw_rect(Rect2(p.x - 5, p.y - 75, 11, 9), Color("#c1a05b"))

func bench(p: Vector2) -> void:
	for x in [0, 48]: draw_rect(Rect2(p + Vector2(x, 10), Vector2(5, 18)), Color("#504936"))
	for y in [0, 8, 16]: draw_rect(Rect2(p + Vector2(-4, y), Vector2(62, 5)), Color("#9a7146"))

func stall(p: Vector2, c: Color, title: String) -> void:
	for x in [0, 134]: draw_rect(Rect2(p + Vector2(x, 0), Vector2(6, 65)), Color("#705638"))
	draw_rect(Rect2(p + Vector2(-9, -22), Vector2(158, 40)), c)
	for x in range(0, 150, 30): draw_rect(Rect2(p + Vector2(x - 9, -22), Vector2(14, 40)), Color("#ecddb0"))
	draw_rect(Rect2(p + Vector2(-4, 39), Vector2(150, 20)), Color("#815c39"))
	for x in range(6, 136, 22):
		draw_rect(Rect2(p + Vector2(x, 26), Vector2(15, 14)), Color("#d4ac46"))
		draw_rect(Rect2(p + Vector2(x + 3, 22), Vector2(9, 6)), Color("#7d9f47"))
	label_at(p + Vector2(12, 83), title, 12)

func boat(p: Vector2) -> void:
	var hull := PackedVector2Array([p + Vector2(-65, 0), p + Vector2(-43, 27), p + Vector2(46, 27), p + Vector2(70, 0), p + Vector2(43, -14), p + Vector2(-40, -14)])
	draw_colored_polygon(hull, Color("#684d38"))
	draw_rect(Rect2(p + Vector2(-40, -9), Vector2(80, 26)), Color("#b7854f"))
	for x in [-30, 0, 30]: draw_rect(Rect2(p + Vector2(x, -9), Vector2(5, 26)), Color("#e1bc7c"))
	draw_rect(Rect2(p + Vector2(-39, -35), Vector2(78, 7)), Color("#d9b568"))
	for x in [-35, 32]: draw_rect(Rect2(p + Vector2(x, -28), Vector2(4, 29)), Color("#8d6a40"))
