extends Line2D


@export var max_length : int
var queue: Array


func _process(_delta: float) -> void:
	clear_points()
	
	if not get_parent().dashing:
		queue.clear()
	
	if get_parent().dashing:
		var pos: Vector2 = get_parent().position
		queue.push_front(pos)
		
		if queue.size() > max_length:
			queue.pop_back()
		
		for point: Vector2 in queue:
			add_point(point)
