extends CanvasLayer

signal DRAWING_FINISHED(strokes)

var is_drawing := false
var strokes = []
var current_stroke = []

@onready var stroke_container = $DrawingSurface/StrokeContainer


func _ready():
	print("DRAW UI READY")
	layer = 100

	if $DrawingSurface:
		$DrawingSurface.set_anchors_preset(Control.PRESET_FULL_RECT)
		print("DRAWING SURFACE FULL RECT SET")
	else:
		print("ERROR: DrawingSurface missing")


func _input(event):
	if not is_drawing:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_stroke(event.position)
			else:
				end_stroke()

	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			add_point(event.position)


func start_stroke(pos):
	current_stroke = [pos]
	print("STROKE START")


func add_point(pos):
	current_stroke.append(pos)
	draw_point(pos)


func end_stroke():
	print("STROKE END")

	if current_stroke.size() > 2:
		strokes.append(current_stroke)

	current_stroke = []


func draw_point(pos):
	var line = Line2D.new()
	line.width = 4
	line.default_color = Color.WHITE
	line.points = current_stroke.duplicate()
	stroke_container.add_child(line)


func start_drawing():
	print("DRAW UI SHOWN")
	strokes.clear()
	current_stroke.clear()
	is_drawing = true
	show()
	visible = true


func finish_drawing():
	print("DRAW UI FINISH CALLED")
	is_drawing = false
	hide()
	emit_signal("DRAWING_FINISHED", strokes)
