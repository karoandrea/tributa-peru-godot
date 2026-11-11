extends Node2D
## Entrada independiente. El equipo puede conectar esta señal sin tocar las misiones.
signal costa_requested(context: Dictionary)
const Progress = preload("res://regiones/selva/scripts/progreso.gd")
const Missions = preload("res://regiones/selva/scripts/misiones.gd")
const World = preload("res://regiones/selva/scripts/mundo.gd")
const Player = preload("res://regiones/selva/scripts/jugador.gd")
const Point = preload("res://regiones/selva/scripts/punto_interactivo.gd")
const Interface = preload("res://regiones/selva/scripts/interfaz.gd")
@export_file("*.tscn") var costa_scene: String = ""
@export var save_enabled := true
var state := Progress.new()
var missions: RefCounted
var world: Node2D
var player: CharacterBody2D
var ui: CanvasLayer
var points: Array[Node2D] = []
var nearest: Node2D
var sounds: Dictionary = {}
var music: AudioStreamPlayer
var crossing_active := false
var crossing_entered := false
var autosave_seconds := 0.0
var restored := false
var travelled := false

func _ready() -> void:
	if save_enabled:
		restored = state.load_game()
		if not restored and state.last_error.is_empty(): state.import_legacy_wallet()
	missions = Missions.new(state)
	world = World.new()
	add_child(world)
	var actors := Node2D.new()
	actors.y_sort_enabled = true
	add_child(actors)
	for definition in World.POINTS:
		var point := Point.new()
		point.setup(definition)
		actors.add_child(point)
		points.append(point)
	player = Player.new()
	actors.add_child(player)
	player.hero = str(state.data["hero"])
	var stored: Array = state.data["position"]
	var spawn := Vector2(float(stored[0]), float(stored[1]))
	player.position = spawn if spawn.is_finite() and world.is_walkable(spawn) else Vector2(260, 405)
	ui = Interface.new()
	add_child(ui)
	ui.action_requested.connect(_on_action)
	for sound_name in ["pickup", "success", "wrong"]:
		var audio := AudioStreamPlayer.new()
		audio.stream = load("res://assets/%s.wav" % sound_name)
		audio.volume_db = -12
		add_child(audio)
		sounds[sound_name] = audio
	music = AudioStreamPlayer.new()
	music.stream = load("res://assets/aventura_musica.wav")
	music.volume_db = -27
	music.finished.connect(music.play)
	add_child(music)
	if not DisplayServer.get_name() == "headless": music.play()
	ui.update_hud(state)
	if not state.last_error.is_empty():
		ui.show_dialog(missions.message("Partida conservada · guardado desactivado", state.last_error + " Puedes explorar, pero esta sesión no sobrescribirá ese archivo.", [missions.option("Elegir personaje y explorar", "select")]), false)
	elif restored:
		ui.show_dialog(missions.message("Bienvenido a Nueva Semilla", "Tu partida de Selva está lista. Tu grupo puede continuar explorando y completar sus objetivos pendientes.", [missions.option("Continuar con " + player.hero.capitalize(), "resume"), missions.option("Elegir personaje", "select")]), false)
	else: select_hero()
	refresh_markers()

func select_hero() -> void:
	ui.show_dialog(missions.message("Selva · La aventura de los tres amigos", "Una compra escolar abre una aventura de ciudadanía junto al río. Elige a tu protagonista; los tres comparten las mismas oportunidades.\n\nWASD / flechas: caminar · E / ENTER: interactuar · J: diario\nLas actividades marcadas con + son opcionales.", [missions.option("María", "hero:maria"), missions.option("Juan", "hero:juan"), missions.option("Luis", "hero:luis")]), false)

