extends Node2D
var id := ""
var title := ""
var kind := ""
var resource := ""
var marker := ""
var highlighted := false
var completed := false
var sprite: Texture2D
var clock := 0.0

func setup(definition: Array) -> void:
	id = definition[0]
	title = definition[1]
	position = definition[2]
	kind = definition[3]
	resource = definition[4]
	if kind == "npc": sprite = load("res://assets/%s.png" % resource)

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()

func _draw() -> void:
	if completed and id.begins_with("recycle_"): return
	if highlighted:
		draw_arc(Vector2.ZERO, 24, 0, TAU, 24, Color("#f8d67c"), 2)
	match kind:
		"npc":
			draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.3))
			draw_circle(Vector2.ZERO, 15, Color(0.05, 0.13, 0.1, 0.3))
			draw_set_transform(Vector2.ZERO)
			draw_texture_rect(sprite, Rect2(-18, -49, 36, 54), false)
		"light":
			draw_rect(Rect2(-3, -65, 6, 68), Color("#655e45"))
			draw_rect(Rect2(-10, -76, 20, 17), Color("#d6ba68"))
			draw_rect(Rect2(-7, -73, 14, 10), Color("#f1dd94"))
		"water":
			draw_rect(Rect2(-25, -9, 50, 16), Color("#7c8e7a"))
			draw_rect(Rect2(-16, -4, 32, 7), Color("#4b9dba"))
			draw_rect(Rect2(-3, -35, 6, 27), Color("#b6bdae"))
			draw_rect(Rect2(-3, -35, 19, 6), Color("#d4d5b8"))
		"notice":
			draw_rect(Rect2(-3, -24, 6, 28), Color("#835c36"))
			draw_rect(Rect2(-18, -46, 36, 29), Color("#f0dba6"))
			draw_string(ThemeDB.fallback_font, Vector2(-12, -25), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#835233"))
		"cargo":
			for p in [Vector2(-22, -22), Vector2(5, -22), Vector2(-8, -44)]:
				draw_rect(Rect2(p, Vector2(25, 25)), Color("#b78d52"))
				draw_rect(Rect2(p, Vector2(25, 25)), Color("#6c5133"), false, 2)
				draw_line(p + Vector2(3, 3), p + Vector2(22, 22), Color("#785b36"), 2)
		"paper":
			draw_rect(Rect2(-9, -18, 18, 22), Color("#eee1b6"))
			for y in [-12, -7, -2]: draw_rect(Rect2(-5, y, 10, 2), Color("#96866b"))
		"plastic":
			draw_rect(Rect2(-4, -22, 8, 6), Color("#d5d7aa"))
			draw_rect(Rect2(-7, -16, 14, 22), Color("#7bb6bd"))
			draw_rect(Rect2(-7, -9, 14, 8), Color("#dae0b7"))
		"organic":
			draw_colored_polygon(PackedVector2Array([Vector2(-12, 0), Vector2(-2, -14), Vector2(13, -5), Vector2(5, 6)]), Color("#e7bc52"))
		"bin":
			draw_rect(Rect2(-15, -28, 30, 32), Color(resource).darkened(0.15))
			draw_rect(Rect2(-18, -32, 36, 7), Color(resource))
			draw_rect(Rect2(-7, -18, 14, 12), Color("#edf0cd"))
			for x in [-9, 8]: draw_rect(Rect2(x, 3, 5, 5), Color("#344b3e"))
		"crossing":
			draw_rect(Rect2(-3, -27, 6, 30), Color("#9f8c60"))
			draw_rect(Rect2(-16, -51, 32, 29), Color("#347899"))
			draw_line(Vector2(-9, -29), Vector2(9, -45), Color("#f4edcf"), 3)
	if not marker.is_empty():
		var y := -74.0 + sin(clock * 3) * 3
		draw_circle(Vector2(0, y), 12, Color("#e9c66c") if marker == "!" else Color("#6ebcc0"))
		draw_string(ThemeDB.fallback_font, Vector2(-4, y + 6), marker, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#173c35"))
	if highlighted or kind == "bin":
		var font := ThemeDB.fallback_font
		var text := ("E · " if highlighted else "") + title
		var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		draw_rect(Rect2(-width / 2 - 6, 14, width + 12, 23), Color("#193e35"))
		draw_string(font, Vector2(-width / 2, 30), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#ffedbf"))
