extends Area2D
class_name Projectile


var angle_tweens: Array = []
var speed_tweens: Array = []
var position_tweens: Array = []
var size_tweens: Array = []
var target: Node = null
var attack: Array
var is_dead: bool = false
var on_hit_effects: Array = []
var follow_player: bool
var piercing: bool = false
var speed: float
var move_range: float
var damage: int
var traveled: float
var bouncy: bool = false
var sprite_size: Vector2
var hitbox_size: Vector2
var anm_speed: float
var frames: int
var look: String
var sprite: Texture
var wait_time: float = 0
var marker_type: String = ""


func shoot(bullet: Node, _seconds: float, sfx: AudioStream = Audio.sfx_shoot) -> void:
	bullet.set_collision_layer_value(3, get_collision_layer_value(3))
	bullet.set_collision_layer_value(5, get_collision_layer_value(5))
	Audio.play_sfx(sfx)
	if bullet.follow_player:
		bullet.position = Vector2.ZERO
		if !bullet.type == "sheild":
			bullet.z_index = -1
		add_child(bullet)
	else:
		get_parent().add_child(bullet)


func aim() -> float:
	if target != null:
		return rad_to_deg(global_position.angle_to_point(target.global_position) + deg_to_rad(90))
	else:
		return 0.0


func get_closest() -> Node:
	var list: Array = get_tree().get_nodes_in_group("enemy")
	if len(list) > 0:
		var nearest: Node = list[0]
		
		for en: Node in list:
			if nearest.global_position.distance_to(global_position) > en.global_position.distance_to(global_position):
				nearest = en
		return nearest
	return null


func execute_angle_tweens() -> void:
	for tween: Dictionary in angle_tweens:
		await get_tree().create_timer(tween["delay"]).timeout
		var t: Tween = create_tween().set_loops(1)
		
		if typeof(tween["value"]) == typeof(""):
			if tween["value"] == "enemy":
				target = get_closest()
				t.tween_property(self, "rotation_degrees", aim(), tween["dur"])
		else:
			t.tween_property(self, "rotation_degrees", tween["value"], tween["dur"])


func execute_speed_tweens() -> void:
	var t: Tween = create_tween().set_loops(1)
	for tween:Dictionary in speed_tweens:
		t.tween_interval(tween["delay"])
		t.tween_property(self, "speed", tween["value"], tween["dur"])


func execute_size_tweens() -> void:
	var t: Tween = create_tween().set_loops(1)
	for tween: Dictionary in size_tweens:
		t.tween_interval(tween["delay"])
		t.tween_property(self, "scale", tween["value"], tween["dur"])
		

func execute_position_tweens() -> void:
	for tween: Dictionary in position_tweens:
		var t: Tween = create_tween().set_loops(1)
		t.tween_interval(tween["delay"])
		if tween["value"].x != 0 and tween["value"].y != 0: 
			t.tween_property(self, "position", position + tween["value"], tween["dur"]).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		elif tween["value"].x != 0:
			t.tween_property(self, "position:x", position.x + tween["value"].x, tween["dur"]).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		elif tween["value"].y != 0:
			t.tween_property(self, "position:y", position.y + tween["value"].y, tween["dur"]).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await t.finished
