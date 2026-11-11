extends RefCounted
## Partida lateral: nunca escribe en la partida del prototipo.
## Los nombres y unidades de la cartera coinciden con scripts/main.gd.
const SAVE_PATH := "user://tributa_peru_selva_v1.json"
const LEGACY_PATH := "user://tributa_peru_tres_amigos_partida.json"
const HEROES := ["maria", "juan", "luis"]
const TITLES := ["La compra para el colegio", "Una venta registrada", "¿A dónde van los impuestos?", "Mercancía sospechosa", "La decisión correcta"]
var path: String = SAVE_PATH
var data: Dictionary = {}
var last_error := ""

func _init() -> void:
	data = defaults()

func defaults() -> Dictionary:
	return {"version": 1, "hero": "juan", "coins": 100, "stars": 0,
		"contribution": 0, "reputation": 100, "mission": 0, "flags": {},
		"rewards": {}, "selva_completed": false, "costa_unlocked": false,
		"position": [260.0, 405.0], "initialized": false}

func has_flag(key: String) -> bool:
	return bool(data["flags"].get(key, false))

func mark(key: String) -> void:
	data["flags"][key] = true

func mission() -> int:
	return int(data["mission"])

func reward(key: String, amount: int, star_count: int = 0) -> bool:
	if data["rewards"].has(key):
		return false
	data["rewards"][key] = {"coins": amount, "stars": star_count}
	data["coins"] = int(data["coins"]) + amount
	data["stars"] = int(data["stars"]) + star_count
	data["reputation"] = int(data["reputation"]) + 2
	return true

func complete(index: int) -> bool:
	if mission() != index:
		return false
	var requirements := [
		["started", "offer_informal", "offer_formal", "choice_receipt"],
		["sale_product", "sale_quantity", "sale_total"],
		["service_light", "service_water", "service_school", "public_answer"],
		["clue_cargo", "clue_manifest", "clue_route", "witness", "reported"],
		["paid", "receipt_product", "receipt_quantity", "receipt_total"]]
	for key in requirements[index]:
		if not has_flag(key):
			return false
	reward("main_%d" % index, 25, 1)
	data["mission"] = index + 1
	if mission() == 5:
		data["selva_completed"] = true
		data["costa_unlocked"] = true
	return true

func objective() -> String:
	match mission():
		0:
			if not has_flag("started"): return "Habla con Ana, tu vecina, o con la docente para recibir el encargo."
			if not has_flag("offer_informal"): return "Visita a Beto, en el puesto de ofertas del mercado."
			if not has_flag("offer_formal"): return "Compara la oferta de Rosa, en la librería del mercado."
			return "Elige una oferta con Rosa después de comparar ambos comercios."
		1: return "Ayuda a Rosa a registrar producto, cantidad e importe de una venta."
		2:
			var count := int(has_flag("service_light")) + int(has_flag("service_water")) + int(has_flag("service_school"))
			return "Examina luz, agua y escuela (%d/3); conversa con Elena en la plaza." % count
		3:
			var count := int(has_flag("clue_cargo")) + int(has_flag("clue_manifest")) + int(has_flag("clue_route"))
			return "Investiga el embarcadero (%d/3 indicios), escucha al estibador e informa al control." % count
		4:
			if has_flag("paid"): return "Vuelve con Rosa y verifica producto, cantidad e importe en tu boleta."
			return "Regresa a la librería de Rosa y realiza la compra responsable."
	return "Selva completada. Habla con la capitana en el embarcadero."

func load_game() -> bool:
	if not FileAccess.file_exists(path): return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		last_error = "No se pudo leer la partida de Selva."
		return false
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	var parsed: Variant = parser.data if parse_error == OK else null
	if not parsed is Dictionary or int(parsed.get("version", 0)) != 1:
		last_error = "La partida de Selva no tiene un formato compatible. Se conservará sin sobrescribir."
		return false
	if not parsed.get("flags") is Dictionary or not parsed.get("rewards") is Dictionary:
		last_error = "La partida contiene datos inválidos; se conservará sin sobrescribir."
		return false
	data = defaults()
	for key in data.keys():
		if parsed.has(key): data[key] = parsed[key]
	data["mission"] = clampi(int(data["mission"]), 0, 5)
	if not HEROES.has(data["hero"]): data["hero"] = "juan"
	for key in ["coins", "stars", "contribution", "reputation"]:
		data[key] = maxi(0, int(data[key]))
	if not data["position"] is Array or data["position"].size() != 2:
		data["position"] = [260.0, 405.0]
	data["selva_completed"] = mission() == 5
	data["costa_unlocked"] = mission() == 5
	return true

func import_legacy_wallet() -> void:
	# Solo lectura, una vez al crear la partida lateral. Nunca altera el archivo original.
	if not FileAccess.file_exists(LEGACY_PATH): return
	var file := FileAccess.open(LEGACY_PATH, FileAccess.READ)
	if file == null: return
	var old: Variant = JSON.parse_string(file.get_as_text())
	if not old is Dictionary: return
	if HEROES.has(old.get("hero", "")): data["hero"] = old["hero"]
	for key in ["coins", "stars", "contribution", "reputation"]:
		if old.get(key) is float or old.get(key) is int:
			data[key] = maxi(0, int(old[key]))

func save_game() -> bool:
	if not last_error.is_empty(): return false
	# Escribir primero un temporal protege la última partida ante un fallo de escritura.
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK: return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(path)) == OK

func integration_context() -> Dictionary:
	return {"source_region": "selva", "hero": data["hero"], "coins": data["coins"],
		"stars": data["stars"], "contribution": data["contribution"],
		"reputation": data["reputation"], "selva_completed": data["selva_completed"],
		"costa_unlocked": data["costa_unlocked"]}
