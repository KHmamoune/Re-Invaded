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
var bullet_color: Color
var look: String
var look_delay: float = 0
var look_duration: float = 0
var looking: bool = false
var sprite: Texture
var wait_time: float = 0
var marker_type: String = ""
var after_image_interval: float = 0
var after_image_delay: float = 0
var additive: bool = false
var sound_effect: AudioStream = null


func shoot(bullet: Node, _seconds: float, i: int, j: int) -> void:
	if bullet.type == "shield":
		bullet.set_collision_layer_value(6, get_collision_layer_value(5))
		bullet.set_collision_layer_value(4, get_collision_layer_value(3))
		bullet.set_collision_mask_value(3, get_collision_layer_value(5))
		bullet.set_collision_mask_value(5, get_collision_layer_value(3))
	else:
		if bullet.type == "laser":
			bullet.z_index = z_index - 1
		bullet.set_collision_layer_value(3, get_collision_layer_value(3))
		bullet.set_collision_layer_value(5, get_collision_layer_value(5))
	
	if bullet.wait_time > 0:
		var indicator: Node = preload("res://Scenes/indicator.tscn").instantiate()
		
		if i == 0 and j == 0:
			indicator.mute = false
		
		indicator.time = bullet.wait_time
		indicator.type = bullet.marker_type
		indicator.angle = bullet.rotation_degrees
		indicator.position = bullet.position
		gv.current_scene.add_child(indicator)
		await get_tree().create_timer(bullet.wait_time).timeout
	
	Audio.play_sfx(bullet.sound_effect)
	if bullet.follow_player:
		bullet.position = Vector2.ZERO
		if !bullet.type == "shield":
			bullet.z_index = -1
		add_child(bullet)
	else:
		gv.current_scene.add_child(bullet)


func aim() -> float:
	if target != null:
		return rad_to_deg(global_position.angle_to_point(target.global_position) + deg_to_rad(90))
	else:
		return 0.0


func get_closest(group: String) -> Node:
	var list: Array = get_tree().get_nodes_in_group(group)
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
			target = get_closest(tween["value"])
			t.tween_property(self, "rotation_degrees", aim(), tween["dur"])
		else:
			if additive:
				t.tween_property(self, "rotation_degrees", rotation_degrees + tween["value"], tween["dur"])
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


func play_after_image() -> void:
	$AfterImageTimer.wait_time = after_image_interval
	await get_tree().create_timer(after_image_delay).timeout
	$AfterImageTimer.start()


func _on_after_image_timer_timeout() -> void:
	var after_image_instance: Node = preload("res://Scenes/after_image.tscn").instantiate()
	after_image_instance.get_node("Sprite2D").texture = $Sprite2D.texture
	after_image_instance.get_node("Sprite2D").hframes = $Sprite2D.hframes
	after_image_instance.scale = $Sprite2D.scale * scale
	after_image_instance.rotation = rotation
	after_image_instance.z_index = z_index - 1
	after_image_instance.global_position = global_position
	after_image_instance.get_node("Sprite2D").modulate = bullet_color
	get_parent().add_child(after_image_instance)
