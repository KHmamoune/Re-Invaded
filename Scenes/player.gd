extends Area2D


signal freeze
signal unfreeze
signal update_ui


var default_speed: float = 400.0
var speed: float = 400.0
var color: Color = Color.CYAN
var state: String = "post_combat"
var on_cooldown: bool = false
var can_dash: bool = true
var dashing: bool = false
var max_hp: int = 200
var hp: int = 200
var direction: Vector2 = Vector2.ZERO
var is_dead: bool = false
var energy: float = 0
var energy_max: int = 5
var afterimage: bool = false
var gen_modifier: float = 1
var hurt: bool = false
var status_effects: Dictionary = {}
var modifiers: Dictionary = {
	"shuffle": [],
	"hurt": [],
	"combat_start": [],
	"kill": [],
	"death": [],
	"debuff": [],
	"create": [],
	"flame": [],
}


@onready var sprite_width: float = $Sprite2D.texture.get_size().x
@onready var sprite_height: float = $Sprite2D.texture.get_size().y
@onready var full_deck: Array = []
@onready var deck: Array = []
var current_hand: Array = []


func _ready() -> void:
	$Animations.play("default")
	for i in range(len(gv.cards)):
		full_deck.append(gv.cards[i])
	
	shuffle_deck()
	
	emit_signal("update_ui")


