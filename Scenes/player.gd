extends Area2D


signal freeze
signal unfreeze
signal update_ui
signal show_shuffle_delay
signal update_graze_bar


var status_text: PackedScene = preload("res://Scenes/status_text.tscn")
var special_attack: Card.CardStats
var default_speed: float = 400.0
var speed: float = 400.0
var color: Color = Color.CYAN
var state: String = "post_combat"
var on_cooldown: bool = false
var can_dash: bool = true
var dashing: bool = false
var shuffling: bool = false
var max_hp: int = 5
var hp: int = 5
var direction: Vector2 = Vector2.ZERO
var is_dead: bool = false
var energy: float = 0
var energy_max: int = 5
var afterimage: bool = false
var gen_modifier: float = 1
var hurt: bool = false
var shuffle_speed: float = 1
var graze_points: int = 0
var exhausted_cards: Array = []
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
	"heal": [],
}


@onready var sprite_width: float = $Sprite2D.texture.get_size().x
@onready var sprite_height: float = $Sprite2D.texture.get_size().y
var full_deck: Array = []
var deck: Array = []
var current_hand: Array = []


func _ready() -> void:
	$Animations.play("default")
	shuffle_deck(0.01)
	emit_signal("update_ui")


func _process(delta: float) -> void:
	if is_dead:
		return
	
	if energy < energy_max:
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
	
	if len(deck) == 0 and current_hand[0] == null and current_hand[1] == null:
		shuffle_deck(shuffle_speed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("speed_up"):
		Engine.time_scale = 2
	else:
		Engine.time_scale = 1
	
	if event.is_action_pressed("shuffle"):
		for enemy: Node in get_tree().get_nodes_in_group("enemy"):
			enemy.take_damage(1000000)
	
	if state != "combat" and state != "post_combat":
		return
	
	if event.is_action_pressed("dash") and can_dash:
		if direction != Vector2(0, 0):
			Audio.play_sfx(Audio.sfx_dash)
			dash()
		
	if event.is_action_pressed("shoot1"):
		if !on_cooldown and current_hand[0] != null:
			if energy > current_hand[0].card_cost:
				var card: Card.CardStats = current_hand[0]
				current_hand[0] = deck.pop_front()
				if card.card_tooltips.has("exhaust"):
					exhausted_cards.append(card)
					full_deck.erase(card)
				card.play(self)
				emit_signal("update_ui")
	
	if event.is_action_pressed("shoot2"):
		if !on_cooldown and current_hand[1] != null:
			if energy > current_hand[1].card_cost:
				var card: Card.CardStats = current_hand[1]
				current_hand[1] = deck.pop_front()
				if card.card_tooltips.has("exhaust"):
					exhausted_cards.append(card)
					full_deck.erase(card)
				card.play(self)
				emit_signal("update_ui")
	
	if event.is_action_pressed("shuffle") and not shuffling:
		shuffling = true
		shuffle_deck(shuffle_speed)
	
	if event.is_action_pressed("special"):
		if graze_points == 30:
			play_animation("special_fire", 0)
			special_attack.play(self)
			graze_points = 0
			update_graze_bar.emit(graze_points)


func shoot(bullet: Node, seconds: float, _i: int, _j: int) -> void:
	if is_dead:
		return
	
	#if bullet.animation_name != "":
	#	play_animation(bullet.animation_name, bullet.animation_delay)
	
	if bullet.type == "shield":
		bullet.set_collision_layer_value(4, true)
		bullet.set_collision_mask_value(5, true)
	else:
		bullet.z_index = z_index - 1
		bullet.set_collision_layer_value(3, true)
	
	if status_effects.has("reinforce"):
		bullet.damage += status_effects["reinforce"]["stack"]
	
	if status_effects.has("meltdown"):
		if status_effects["meltdown"]["stack"] == 1:
			bullet.damage = ceili(bullet.damage * 1.2)
	
	Audio.play_sfx(bullet.sound_effect)
	
	bullet.add_to_group("bullet")
	
	if bullet.follow_player:
		bullet.position = Vector2.ZERO
		if !bullet.type == "shield":
			bullet.z_index = -1
		add_child(bullet)
	else:
		gv.current_scene.call_deferred("add_child", bullet)
	
	on_cooldown = true
	%FireCooldownTimer.wait_time = seconds
	%FireCooldownTimer.start()


func play_animation(anm_name: String, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	var instance: Node = gv.attack_animations[anm_name].instantiate()
	add_child(instance)
	instance.get_node("AnimationPlayer").play("play")


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
		if status_effects.has("endurance"):
			if status_effects["endurance"] > 0:
				status_effects["endurance"] -= 1
				update_status_bar()
			else:
				hp -= 1
		else:
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


func shuffle_deck(time: float) -> void:
	deck = []
	current_hand = [null, null]
	
	randomize()
	deck = full_deck.duplicate(true)
	deck.shuffle()
	
	emit_signal("show_shuffle_delay", time)
	await get_tree().create_timer(time).timeout
	
	current_hand[0] = deck.pop_front()
	current_hand[1] = deck.pop_front()
	
	for modifier: Modifiers.Modifier in modifiers["shuffle"]:
		modifier.play(self)
	
	emit_signal("update_ui")
	shuffling = false


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
		Modifiers.Types.HEAL:
			modifiers["heal"].append(modifier)


func show_text(image: String, text: String) -> void:
	var inst: Node = status_text.instantiate()
	inst.text = text + " +"
	inst.image = image
	inst.position.y = position.y - 50
	add_child(inst)


func heal(amount: int) -> void:
	for modifier: Modifiers.Modifier in modifiers["heal"]:
		modifier.play(self)
	 
	hp += amount


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
	if "on_hit_effects" in area:
		for effect: Card.StatusAffliction in area.on_hit_effects:
			effect.play(self)
	
	lose_health()
	
	#if the attacker is not an enemy free it
	if area.type != "enemy" and area.type != "drone" and area.type != "laser" and area.type != "explosion":
		if !area.piercing:
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


func _on_grazebox_area_entered(_area: Area2D) -> void:
	if graze_points < 30:
		graze_points += 1
		update_graze_bar.emit(graze_points)
