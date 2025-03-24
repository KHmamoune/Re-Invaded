extends Area2D


signal selected(room: Map.Room)

const ICONS = {
	Map.Type.NOT_ASSIGNED: [null, Vector2.ZERO],
	Map.Type.BATTLE: [preload("res://Images/Icons/battle.png"), Vector2(3, 3)],
	Map.Type.REST: [preload("res://Images/Icons/rest.png"), Vector2(3, 3)],
	Map.Type.MINIBOSS: [preload("res://Images/Icons/miniboss.png"), Vector2(3, 3)],
	Map.Type.RESOURCE: [preload("res://Images/Icons/resources.png"), Vector2(3, 3)],
	Map.Type.BOSS: [preload("res://Images/Icons/security_system.png"), Vector2(4, 4)]
}

var availiable: bool = false
var room: Map.Room


func set_availiable(val: bool) -> void:
	availiable = val
	room.availiable = val
	
	if availiable:
		$AnimationPlayer.play("Pulse")
	else:
		$AnimationPlayer.play("RESET")


func set_room(val: Map.Room) -> void:
	room = val
	
	if room.type == Map.Type.BOSS:
		room.y_position += 100
	
	position = Vector2(room.x_position, room.y_position)
	$Sprite2D.texture = ICONS[room.type][0]
	$Sprite2D.scale = ICONS[room.type][1]
