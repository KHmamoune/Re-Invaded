extends Area2D
class_name Enemy

signal dead(scrap: int)

var hp: int
var is_dead: bool = false
var scrap: int
var status_effects: Dictionary = {}
var color: Color = Color.WHITE
var type: String = "enemy"


func start() -> void:
	pass


func rotate_by(angle: float) -> void:
	rotation_degrees = angle


func _on_area_entered(area: Node) -> void:
	if "damage" in area:
		for effect: Card.StatusAffliction in area.on_hit_effects:
			if effect.status_effect == "flame":
				var player: Node = get_tree().get_first_node_in_group("player")
				for modifier: Modifiers.Modifier in player.modifiers["flame"]:
					modifier.play(self)
			
			effect.play(self)
		
		take_damage(area.damage)
		if area.type == "bomb":
			area.explode()
		
		if area.type != "drone" and area.type != "laser" and area.type != "explosion" and not area.piercing:
			area.queue_free()


func shoot(bullet: Node, _seconds: float, i: int, j: int) -> void:
	#set the correct collision layers for the bullet
	if bullet.type == "shield":
		bullet.set_collision_layer_value(6, true)
		bullet.set_collision_mask_value(3, true)
	else:
		if bullet.type == "laser":
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
	
	if bullet.follow_player:
		bullet.position = Vector2.ZERO
		if !bullet.type == "shield":
			bullet.z_index = -1
		add_child(bullet)
	else:
		gv.current_scene.call_deferred("add_child", bullet)


func take_damage(dmg: int) -> void:
	Audio.play_sfx(Audio.sfx_hit)
	hit_flash()
	hp -= dmg
	$hp.text = str(hp)
	
	if hp <= 0 and !is_dead:
		is_dead = true
		play_death_effect()
		$Hurtbox.set_deferred("disabled", true)
		dead.emit(scrap)
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
