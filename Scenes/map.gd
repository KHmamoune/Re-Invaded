extends Control


signal selected(room: Map.Room)


var state: String = "hidden"
var selected_room: Map.Room
var current_cursor_cord: Array = []
var cursor: Node


func place_cursor() -> void:
	var new_cursor: Node = preload("res://Scenes/cursor.tscn").instantiate()
	for layer in gv.current_map.map_data:
		for room: Map.Room in layer:
			if room.availiable:
				new_cursor.position = Vector2(room.x_position, room.y_position)
				current_cursor_cord = [room.y_cord, room.x_cord]
				selected_room = room
				cursor = new_cursor
				$Rooms.add_child(cursor)
				return


func _process(delta: float) -> void:
	if state == "hidden":
		return
	
	var direction: Vector2 = Vector2(0.0, Input.get_axis("move_up", "move_down"))
	$Rooms.position -= direction * 400 * delta
	$Rooms.position.y = clamp($Rooms.position.y, -550, 0)
	
	if Input.is_action_just_pressed("move_right"):
		move_cursor("right")
	
	if Input.is_action_just_pressed("move_left"):
		move_cursor("left")
	
	if Input.is_action_just_pressed("shoot1"):
		select_room()


func select_room() -> void:
	emit_signal("selected", selected_room)
	$Rooms.remove_child(cursor)
	place_cursor()


func move_cursor(direc: String) -> void:
	if direc == "right":
		var i: int = current_cursor_cord[1] + 1
		var map: Map.MapData = gv.current_map
		while i < len(map.map_data[current_cursor_cord[0]]):
			var current_room: Map.Room = map.map_data[current_cursor_cord[0]][i]
			if current_room.availiable:
				var t: Tween = create_tween()
				t.parallel().tween_property(cursor, "position", Vector2(current_room.x_position, current_room.y_position), 0.2)
				t.parallel().tween_property(cursor, "rotation_degrees", cursor.rotation_degrees + 90, 0.2)
				t.tween_callback(reset_rotation)
				current_cursor_cord = [current_room.y_cord, current_room.x_cord]
				selected_room = current_room
				break
			i += 1
	elif direc == "left":
		var i: int = current_cursor_cord[1] - 1
		var map: Map.MapData = gv.current_map
		while i > -1:
			var current_room: Map.Room = map.map_data[current_cursor_cord[0]][i]
			if current_room.availiable:
				var t: Tween = create_tween()
				t.parallel().tween_property(cursor, "position", Vector2(current_room.x_position, current_room.y_position), 0.2)
				t.parallel().tween_property(cursor, "rotation_degrees", cursor.rotation_degrees - 90, 0.2)
				t.tween_callback(reset_rotation)
				current_cursor_cord = [current_room.y_cord, current_room.x_cord]
				selected_room = current_room
				break
			i -= 1


func reset_rotation() -> void:
	cursor.rotation = 0
