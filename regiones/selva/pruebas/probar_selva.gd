extends SceneTree
## Ejecutar con Godot --headless --path . --script res://regiones/selva/pruebas/probar_selva.gd
## Todas las escrituras de esta prueba quedan en res://.godot/selva_validation/.
const Progress = preload("res://regiones/selva/scripts/progreso.gd")
const Missions = preload("res://regiones/selva/scripts/misiones.gd")
const World = preload("res://regiones/selva/scripts/mundo.gd")
var failed := 0
var checked := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checked += 1
	if not condition:
		failed += 1
		push_error("FALLO: " + description)

func answer(flow: RefCounted, key: String, correct: int) -> void:
	flow.respond("answer:%s:%d" % [key, correct])

func run() -> void:
	var state := Progress.new()
	var flow := Missions.new(state)
	check(not state.complete(4), "No se puede terminar una misión futura")
	flow.respond("buy")
	check(not state.has_flag("paid"), "No se puede comprar antes de la misión 5")
	flow.interact("clue_cargo")
	check(not state.has_flag("clue_cargo"), "La investigación no avanza antes de tiempo")
	flow.interact("rosa")
	check(not state.has_flag("offer_formal"), "Se necesita recibir el encargo")
	flow.respond("start")
	flow.interact("beto")
	flow.respond("choose_formal")
	check(state.mission() == 0, "Comparar ambos comercios es obligatorio")
	flow.interact("rosa")
	flow.respond("choose_informal")
	check(state.mission() == 0 and int(state.data["coins"]) == 100, "Decisión incorrecta tiene retroalimentación sin castigo")
	flow.respond("choose_formal")
	check(state.mission() == 1 and int(state.data["coins"]) == 125, "Misión 1: comparación y reserva completables")
	flow.respond("choose_formal")
	check(int(state.data["coins"]) == 125, "Misión 1 no duplica recompensa")
	answer(flow, "sale_total", 2)
	check(not state.has_flag("sale_total"), "El registro no permite saltarse producto y cantidad")
	answer(flow, "sale_product", 1)
	check(not state.has_flag("sale_product"), "Respuesta incorrecta no avanza")
	answer(flow, "sale_product", 0)
	answer(flow, "sale_quantity", 1)
	answer(flow, "sale_total", 2)
	check(state.mission() == 2, "Misión 2: registro interactivo completo")
	answer(flow, "public_answer", 0)
	check(state.mission() == 2, "Hay que explorar los servicios antes de responder")
	for id in ["service_light", "service_water", "service_school"]: flow.interact(id)
	answer(flow, "public_answer", 0)
	check(state.mission() == 3, "Misión 3: necesidades y presupuesto completables")
	answer(flow, "reported", 1)
	check(state.mission() == 3, "No se puede informar sin reunir indicios")
	for id in ["clue_cargo", "clue_manifest", "clue_route"]: flow.interact(id)
	answer(flow, "reported", 1)
	check(state.mission() == 3, "El testimonio también es necesario")
	flow.interact("estibador")
	answer(flow, "reported", 0)
	check(state.mission() == 3, "Acusar sin comunicar al responsable no completa la investigación")
	answer(flow, "reported", 1)
	check(state.mission() == 4, "Misión 4: investigación y comunicación completables")
	answer(flow, "receipt_product", 0)
	check(not state.has_flag("receipt_product"), "Hay que comprar antes de revisar la boleta")
	flow.respond("buy")
	var after_purchase := int(state.data["coins"])
	flow.respond("buy")
	check(int(state.data["coins"]) == after_purchase, "La compra se cobra una sola vez")
	answer(flow, "receipt_product", 0)
	answer(flow, "receipt_quantity", 1)
	answer(flow, "receipt_total", 2)
	check(state.mission() == 5 and state.data["selva_completed"] and state.data["costa_unlocked"], "Misión 5 completa Selva y desbloquea Costa")
	check(int(state.data["coins"]) == 213 and int(state.data["stars"]) == 5, "Balance principal: 100 + 125 − 12 y cinco estrellas")
	check(not state.has_flag("trivia_done") and not state.has_flag("recycle_done") and not state.has_flag("crossing_done"), "Costa no depende de actividades opcionales")
	var before := int(state.data["coins"])
	for i in range(5): state.complete(i)
	answer(flow, "receipt_total", 2)
	check(int(state.data["coins"]) == before, "Repetir finalizaciones no vuelve a premiar")
	flow.respond("sort:bin_paper:paper")
	check(not state.has_flag("sorted_paper"), "No se puede depositar un residuo no recogido")
	flow.interact("recycle_paper")
	flow.respond("sort:bin_plastic:paper")
	check(not state.has_flag("sorted_paper"), "El contenedor debe corresponder al residuo")
	for kind in ["paper", "plastic", "organic"]:
		flow.interact("recycle_" + kind)
		flow.respond("sort:bin_%s:%s" % [kind, kind])
	check(state.has_flag("recycle_done") and int(state.data["coins"]) == before + 15, "Recoger y separar tres residuos premia una vez")
	flow.respond("sort:bin_organic:organic")
	check(int(state.data["coins"]) == before + 15, "Limpieza no duplica premios")
	flow.respond("trivia:0:2")
	check(int(state.data["flags"].get("trivia_index", 0)) == 0, "Trivia incorrecta permite reintentar")
	for i in range(5): flow.respond("trivia:%d:%d" % [i, Missions.TRIVIA[i][2]])
	check(state.has_flag("trivia_done") and int(state.data["coins"]) == before + 30, "Cinco preguntas de trivia completables")
	flow.respond("trivia:4:1")
	check(int(state.data["coins"]) == before + 30, "Trivia no duplica premios")
	# Guardado lateral en caché local, sin leer ni sobrescribir partidas personales.
	DirAccess.make_dir_recursive_absolute("res://.godot/selva_validation")
	state.path = "res://.godot/selva_validation/test_save.json"
	state.data["hero"] = "luis"
	state.data["position"] = [630.0, 845.0]
	check(state.save_game(), "Escritura de partida lateral")
	check(state.save_game(), "Actualización atómica de partida existente")
	var loaded := Progress.new()
	loaded.path = state.path
	check(loaded.load_game(), "Lectura de partida lateral")
	check(equivalent(loaded.data, state.data), "Recuperación íntegra de personaje, cartera, objetivos, opcionales y salida")
	check(loaded.path != Progress.LEGACY_PATH, "La ruta de Selva es distinta de la partida original")
	var bad_path := "res://.godot/selva_validation/invalid.json"
	var bad_file := FileAccess.open(bad_path, FileAccess.WRITE)
	bad_file.store_string("{invalido")
	bad_file.close()
	var damaged := Progress.new()
	damaged.path = bad_path
	check(not damaged.load_game() and not damaged.save_game(), "Partida dañada se conserva sin sobrescribir")
	# Cargar la escena real, su cámara, interfaz, físicas y los tres personajes.
	var scene = load("res://regiones/selva/escenas/selva.tscn").instantiate()
	scene.save_enabled = false
	root.add_child(scene)
	await process_frame
	await physics_frame
	check(scene.player != null and scene.points.size() == 22, "Escena real con personaje y todos los puntos")
	check(scene.player.get_child(1) is Camera2D and scene.player.get_child(1).enabled, "Cámara activa en el personaje")
	for hero in Progress.HEROES:
		scene._on_action("hero:" + hero)
		check(scene.player.hero == hero and scene.player.textures[hero] != null, "Sprite existente de " + hero)
	# UI en el tamaño real del proyecto.
	scene.ui.show_dialog(scene.missions.interact("ana"))
	await process_frame
	check(scene.ui.modal and scene.ui.buttons.get_child_count() > 0, "NPC abre diálogo y opciones")
	check(scene.ui.dialog.size.x <= 720 and scene.ui.dialog.position.y + scene.ui.dialog.size.y <= 540, "Diálogo cabe en 960 × 540")
	scene.ui.handle_key(KEY_ESCAPE)
	check(not scene.ui.modal, "ESC cierra diálogos")
	scene.show_journal()
	check(scene.ui.modal and scene.ui.dialog_body.text.contains("Opcionales"), "Diario muestra misiones y actividades")
	scene.ui.close_dialog()
	# Comprobar movimiento real mediante el evento de teclado que consulta el jugador.
	scene.player.position = Vector2(600, 1020)
	var key := InputEventKey.new()
	key.physical_keycode = KEY_D
	key.keycode = KEY_D
	key.pressed = true
	Input.parse_input_event(key)
	for i in range(12): await physics_frame
	key.pressed = false
	Input.parse_input_event(key)
	check(scene.player.position.x > 610, "WASD mueve el CharacterBody2D")
	var camera: Camera2D = scene.player.get_child(1)
	camera.reset_smoothing()
	camera.force_update_scroll()
	var previous_camera_x := camera.get_screen_center_position().x
	scene.player.position = Vector2(1200, 1020)
	camera.reset_smoothing()
	camera.force_update_scroll()
	check(camera.get_screen_center_position().x > previous_camera_x + 300, "La cámara sigue el desplazamiento real y respeta sus límites")
	# Las colisiones no dependen del dibujo: probar el cuerpo real contra una pared.
	scene.player.enabled = false
	scene.player.position = Vector2(250, 355)
	await physics_frame
	var hit = scene.player.move_and_collide(Vector2(0, -70))
	check(hit != null and scene.player.position.y >= 338, "La construcción bloquea físicamente al jugador")
	check(not scene.world.is_walkable(Vector2(1700, 400)), "Agua bloqueada")
	check(scene.world.is_walkable(Vector2(1700, 650)), "Puente transitable")
	check(scene.world.is_walkable(Vector2(1720, 1000)), "Embarcadero transitable")
	check(not scene.world.is_walkable(Vector2(-5, 500)), "Límite del escenario bloqueado")
	# BFS: todos los NPC y objetos tienen una aproximación por suelo transitable.
	var reachable := flood(scene.world, Vector2(260, 405))
	for point in scene.points:
		var accessible := false
		for cell in reachable:
			var pos: Vector2 = Vector2(cell) * 16 + Vector2(8, 8)
			if pos.distance_to(point.position) < 65:
				accessible = true
				break
		check(accessible, "Punto accesible desde inicio: " + point.id)
	# Cruce: rojo falla, verde requiere llegar efectivamente al otro lado.
	scene.player.position = Vector2(800, 550)
	scene._on_action("cross_start")
	check(scene.crossing_active, "Cruce inicia desde el cartel")
	scene.world.pedestrian_green = false
	scene.player.position = Vector2(800, 480)
	scene.check_crossing()
	check(not scene.crossing_active and not scene.state.has_flag("crossing_done"), "Cruzar en rojo no premia")
	scene.player.position = Vector2(800, 550)
	scene._on_action("cross_start")
	scene.world.pedestrian_green = true
	scene.player.position = Vector2(800, 470)
	scene.check_crossing()
	scene.player.position = Vector2(800, 410)
	scene.check_crossing()
	check(scene.state.has_flag("crossing_done") and int(scene.state.data["coins"]) == 115, "Cruce seguro entrega 15 monedas")
	scene._on_action("cross_start")
	check(not scene.crossing_active and int(scene.state.data["coins"]) == 115, "Cruce no duplica premios")
	# Integración no intenta abrir rutas inexistentes.
	scene.state = state
	scene.missions = flow
	var emitted: Array = []
	scene.costa_requested.connect(func(context: Dictionary) -> void: emitted.append(context))
	scene.request_costa()
	scene.request_costa()
	check(emitted.size() == 1 and emitted[0]["costa_unlocked"], "Salida emite contexto una vez sin cargar escenas inexistentes")
	check(scene.is_inside_tree(), "Selva sigue disponible después de consultar Costa")
	# Recorrido adicional por el controlador real, tecla E y botones de su interfaz.
	scene.state = Progress.new()
	scene.missions = Missions.new(scene.state)
	interact_in_scene(scene, "ana")
	choose_in_scene(scene, 0)
	interact_in_scene(scene, "beto")
	interact_in_scene(scene, "rosa")
	choose_in_scene(scene, 0)
	check(scene.state.mission() == 1, "Interfaz real: completar comparación")
	interact_in_scene(scene, "rosa")
	choose_in_scene(scene, 0) # producto
	choose_in_scene(scene, 0) # continuar
	choose_in_scene(scene, 1) # cantidad
	choose_in_scene(scene, 0) # continuar
	choose_in_scene(scene, 2) # total
	check(scene.state.mission() == 2, "Interfaz real: completar venta registrada")
	for id in ["service_light", "service_water", "service_school"]: interact_in_scene(scene, id)
	interact_in_scene(scene, "elena")
	choose_in_scene(scene, 0)
	check(scene.state.mission() == 3, "Interfaz real: completar servicios públicos")
	for id in ["clue_cargo", "clue_manifest", "clue_route", "estibador"]: interact_in_scene(scene, id)
	interact_in_scene(scene, "control")
	choose_in_scene(scene, 1)
	check(scene.state.mission() == 4, "Interfaz real: completar investigación")
	interact_in_scene(scene, "rosa")
	choose_in_scene(scene, 0) # pagar
	choose_in_scene(scene, 0) # verificar
	choose_in_scene(scene, 0) # producto
	choose_in_scene(scene, 0) # continuar
	choose_in_scene(scene, 1) # cantidad
	choose_in_scene(scene, 0) # continuar
	choose_in_scene(scene, 2) # importe
	check(scene.state.mission() == 5 and scene.ui.dialog_title.text.contains("completada"), "Interfaz real: pantalla final y desbloqueo")
	check(scene.ui.hud_title.text.contains("completada"), "HUD actualiza el estado final")
	# El prototipo sigue cargando y no depende del módulo nuevo.
	var original: PackedScene = load("res://main.tscn")
	check(original != null and original.can_instantiate(), "Escena original sigue cargando")
	var launcher = original.instantiate()
	check(launcher.get_node_or_null("AccesoSelva") != null, "Integración del menú es un nodo adicional aislado")
	launcher.free()
	for audio in scene.sounds.values(): audio.stop()
	await create_timer(0.2).timeout
	scene.queue_free()
	await process_frame
	print("SELVA: %d verificaciones; %d fallos." % [checked, failed])
	call_deferred("quit", 0 if failed == 0 else 1)