func _process(delta: float) -> void:
	if ui == null: return
	player.enabled = not ui.modal
	world.set_process(not ui.modal)
	nearest = null
	var distance := 76.0
	for point in points:
		point.highlighted = false
		if point.completed and point.id.begins_with("recycle_"): continue
		var current_distance: float = player.position.distance_to(point.position)
		if current_distance < distance:
			nearest = point
			distance = current_distance
	if nearest != null: nearest.highlighted = not ui.modal
	if not ui.modal:
		check_crossing()
		autosave_seconds += delta
		if autosave_seconds >= 15:
			autosave_seconds = 0
			persist()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	var code: Key = event.physical_keycode
	if code == KEY_M:
		music.stream_paused = not music.stream_paused
		return
	if ui.handle_key(code):
		get_viewport().set_input_as_handled()
		return
	match code:
		KEY_E, KEY_ENTER, KEY_KP_ENTER:
			if nearest != null:
				ui.show_dialog(missions.interact(nearest.id))
				persist()
				refresh_markers()
		KEY_J: show_journal()
		KEY_H:
			ui.show_dialog(missions.message("Pista · misión actual", state.objective() + "\n\n! indica un objetivo principal. + indica una actividad opcional. Consulta el diario con J para ubicar cada sector."))
		KEY_K:
			ui.toast("Partida de Selva guardada." if persist() else "No se pudo guardar. El progreso sigue en esta sesión.")
		KEY_ESCAPE:
			persist()
			ui.show_dialog(missions.message("Pausa · Selva", "El mapa y el semáforo están en pausa. Tu progreso se guarda al interactuar y cada 15 segundos de exploración.", [missions.option("Volver al mapa", "resume"), missions.option("Diario de misiones", "journal"), missions.option("Más opciones", "more")]))

func _on_action(action: String) -> void:
	if action == "close" or action == "resume":
		ui.close_dialog()
		return
	if action == "select":
		select_hero()
		return
	if action == "journal":
		show_journal()
		return
	if action == "more":
		ui.show_dialog(missions.message("Opciones", "Puedes cambiar de personaje conservando todos tus objetivos, o regresar al menú principal.", [missions.option("Elegir otro personaje", "select"), missions.option("Volver al menú principal", "main_menu"), missions.option("Volver a Selva", "resume")]))
		return
	if action == "main_menu":
		persist()
		get_tree().call_deferred("change_scene_to_file", "res://main.tscn")
		return
	if action.begins_with("hero:"):
		var hero := action.get_slice(":", 1)
		if not Progress.HEROES.has(hero): return
		state.data["hero"] = hero
		state.data["initialized"] = true
		player.hero = hero
		ui.close_dialog()
		persist()
		refresh_markers()
		return
	if action == "cross_start":
		if state.has_flag("crossing_done"): return
		if not Rect2(755, 515, 95, 85).has_point(player.position):
			ui.show_dialog(missions.message("Ubica el inicio", "Acércate al cartel del cruce desde el sur del paso peatonal y vuelve a iniciar."))
			return
		crossing_active = true
		crossing_entered = false
		ui.close_dialog()
		ui.toast("Espera PASA y cruza hacia el norte por las franjas.")
		return
	if action == "travel":
		request_costa()
		return
	var before: int = int(state.data["stars"])
	var response: Dictionary = missions.respond(action)
	ui.show_dialog(response)
	if int(state.data["stars"]) > before: sounds["success"].play()
	elif response.get("title", "") in ["Revisa la situación", "Piensa otra vez", "Separa por material"]: sounds["wrong"].play()
	else: sounds["pickup"].play()
	persist()
	refresh_markers()

func check_crossing() -> void:
	if not crossing_active: return
	var pos := player.position
	if pos.y >= 425 and pos.y <= 515:
		if pos.x < 765 or pos.x > 840 or not world.pedestrian_green:
			crossing_active = false
			ui.toast("Espera la señal y usa las franjas. Regresa al cartel para reintentar.")
			return
		crossing_entered = true
	if crossing_entered and pos.y < 420:
		crossing_active = false
		state.mark("crossing_done")
		state.reward("side_crossing", 15)
		persist()
		refresh_markers()
		sounds["success"].play()
		ui.show_dialog(missions.message("Cruce seguro · +15 monedas", "Esperaste la señal y cruzaste por el paso peatonal. Mira siempre a ambos lados; las señales no reemplazan la atención al entorno."))

func persist() -> bool:
	state.data["position"] = [player.position.x, player.position.y]
	if not save_enabled: return true
	if not bool(state.data["initialized"]): return true
	var result: bool = state.save_game()
	if not result: ui.toast("Guardado no disponible. El progreso permanece en esta sesión.")
	return result

func refresh_markers() -> void:
	var main_targets := [["ana", "docente", "beto", "rosa"], ["rosa"], ["elena", "service_light", "service_water", "service_school"], ["control", "estibador", "clue_cargo", "clue_manifest", "clue_route"], ["rosa"], ["capitana"]]
	for point in points:
		point.completed = state.has_flag(point.id)
		point.marker = "!" if main_targets[state.mission()].has(point.id) else ""
		if state.has_flag(point.id) and point.id.begins_with("clue_"): point.marker = ""
		if state.has_flag(point.id) and point.id.begins_with("service_"): point.marker = ""
		if point.id == "trivia" and not state.has_flag("trivia_done"): point.marker = "+"
		if point.id == "crossing" and not state.has_flag("crossing_done"): point.marker = "+"
		if point.id.begins_with("recycle_") and not point.completed: point.marker = "+"
		if point.id.begins_with("bin_") and not state.has_flag("sorted_" + point.id.trim_prefix("bin_")): point.marker = "+"
	ui.update_hud(state)

