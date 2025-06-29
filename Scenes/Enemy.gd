extends Area2D
class_name Enemy

signal dead(scrap: int)

var hp: int
var is_dead: bool = false
var scrap: int
var status_effects: Dictionary = {}
var color: Color = Color.WHITE
var type: String = "enemy"
var hit_effect: PackedScene = preload("res://Scenes/hit_effect.tscn")
var hp_node: Node
var status_node: Node


func start() -> void:
	pass


func rotate_by(angle: float) -> void:
	rotation_degrees = angle


func play_animation(anm_name: String, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	var instance: Node = gv.attack_animations[anm_name].instantiate()
	instance.z_index += 1
	instance.position = position
	get_parent().add_child(instance)
	instance.get_node("AnimationPlayer").play("play")


func _on_area_entered(area: Node) -> void:
	if "damage" in area:
		for c: Card.CardStats in area.on_hit_effects:
			for eff: Dictionary in c.card_effect:
				if eff["effect"].status_effect == "flame":
					var player: Node = get_tree().get_first_node_in_group("player")
					for modifier: Modifiers.Modifier in player.modifiers["flame"]:
						modifier.play(self)
				
				eff["effect"].play(self)
		
		take_damage(area.damage, area)
		if area.type == "bomb":
			area.explode()
		
		if area.type != "drone" and area.type != "laser" and area.type != "explosion" and not area.piercing:
			var inst: Node = hit_effect.instantiate()
			inst.color = color
			inst.position = area.position
			get_parent().add_child(inst)
			inst.emitting = true
			area.fade_out()


func shoot(bullet: Node, _seconds: float, i: int, j: int) -> void:
	#set the correct collision layers for the bullet
	if bullet.type == "shield":
		bullet.set_collision_layer_value(6, true)
		bullet.set_collision_mask_value(3, true)
	else:
		bullet.z_index = z_index - 1
		bullet.set_collision_layer_value(5, true)
	
	#if there is an indicator before the attack we set its values
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
	
	#accounting if the enemy has X buffs
	if "bullet_speed_boost" in status_effects:
		if status_effects["bullet_speed_boost"] == 1:
			bullet.speed += 200
	
	#playing the sound effect of the bullet
	Audio.play_sfx(bullet.sound_effect)
	
	bullet.add_to_group("bullet")
	
	if bullet.follow_player:
		bullet.position = Vector2.ZERO
		if !bullet.type == "shield":
			bullet.z_index = -1
		add_child(bullet)
	else:
		gv.current_scene.call_deferred("add_child", bullet)


func take_damage(dmg: int, area: Node = null) -> void:
	Audio.play_sfx(Audio.sfx_hit)
	hit_flash()
	hp -= dmg
	hp_node.get_child(0).text = str(hp)
	
	if hp <= 0 and !is_dead:
		is_dead = true
		play_death_effect()
		$Hurtbox.set_deferred("disabled", true)
		
		if area != null:
			if len(area.on_kill_effects) != 0:
				for effect: Card.CardStats in area.on_kill_effects:
					var player: Node = get_tree().get_first_node_in_group("player")
					effect.play(player, self)
		
		dead.emit(scrap)
		hp_node.queue_free()
		status_node.queue_free()
		Audio.play_sfx(Audio.sfx_enemy_death_explosion)
		queue_free()


func play_death_effect() -> void:
	var death_effect: Node = preload("res://Scenes/death_effect.tscn").instantiate()
	death_effect.get_node("CPUParticles2D").color = color
	death_effect.global_position = global_position
	get_parent().add_child(death_effect)
	death_effect.get_node("CPUParticles2D").emitting = true


func hit_flash() -> void:
	$Sprite2D.material.set_shader_parameter("flash_modifier", 1)
	await get_tree().create_timer(0.02).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0)


func set_up_hp(hp_amount: int, hp_position: Vector2) -> void:
	var hp_label: Label = Label.new()
	hp_node = Node2D.new()
	
	hp_node.add_child(hp_label)
	
	hp = hp_amount
	hp_label.text = str(hp_amount)
	
	get_parent().add_child(hp_node)
	
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	hp_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	hp_label.set_anchors_preset(Control.PRESET_CENTER, false)
	hp_label.offset_left = 0
	hp_label.offset_right = 0
	hp_label.offset_bottom = 0
	hp_label.offset_top = 0
	hp_label.position += hp_position
	
	$HPTransform2D.remote_path = hp_node.get_path()


func set_up_status_effects(status_position: Vector2) -> void:
	var status_label: Node = preload("res://Scenes/status_effects_bar.tscn").instantiate()
	status_label.position = status_position
	status_node = Node2D.new()
	
	status_node.add_child(status_label)
	get_parent().add_child(status_node)
	
	$StatusTransform2D.remote_path = status_node.get_path()


func update_status_bar() -> void:
	status_node.get_child(0).update_status_effects(status_effects)


func _on_after_image_timer_timeout() -> void:
	var after_image_instance: Node = preload("res://Scenes/after_image.tscn").instantiate()
	after_image_instance.get_node("Sprite2D").texture = $Sprite2D.texture
	after_image_instance.get_node("Sprite2D").hframes = $Sprite2D.hframes
	after_image_instance.get_node("Sprite2D").frame = $Sprite2D.frame
	after_image_instance.scale = $Sprite2D.scale
	after_image_instance.rotation = rotation
	after_image_instance.global_position = global_position
	get_parent().add_child(after_image_instance)
