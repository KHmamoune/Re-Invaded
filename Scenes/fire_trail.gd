extends Node2D

@onready var line2d: Line2D = $Line2D
var max_points: int = 10
var point_spacing: float = 1
var distance_accum: float = 0.0

func _ready():
	if line2d == null:
		print("Error: line2d is not assigned. Please assign it in the editor.")
		return
	line2d.clear_points()

func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()
	print("lining")
	
	if line2d.get_point_count() > 0:
		var last_point = line2d.get_point_position(line2d.get_point_count() - 1)
		var distance = mouse_position.distance_to(last_point)
		distance_accum += distance
	else:
		distance_accum = point_spacing
	
	if distance_accum >= point_spacing:
		line2d.add_point(mouse_position)
		distance_accum = 0.0
		
		if line2d.get_point_count() > max_points:
			line2d.remove_point(0)

func reset_trail():
	if line2d != null:
		line2d.clear_points()
		distance_accum = 0.0
