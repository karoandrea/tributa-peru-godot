extends CanvasLayer
## Único enlace con el prototipo: un botón visible exclusivamente en su portada.
var button: Button

func _ready() -> void:
	layer = 2
	button = Button.new()
	button.position = Vector2(709, 495)
	button.size = Vector2(235, 36)
	button.text = "Explorar nueva Selva"
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 16)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#245749")
	style.border_color = Color("#e2c47a")
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_color_override("font_color", Color("#fff0c8"))
	add_child(button)
	button.pressed.connect(open_selva)
	button.visible = get_parent().get("mode") == "title"

func _process(_delta: float) -> void:
	button.visible = get_parent().get("mode") == "title"

func open_selva() -> void:
	if get_parent().get("mode") != "title": return
	get_tree().call_deferred("change_scene_to_file", "res://regiones/selva/escenas/selva.tscn")
