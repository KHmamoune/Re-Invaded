extends Node


enum Type {NOT_ASSIGNED, BATTLE, RESOURCE, REST, MINIBOSS, BOSS}
const GAP_WIDTH = 120
const GAP_HEIGHT = 100
const ROOM_COUNT = 7
const FLOOR_COUNT = 10
const PATHS = 6
const BATTLE_ROOM_WEIGHT = 7.0
const REST_ROOM_WEIGHT = 5.0
const RESOURCE_ROOM_WEIGHT = 2.0
const MINIBOSS_ROOM_WEIGHT = 5.0


class Room:
	var type: Type
	var x_cord: int
	var y_cord: int
	var x_position: float
	var y_position: float
	var next_rooms: Array
	var availiable: bool = false
	
	func _init(x: int, y: int) -> void:
		type = Type.NOT_ASSIGNED
		x_cord = x
		y_cord = y
		x_position = GAP_WIDTH * (x_cord + 1)
		y_position = GAP_HEIGHT * (y_cord + 1)
	
	func output() -> void:
		print("floor: " + str(y_cord) + " room: " + str(x_cord) + " type: " + str(type))


class MapData:
	var map_data: Array[Array]
	var random_room_weights: Dictionary = {
		Type.BATTLE: 0.0,
		Type.REST: 0.0,
		Type.RESOURCE: 0.0,
		Type.MINIBOSS: 0.0
	}
	
	func output() -> void:
		var i: int = 0
		for layer in map_data:
			print("floor" + str(i))
			var used_rooms: Array = layer.filter(
				func(room: Room) -> bool: return room.next_rooms.size() > 0 or room.y_cord == FLOOR_COUNT - 1
			)
			for r: Room in used_rooms:
				r.output()
			i+= 1
	
	func generate_map() -> void:
		generate_data()
		var starting_rooms: Array = generate_starting_rooms()
		
		for j: int in starting_rooms:
			var curr_j: int = j
			for i in range(FLOOR_COUNT - 1):
				curr_j = setup_connection(i, curr_j)
		
		setup_boss_room()
		setup_random_room_weights()
		setup_rooms()
	
	func setup_connection(i: int, j: int) -> int:
		var next_room: Room
		var current_room: Room = map_data[i][j]
		
		while not next_room or would_cross_path(i, j, next_room):
			var rand_j: int = clampi(randi_range(j-1, j+1), 0, ROOM_COUNT - 1)
			next_room = map_data[i + 1][rand_j]
		
		current_room.next_rooms.append(next_room)
		return next_room.x_cord
	
	func would_cross_path(i: int, j: int, room: Room) -> bool:
		var left: Room
		var right: Room
		
		if j > 0:
			left = map_data[i][j-1]
			
		if j < ROOM_COUNT - 1:
			right = map_data[i][j+1]
		
		if right and room.x_cord > j:
			for next_room: Room in right.next_rooms:
				if next_room.x_cord < room.x_cord:
					return true
		
		if left and room.x_cord < j:
			for next_room: Room in left.next_rooms:
				if next_room.x_cord > room.x_cord:
					return true
		
		return false
	
	func generate_starting_rooms() -> Array:
		var y_cords: Array
		var unique_points: int = 0
		
		while unique_points < 2:
			unique_points = 0
			y_cords = []
			
			for i in PATHS:
				var starting_points: int = randi_range(0, ROOM_COUNT-1)
				if not y_cords.has(starting_points):
					unique_points += 1
				
				y_cords.append(starting_points)
		return y_cords
	
	func setup_boss_room() -> void:
		var middle: int = floori(ROOM_COUNT * 0.5)
		var boss_room: Room = map_data[FLOOR_COUNT - 1][middle]
		
		for j in ROOM_COUNT:
			var current_room: Room = map_data[FLOOR_COUNT - 2][j] as Room
			if current_room.next_rooms:
				current_room.next_rooms = []
				current_room.next_rooms.append(boss_room)
		
		boss_room.type = Type.BOSS
	
	func setup_random_room_weights() -> void:
		random_room_weights[Type.BATTLE] = BATTLE_ROOM_WEIGHT
		random_room_weights[Type.REST] = BATTLE_ROOM_WEIGHT + REST_ROOM_WEIGHT
		random_room_weights[Type.RESOURCE] = BATTLE_ROOM_WEIGHT + REST_ROOM_WEIGHT + RESOURCE_ROOM_WEIGHT
		random_room_weights[Type.MINIBOSS] = BATTLE_ROOM_WEIGHT + REST_ROOM_WEIGHT + RESOURCE_ROOM_WEIGHT + MINIBOSS_ROOM_WEIGHT
	
	func setup_rooms() -> void:
		for room: Room in map_data[0]:
			if room.next_rooms.size() > 0:
				room.type = Type.REST #change this to change starting rooms type
				
		for room: Room in map_data[FLOOR_COUNT - 2]:
			if room.next_rooms.size() > 0:
				room.type = Type.REST
		
		for current_floor in map_data:
			for room: Room in current_floor:
				for next_room: Room in room.next_rooms:
					if next_room.type == Type.NOT_ASSIGNED:
						set_rooms_randomly(next_room)
	
	func set_rooms_randomly(room_to_set: Room) -> void:
		var rest_bellow_4: bool = true
		var mini_bellow_4: bool = true
		var rest_on_7: bool = true
		var consecutive_rest: bool = true
		var consecutive_mini: bool = true
		
		var type_cand: Type
		
		while mini_bellow_4 or rest_bellow_4 or rest_on_7 or consecutive_rest or consecutive_mini:
			type_cand = get_random_room_type()
			
			var is_rest: bool = type_cand == Type.REST
			var is_mini: bool = type_cand == Type.MINIBOSS
			var has_rest_parent: bool = has_parent(room_to_set, Type.REST)
			var has_mini_parent: bool = has_parent(room_to_set, Type.MINIBOSS)
			
			mini_bellow_4 = is_mini and room_to_set.y_cord < 3
			rest_bellow_4 = is_rest and room_to_set.y_cord < 3
			rest_on_7 = is_rest and room_to_set.y_cord == 7
			consecutive_rest = is_rest and has_rest_parent
			consecutive_mini = is_mini and has_mini_parent
		
		room_to_set.type = type_cand
	
	func has_parent(room: Room, type: Type) -> bool:
		var parents: Array[Room] = []
		
		if room.x_cord > 0 and room.y_cord > 0:
			var parent_cand: Room = map_data[room.y_cord - 1][room.x_cord - 1]
			if parent_cand.next_rooms.has(room):
				parents.append(parent_cand)
		
		if room.y_cord > 0:
			var parent_cand: Room = map_data[room.y_cord - 1][room.x_cord]
			if parent_cand.next_rooms.has(room):
				parents.append(parent_cand)
		
		if room.x_cord < ROOM_COUNT - 1 and room.y_cord > 0:
			var parent_cand: Room = map_data[room.y_cord - 1][room.x_cord + 1]
			if parent_cand.next_rooms.has(room):
				parents.append(parent_cand)
		
		for parent in parents:
			if parent.type == type:
				return true
		return false
	
	func get_random_room_type() -> Type:
		var roll: float = randf_range(0.0, random_room_weights[Type.MINIBOSS])
		
		for t: Type in random_room_weights:
			if random_room_weights[t] > roll:
				return t
		
		return Type.BATTLE
	
	func generate_data() -> void:
		for i in range(FLOOR_COUNT):
			var floor_rooms: Array = []
			
			for j in range(ROOM_COUNT):
				floor_rooms.append(Room.new(j, i))
			map_data.append(floor_rooms)
