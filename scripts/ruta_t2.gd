extends Node
## Guardado independiente de la Tarea 2 para no sobrescribir el progreso del Nivel 1.
const PATH := "user://tributa_tarea2.json"
const RutaT2 := "user://tributa_tarea2_clon.json"
var personaje: String = "juan"
var monedas: int = 0
var estrellas: int = 0
var fondo: int = 0
var camino_completado: bool = false
var bodega_completada: bool = false
var puntuacion_comprobantes: int = 0

func guardar() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({
			"personaje": personaje, "monedas": monedas,
			"estrellas": estrellas, "fondo": fondo,
			"camino_completado": camino_completado,
			"bodega_completada": bodega_completada,
			"puntuacion_comprobantes": puntuacion_comprobantes
		}))
		f.close()

func cargar() -> void:
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	if not data is Dictionary:
		return
	personaje = str(data.get("personaje", "juan"))
	if not ["maria", "juan", "luis"].has(personaje):
		personaje = "juan"
	monedas = int(data.get("monedas", 0))
	estrellas = int(data.get("estrellas", 0))
	fondo = int(data.get("fondo", 0))
	camino_completado = bool(data.get("camino_completado", false))
	bodega_completada = bool(data.get("bodega_completada", false))
	puntuacion_comprobantes = int(data.get("puntuacion_comprobantes", 0))

func _ready() -> void:
	cargar()
