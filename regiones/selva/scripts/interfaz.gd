extends CanvasLayer
signal action_requested(action: String)
var root: Control
var hud_title: Label
var hud_objective: Label
var wallet: Label
var hint: Label
var toast_label: Label
var dialog: PanelContainer
var dialog_title: Label
var dialog_body: RichTextLabel
var buttons: VBoxContainer
var modal := false
var allow_close := true
var actions: Array[String] = []
var toast_seconds := 0.0

func _ready() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme := Theme.new()
	theme.default_font_size = 16
	var panel_style := box(Color("#183e37"), Color("#628371"))
	theme.set_stylebox("panel", "PanelContainer", panel_style)
	for state_name in ["normal", "hover", "pressed", "focus"]:
		var color := Color("#28574b") if state_name == "normal" else Color("#477763")
		theme.set_stylebox(state_name, "Button", box(color, Color("#b3ac71")))
	theme.set_color("font_color", "Button", Color("#fff0c8"))
	theme.set_color("font_color", "Label", Color("#fff0c8"))
	theme.set_color("default_color", "RichTextLabel", Color("#f0e6cc"))
	root.theme = theme
	var hud := PanelContainer.new()
	hud.position = Vector2(16, 12)
	hud.size = Vector2(674, 103)
	root.add_child(hud)
	var hud_box := VBoxContainer.new()
	hud_box.add_theme_constant_override("separation", 5)
	hud.add_child(hud_box)
	hud_title = make_label("SELVA · NUEVA SEMILLA", 20)
	hud_box.add_child(hud_title)
	hud_objective = make_label("", 15)
	hud_objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hud_objective.custom_minimum_size = Vector2(638, 45)
	hud_box.add_child(hud_objective)
	var wallet_panel := PanelContainer.new()
	wallet_panel.position = Vector2(704, 12)
	wallet_panel.size = Vector2(240, 103)
	root.add_child(wallet_panel)
	wallet = make_label("", 16)
	wallet_panel.add_child(wallet)
	hint = make_label("WASD / flechas · E conversar · J diario · H pista · K guardar · M música · ESC pausa", 14)
	hint.position = Vector2(18, 510)
	root.add_child(hint)
	toast_label = make_label("", 16)
	toast_label.position = Vector2(22, 465)
	toast_label.add_theme_color_override("font_color", Color("#ffdf8a"))
	root.add_child(toast_label)
	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.color = Color(0.02, 0.08, 0.07, 0.65)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.visible = false
	root.add_child(shade)
	dialog = PanelContainer.new()
	dialog.position = Vector2(125, 125)
	dialog.size = Vector2(710, 375)
	dialog.visible = false
	root.add_child(dialog)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	dialog.add_child(content)
	dialog_title = make_label("", 21)
	dialog_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(dialog_title)
	dialog_body = RichTextLabel.new()
	dialog_body.bbcode_enabled = true
	dialog_body.custom_minimum_size = Vector2(674, 100)
	dialog_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialog_body.add_theme_font_size_override("normal_font_size", 17)
	content.add_child(dialog_body)
	buttons = VBoxContainer.new()
	buttons.add_theme_constant_override("separation", 7)
	content.add_child(buttons)
	var note := make_label("1–3 elegir · Ratón disponible · ENTER continuar · ESC cerrar", 12)
	content.add_child(note)

func box(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

func make_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	return label

func show_dialog(data: Dictionary, closable: bool = true) -> void:
	if data.is_empty():
		close_dialog()
		return
	modal = true
	allow_close = closable
	root.get_node("Shade").show()
	dialog.show()
	dialog_title.text = data.get("title", "Selva")
	dialog_body.text = data.get("body", "")
	dialog_body.scroll_to_line(0)
	actions.clear()
	for child in buttons.get_children():
		buttons.remove_child(child)
		child.queue_free()
	var options: Array = data.get("options", [])
	if options.is_empty(): options = [{"label": "Continuar", "action": "close"}]
	for i in range(options.size()):
		var entry: Dictionary = options[i]
		var action: String = entry["action"]
		actions.append(action)
		var button := Button.new()
		button.custom_minimum_size = Vector2(674, 43)
		button.focus_mode = Control.FOCUS_NONE
		var label := make_label("%d · %s" % [i + 1, entry["label"]], 15)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.position = Vector2(12, 3)
		label.size = Vector2(650, 37)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(label)
		button.pressed.connect(func() -> void: action_requested.emit(action))
		buttons.add_child(button)

func close_dialog() -> void:
	modal = false
	dialog.hide()
	root.get_node("Shade").hide()
	actions.clear()

func handle_key(code: Key) -> bool:
	if not modal: return false
	if code == KEY_ESCAPE:
		if allow_close: action_requested.emit("close")
		return true
	var index := -1
	if code in [KEY_1, KEY_KP_1]: index = 0
	if code in [KEY_2, KEY_KP_2]: index = 1
	if code in [KEY_3, KEY_KP_3]: index = 2
	if code == KEY_ENTER or code == KEY_KP_ENTER:
		if actions.size() == 1: index = 0
	if index >= 0 and index < actions.size(): action_requested.emit(actions[index])
	return true

func update_hud(state: RefCounted) -> void:
	var stage: int = state.mission()
	hud_title.text = "SELVA · " + ("Región completada" if stage == 5 else "%d/5 · %s" % [stage + 1, state.TITLES[stage]])
	hud_objective.text = state.objective()
	wallet.text = "%s\nMonedas: %d    Estrellas: %d\nJ · Diario y recompensas" % [str(state.data["hero"]).capitalize(), int(state.data["coins"]), int(state.data["stars"])]

func toast(text: String) -> void:
	toast_label.text = text
	toast_seconds = 4.0

func _process(delta: float) -> void:
	toast_seconds = maxf(0, toast_seconds - delta)
	toast_label.visible = toast_seconds > 0 and not modal