func interact_in_scene(scene: Node2D, id: String) -> void:
	scene.ui.close_dialog()
	for point in scene.points:
		if point.id == id:
			scene.nearest = point
			scene.player.position = point.position + Vector2(0, 24)
			break
	var key := InputEventKey.new()
	key.physical_keycode = KEY_E
	key.keycode = KEY_E
	key.pressed = true
	scene._unhandled_input(key)
	check(scene.ui.modal, "E abre la interacción de " + id)

func choose_in_scene(scene: Node2D, index: int) -> void:
	check(index < scene.ui.buttons.get_child_count(), "La opción solicitada existe en el diálogo")
	if index < scene.ui.buttons.get_child_count(): scene.ui.buttons.get_child(index).pressed.emit()

func equivalent(a: Variant, b: Variant) -> bool:
	# JSON representa los números como float; comparar valores, no tipos enteros/flotantes.
	if a is Dictionary and b is Dictionary:
		if a.size() != b.size(): return false
		for key in a:
			if not b.has(key) or not equivalent(a[key], b[key]): return false
		return true
	if a is Array and b is Array:
		if a.size() != b.size(): return false
		for i in range(a.size()):
			if not equivalent(a[i], b[i]): return false
		return true
	return a == b

func flood(world: Node2D, start: Vector2) -> Dictionary:
	var initial := Vector2i(start / 16)
	var visited := {initial: true}
	var queue: Array[Vector2i] = [initial]
	var index := 0
	while index < queue.size():
		var cell := queue[index]
		index += 1
		for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = cell + offset
			if visited.has(next): continue
			if world.is_walkable(Vector2(next) * 16 + Vector2(8, 8), 12):
				visited[next] = true
				queue.append(next)
	return visited