func _process(delta: float) -> void:
	if is_dead:
		return
	
	if Input.is_action_pressed("speed_up"):
		Engine.time_scale = 2
	else:
		Engine.time_scale = 1
	
	if Input.is_action_just_pressed("shuffle"):
		for enemy: Node in get_tree().get_nodes_in_group("enemy"):
			enemy.take_damage(1000000)
	
	if energy < 5:
		energy += (0.5 * gen_modifier) * delta
	
	if state == "combat" or state == "post_combat":
		direction = Vector2(Input.get_axis("move_left", "move_right"), 0.0)
	elif state == "boss":
		direction = Vector2(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
	else:
		direction = Vector2.ZERO
		return
	
	position += direction * speed * delta
	
	%DashCooldownBar.value = 0.5 - %DashCooldownTimer.time_left
	position.x = clamp(position.x, 235, 920)
	
	if Input.is_action_just_pressed("dash") and can_dash:
		if direction != Vector2(0, 0):
			Audio.play_sfx(Audio.sfx_dash)
			dash()
		
	if Input.is_action_just_pressed("shoot1"):
		if !on_cooldown and current_hand[0] != null:
			if energy > current_hand[0].card_cost:
				current_hand[0].play(self)
				current_hand[0] = deck.pop_front()
				emit_signal("update_ui")
	
	if Input.is_action_just_pressed("shoot2"):
		if !on_cooldown and current_hand[1] != null:
			if energy > current_hand[1].card_cost:
				current_hand[1].play(self)
				current_hand[1] = deck.pop_front()
				emit_signal("update_ui")
	
	if Input.is_action_just_pressed("shuffle"):
		shuffle_deck()
	
	if len(deck) == 0 and current_hand[0] == null and current_hand[1] == null:
		shuffle_deck()


func shoot(bullet: Node, seconds: float) -> void:
	if is_dead:
		return
	
	match bullet.type:
		"bullet":
			bullet.set_collision_layer_value(3, true)
		"shield":
			bullet.set_collision_layer_value(4, true)
			bullet.set_collision_mask_value(5, true)
	
	if status_effects.has("reinforce"):
		bullet.damage += status_effects["reinforce"]
	
	Audio.play_sfx(bullet.sound_effect)
	if bullet.follow_player:
		bullet.position = Vector2.ZERO
		if !bullet.type == "shield":
			bullet.z_index = -1
		add_child(bullet)
	else:
		get_parent().call_deferred("add_child", bullet)
	
	on_cooldown = true
	%FireCooldownTimer.wait_time = seconds
	%FireCooldownTimer.start()


func dash() -> void:
	can_dash = false
	dashing = true
	$Hurtbox.disabled = true
	speed *= 6
	%AfterImageTimer.start()
	%DashCooldownTimer.start()
	%DashCooldownBar.visible = true
	%DashTimer.start()


func lose_health() -> void:
	for modifier: Modifiers.Modifier in modifiers["hurt"]:
		modifier.play(self) 
	
	if hp > 0:
		hp -= 1
	
	disable_hurtbox()
	Audio.play_sfx(Audio.sfx_damage)
	emit_signal("update_ui")
	
	if hp == 0:
		is_dead = true
		emit_signal("freeze")
		health_depleted()


func health_depleted() -> void:
	Audio.play_sfx(Audio.sfx_flash)
	get_tree().paused = true
	%FreezeTimer.start()


func disable_hurtbox() -> void:
	$Hurtbox.set_deferred("disabled", true)
	if !is_dead:
		%InvincibilityTimer.start()
		$Animations.play("hit")

func shuffle_deck() -> void:
	deck = []
	current_hand = [null, null]
	
	randomize()
	deck = full_deck.duplicate(true)
	deck.shuffle()
	
	current_hand[0] = deck.pop_front()
	current_hand[1] = deck.pop_front()
	
	for modifier: Modifiers.Modifier in modifiers["shuffle"]:
		modifier.play(self)
	
	emit_signal("update_ui")


func add_modifier(modifier: Modifiers.Modifier) -> void:
	match modifier.modifier_type:
		Modifiers.Types.SHUFFLE:
			modifiers["shuffle"].append(modifier)
		Modifiers.Types.HURT:
			modifiers["hurt"].append(modifier)
		Modifiers.Types.COMBAT_START:
			modifiers["combat_start"].append(modifier)
		Modifiers.Types.KILL:
			modifiers["kill"].append(modifier)
		Modifiers.Types.DEATH:
			modifiers["death"].append(modifier)
		Modifiers.Types.FLAME:
			modifiers["flame"].append(modifier)
		Modifiers.Types.CREATE:
			modifiers["create"].append(modifier)
		Modifiers.Types.DEBUFF:
			modifiers["debuff"].append(modifier)


func _on_dash_timer_timeout() -> void:
	dashing = false
	speed = default_speed
	await get_tree().create_timer(0.05).timeout
	$Hurtbox.disabled = false
	%AfterImageTimer.stop()


func _on_fire_cooldown_timer_timeout() -> void:
	on_cooldown = false


func _on_dash_cooldown_timer_timeout() -> void:
	%DashCooldownBar.visible = false
	can_dash = true


func _on_freeze_timer_timeout() -> void:
	get_tree().paused = false
	$Hurtbox.set_deferred("disabled", true)
	emit_signal("unfreeze")
	
	if len(modifiers["death"]) > 0:
		is_dead = false
		$InvincibilityTimer.start()
		modifiers["death"][0].play(self)
		modifiers["death"].pop_back()
		emit_signal("update_ui")
		return
	
	hide()
	
	var particle: Node = $DeathEffect
	remove_child(particle)
	particle.position = position
	particle.emitting = true
	get_parent().add_child(particle)
	Audio.play_sfx(Audio.sfx_explosion)
	
	await get_tree().create_timer(1.5).timeout
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/game_over_menu.tscn")


func _on_invincibility_timer_timeout() -> void:
	if !is_dead:
		$Hurtbox.set_deferred("disabled", false)
		$Animations.play("default")


func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)


func _on_area_entered(area: Node) -> void:
	hurt = true
	lose_health()
	#if the attacker is not an enemy free it
	if area.type != "enemy" and area.type != "drone" and area.type != "laser" and area.type != "explosion":
		area.queue_free()

#every time the after image timer timesout we add a new after image
func _on_after_image_timer_timeout() -> void:
	var after_image_instance: Node = preload("res://Scenes/after_image.tscn").instantiate()
	after_image_instance.get_node("Sprite2D").texture = $Sprite2D.texture
	after_image_instance.get_node("Sprite2D").hframes = $Sprite2D.hframes
	after_image_instance.scale = $Sprite2D.scale
	after_image_instance.rotation = rotation
	after_image_instance.global_position = global_position
	get_parent().add_child(after_image_instance)