func show_journal() -> void:
	var text := "[b]Misiones principales[/b]\n"
	for i in range(5):
		var status := "COMPLETA" if state.mission() > i else ("ACTIVA" if state.mission() == i else "BLOQUEADA")
		text += "%d. %s · %s\n" % [i + 1, Progress.TITLES[i], status]
	text += "\n[b]Objetivo[/b]\n" + state.objective()
	text += "\n\n[b]Registro de objetivos[/b]\n"
	var labels := {"offer_informal": "Oferta de Beto comparada", "offer_formal": "Oferta de Rosa comparada", "sale_product": "Producto registrado", "sale_quantity": "Cantidad registrada", "sale_total": "Importe registrado", "service_light": "Alumbrado examinado", "service_water": "Agua examinada", "service_school": "Escuela examinada", "clue_cargo": "Etiquetas de carga anotadas", "clue_manifest": "Lista de carga revisada", "clue_route": "Ruta irregular anotada", "witness": "Testimonio de Diego", "reported": "Indicios comunicados al control", "paid": "Compra escolar pagada", "receipt_product": "Producto verificado", "receipt_quantity": "Cantidad verificada", "receipt_total": "Total verificado"}
	for key in labels:
		if state.has_flag(key): text += "✓ " + labels[key] + "\n"
	text += "\n[b]Opcionales · no bloquean Costa[/b]\n"
	for entry in [["recycle_done", "Limpieza: recoger papel (barrio), botella (mercado) y cáscara (sur). Separar junto a la plaza."], ["crossing_done", "Cruce seguro: cartel al sur del paso peatonal."], ["trivia_done", "Trivia: conversa con Tomi, al sur de la plaza."]]:
		text += ("✓ " if state.has_flag(entry[0]) else "○ ") + entry[1] + "\n"
	text += "Papel: %s · Plástico: %s · Orgánico: %s\n" % [recycle_status("paper"), recycle_status("plastic"), recycle_status("organic")]
	text += "\n[b]Orientación[/b]\nBarrio y escuela: norte. Mercado: suroeste. Plaza: centro-este. Control y embarcadero: sureste. El río tiene un puente al este.\n"
	text += "\n[b]Recompensas recibidas[/b]\n"
	for key in state.data["rewards"]:
		var r: Dictionary = state.data["rewards"][key]
		var reward_name: String = Progress.TITLES[int(str(key).trim_prefix("main_"))] if str(key).begins_with("main_") else {"side_recycle": "Limpieza", "side_crossing": "Cruce seguro", "side_trivia": "Trivia"}.get(key, str(key))
		text += "%s: +%d monedas, +%d estrellas\n" % [reward_name, int(r["coins"]), int(r["stars"])]
	text += "\n[b]Aprendizajes[/b]\nEl comprobante deja constancia de una operación. Los tributos contribuyen a financiar servicios y obras públicas. Los indicios de irregularidad deben comunicarse al personal competente. Compara ofertas y verifica tu comprobante.\n\nDemo educativa no oficial. No uses datos ni claves reales."
	ui.show_dialog(missions.message("Diario de Selva · desplaza para leer", text))

func recycle_status(kind: String) -> String:
	if state.has_flag("sorted_" + kind): return "depositado"
	return "en mochila" if state.has_flag("recycle_" + kind) else "por recoger"

func request_costa() -> void:
	if not state.data["costa_unlocked"]: return
	persist()
	var context: Dictionary = state.integration_context()
	if not travelled:
		travelled = true
		costa_requested.emit(context)
	if not costa_scene.is_empty() and ResourceLoader.exists(costa_scene):
		var result := get_tree().change_scene_to_file(costa_scene)
		if result == OK: return
	ui.show_dialog(missions.message("Costa · acceso habilitado", "Completaste Selva y habilitaste el viaje. Costa estará disponible próximamente. Mientras tanto, puedes continuar explorando y disfrutar las actividades del barrio."))

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and is_instance_valid(player): persist()

func _exit_tree() -> void:
	for audio in sounds.values(): audio.stop()
	if is_instance_valid(music): music.stop()
