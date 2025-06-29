extends Node

class CardStats:
	var game_data: Dictionary = gdt.read_json(gdt.game_data_path)
	var card_data: Dictionary = game_data["card_data"]
	var card_cost: int
	var card_name: String
	var card_image: String
	var card_type: String
	var card_description: String
	var card_color: Color
	var card_effect: Array
	var card_price: int
	var card_tooltips: Array
	
	func _init(cost: int, name: String, type: String, color: Color, effect: Array, price: int = 100, tooltips: Array = []) -> void:
		if name != "":
			card_name = card_data[name]["title"]
			card_image = card_data[name]["image"]
			card_description = card_data[name]["description"]
		card_cost = cost
		card_type = type
		card_color = color
		card_effect = effect
		card_price = price
		card_tooltips = tooltips
	
	func play(pl: Node, _additional_arg: Node = null) -> void:
		pl.energy -= card_cost
		for card: Dictionary in card_effect:
			if card.has("effect"):
				if typeof(card["effect"]) == typeof(Card.CardStats) or typeof(card["effect"]) == typeof(Card.StatusAffliction) or typeof(card["effect"]) == typeof(Card.DeckManipulation):
					if card["effect"].animation_name != "":
						pl.play_animation(card["effect"].animation_name, card["effect"].animation_delay)
					
					if card.has("delay"):
						await gv.current_scene.get_tree().create_timer(card["delay"]).timeout
					
					card["effect"].play(pl)
				else:
					if card.has("delay"):
						await gv.current_scene.get_tree().create_timer(card["delay"]).timeout
					
					card["effect"].call(pl)


class StatusAffliction:
	var status_effect: String
	var status_type: String
	var status_duration: float
	var status_stack: int
	var animation_name: String = ""
	var animation_delay: float = 0
	
	func _init(se: String, sd: float = 0, ss: int = 1, st: String = "buff") -> void:
		status_effect = se
		status_type = st
		status_duration = sd
		status_stack = ss
	
	func play(pl: Node) -> void:
		if status_type == "debuff":
			if "modifiers" in pl:
				for modifier: Modifiers.Modifier in pl.modifiers["debuff"]:
					modifier.play(pl)
			
			if pl.status_effects.has(status_effect):
				if pl.status_effects[status_effect]["stack"] == 0:
					pl.play_animation("debuff_animation", 0)
			else:
				pl.play_animation("debuff_animation", 0)
		
		if status_type == "buff":
			pl.play_animation("buff_animation", 0)
		
		match status_effect:
			"impede":
				StatusEffects.apply_impede(pl, status_duration)
			"gen_boost":
				StatusEffects.apply_generation_boost(pl, status_duration)
			"gen_impede":
				StatusEffects.apply_generation_impede(pl, status_duration)
			"flame":
				StatusEffects.apply_flame(pl, status_duration)
			"heat":
				StatusEffects.apply_heat(pl, status_stack)
			"reinforce":
				StatusEffects.apply_reinforce(pl, status_stack)
			"fragile":
				StatusEffects.apply_fragile(pl, status_stack)
			"endurance":
				StatusEffects.apply_endurance(pl, status_stack)
			"charge":
				StatusEffects.apply_charge(pl, status_stack)
		
		if pl.has_method("show_text"):
			pl.show_text(status_effect, status_effect)


class DeckManipulation:
	var manipulation_type: String
	var card: CardStats
	var animation_name: String = ""
	var animation_delay: float = 0
	var execution_times: int = 1
	
	func _init(mt: String, c: CardStats = null, e: int = 1) -> void:
		manipulation_type = mt
		card = c
		execution_times = e
	
	func play(pl: Node) -> void:
		match manipulation_type:
			"add":
				for modifier: Modifiers.Modifier in pl.modifiers["create"]:
					modifier.play(pl)
				for _i in range(execution_times):
					pl.full_deck.push_back(card)
					
					if len(pl.deck) == 0 and pl.current_hand[0] == null or pl.current_hand[1] == null:
						if pl.current_hand[0] == null:
							pl.current_hand[0] = card
						else:
							pl.current_hand[1] = card
					else:
						pl.deck.push_back(card)
				
				pl.emit_signal("update_ui")
				pl.show_text("", card.card_name)
			
			"shuffle":
				pl.shuffle_deck(0.01)


class AttackPattren:
	var bullet_amount: int # amount of bullets shot each wave
	var fire_amount: int # number of waves shot
	var fire_angles: Array # the firing angle of the bullets
	var fire_delay: float # the delay between bullet waves
	var bullet_speed: float # the speed of the bullets
	var fire_positions: Array # the fire position offset
	var bullet_range: float # the distance the bullet travels before it is deleted
	var bullet_damage: int # the damage of the bullet
	var bullet_type: PackedScene # the type of the bullet (bullet, shield, laser...)
	var sound_effect: AudioStream = Audio.sfx_shoot # the sfx played when the bullet is shot
	var change_angle_by: Array = [] # the different offsets between waves
	var change_speed_by: Array = []
	var change_position_by: Array = []
	var move_angle_to: Array = [] # the different tweens
	var move_speed_to: Array = []
	var move_position_to: Array = []
	var move_size_to: Array = []
	var additive_tweens: bool = false
	var bounce: bool = false # wether the bullet is bounces off walls or not
	var on_hit_effects: Array = [] # status effects applied by the bullet
	var on_kill_effects: Array = []
	var random_range: float = 0 # randomness added to the fire angle
	var aim: String = "" # a target for the bullet to ain at
	var laser_duration: float # time that the laser lasts active
	var bullet_attack: Array # an attack that the bullet shoots
	var abs_position: Array = [] # an array of positions that overrides the original shooter position
	var explosion_delay: float
	var explosion_damage: int
	var explosion_radius: Vector2
	var follow_player: bool = false
	var pierce: bool = false
	var shield_time: float = 0
	var shield_scale: Vector2 = Vector2(1, 1)
	var shield_reflect: bool = false
	var drone_time: float = 0
	var look: String = ""
	var look_delay: float = 0
	var look_duration: float = 0
	var bullet_sprite: Texture = preload("res://Assets/Bullets/Bullet.png")
	var animation_frames: int = 1
	var animation_speed: float = 0
	var bullet_sprite_size: Vector2 = Vector2(3, 2)
	var bullet_hitbox_size: Vector2 = Vector2(0.3, 0.175)
	var bullet_color: Color = Color.WHITE
	var marker_type: String = ""
	var marker_duration: float =  0
	var after_image_delay: float = 0
	var after_image_interval: float = 0
	var animation_name: String = ""
	var animation_delay: float = 0
	var fade_in_delay: float = 0
	var fade_in_duration: float = 0
	var bullet_effect: PackedScene = null
	var bullet_effect_color: Color
	var changed_sprite: bool = false
	
	
	func _init(bt: PackedScene, bam: int, fam: int, fan: Array, fde: float, bsp: float, fpo: Array, bra: float, bda: int) -> void:
		bullet_amount = bam
		fire_amount = fam
		fire_angles = fan
		fire_delay = fde
		bullet_speed = bsp
		fire_positions = fpo
		bullet_range = bra
		bullet_damage = bda
		bullet_type = bt
	
	func play(pl: Node) -> void:
		for i in range(fire_amount): #looping for each fired wave
			if is_instance_valid(pl):
				for j in range(bullet_amount): #looping through each bullet in a wave
					if pl.is_dead == false:
						if bullet_type == preload("res://Scenes/laser.tscn"):
							var laser: Node = set_stats(j, i, pl)
							set_laser_stats(laser)
							pl.shoot(laser, fire_delay * float(fire_amount), i, j)
						elif bullet_type == preload("res://Scenes/bomb.tscn"):
							var bomb: Node = set_stats(j, i, pl)
							set_bomb_stats(bomb)
							pl.shoot(bomb, fire_delay * float(fire_amount), i, j)
						elif bullet_type == preload("res://Scenes/shield.tscn"):
							var shield: Node = set_stats(j, i, pl)
							set_shield_stats(shield)
							pl.shoot(shield, fire_delay * float(fire_amount), i, j)
						elif bullet_type == preload("res://Scenes/drone.tscn"):
							var drone: Node = set_stats(j, i, pl)
							set_drone_stats(drone)
							pl.shoot(drone, fire_delay * float(fire_amount), i, j)
						else:
							var bullet: Node = set_stats(j, i, pl)
							pl.shoot(bullet, fire_delay * float(fire_amount), i, j)
				
				if is_instance_valid(pl.get_tree()):
					await pl.get_tree().create_timer(fire_delay).timeout
	
	func set_stats(j: int, i: int, player: Node) -> Node:
		var bullet: Node = bullet_type.instantiate()
		
		bullet.shooter = player
		
		if abs_position != []:
			if change_position_by.is_empty():
				bullet.global_position = get_abs_position(j) + get_position(j)
			else:
				bullet.global_position = get_abs_position(j) + (change_position_by[j] * i)
		else:
			if change_position_by.is_empty():
				bullet.global_position = player.global_position + get_position(j)
			else:
				bullet.global_position = player.global_position + (change_position_by[j] * i)
		
		#setting the fire angle
		if aim != "":
			bullet.target = get_closest(bullet)
		else:
			if random_range != 0:
				bullet.rotation_degrees = player.rotation_degrees + (get_angle(j) - random_range / 2.0) + randf() * random_range
			elif change_angle_by.is_empty():
				bullet.rotation_degrees = player.rotation_degrees + get_angle(j)
			else:
				bullet.rotation_degrees = player.rotation_degrees + get_angle(j) + (change_angle_by[j] * i)
		
		#setting the bullet speed
		if change_speed_by.is_empty():
			bullet.speed = bullet_speed
		else:
			bullet.speed = bullet_speed + (change_speed_by[j] * i)
		
		bullet.move_range = bullet_range
		bullet.damage = bullet_damage
		
		#setting specific properties
		if bounce:
			bullet.bouncy = true
		
		if follow_player:
			bullet.follow_player = true
		
		if pierce:
			bullet.piercing = true
		
		if len(on_hit_effects) > 0:
			for effect: Card.CardStats in on_hit_effects:
				bullet.on_hit_effects.append(effect)
		
		#setting tween values
		if len(move_angle_to) > 0:
			bullet.angle_tweens = get_angle_tween(j)
		
		if len(move_speed_to) > 0:
			bullet.speed_tweens = get_speed_tween(j)
		
		if len(move_position_to) > 0:
			bullet.position_tweens = get_position_tween(j)
		
		if len(move_size_to) > 0:
			bullet.size_tweens = get_size_tween(j)
		
		if len(bullet_attack) > 0:
			bullet.attack = bullet_attack
		
		bullet.additive = additive_tweens
		
		bullet.sprite = bullet_sprite
		bullet.frames = animation_frames
		bullet.anm_speed = animation_speed
		bullet.sprite_size = bullet_sprite_size
		bullet.hitbox_size = bullet_hitbox_size
		bullet.bullet_color = bullet_color
		bullet.changed_sprite = changed_sprite
		
		bullet.look = look
		bullet.look_delay = look_delay
		bullet.look_duration = look_duration
		
		if marker_type != "":
			bullet.marker_type = marker_type
			bullet.wait_time = marker_duration
		
		bullet.after_image_delay = after_image_delay
		bullet.after_image_interval = after_image_interval
		
		bullet.sound_effect = sound_effect
		
		bullet.animation_name = animation_name
		bullet.animation_delay = animation_delay
		
		if fade_in_delay != 0:
			bullet.fade_in_delay = fade_in_delay
			bullet.fade_in_duration = fade_in_duration
		
		if len(on_kill_effects) != 0:
			bullet.on_kill_effects = on_kill_effects
		
		if bullet_effect != null:
			var inst: Node = bullet_effect.instantiate()
			inst.color = bullet_effect_color
			inst.z_index = bullet.z_index - 1
			gv.current_scene.add_child(inst)
			bullet.get_node("EffectTransform").remote_path = inst.get_path()
			bullet.vfx_effect = inst
		
		return bullet
	
	func set_laser_stats(laser: Node) -> void:
		laser.duration = laser_duration
		laser.damage = bullet_damage
		
		if follow_player:
			laser.follow_player = true
	
	func set_bomb_stats(bomb: Node) -> void:
		bomb.time = explosion_delay
		bomb.explosion_damage = explosion_damage
		bomb.rad = explosion_radius
	
	func set_shield_stats(shield: Node) -> void:
		shield.time = shield_time
		shield.size = shield_scale
		shield.reflect = shield_reflect
	
	func set_drone_stats(drone: Node) -> void:
		drone.time = drone_time
	
	func set_laser_properties(dur: float) -> void:
		laser_duration = dur
	
	func set_bomb_properties(delay: float, radius: Vector2, damage: int) -> void:
		explosion_delay = delay
		explosion_radius = radius
		explosion_damage = damage
	
	func set_shield_properties(time: float = 1, size: Vector2 = Vector2(1, 1), reflect: bool = false) -> void:
		shield_time = time
		shield_scale = size
		shield_reflect = reflect
	
	func set_drone_properties(time: float) -> void:
		drone_time = time
	
	func set_change_values(cab: Array = [], csb: Array = [], cpb: Array = []) -> void:
		change_angle_by = cab
		change_speed_by = csb
		change_position_by = cpb
	
	func set_properties(bouncy: bool = false, follow: bool = false, piercing: bool = false) -> void:
		bounce = bouncy
		follow_player = follow
		pierce = piercing
	
	func set_aim(target: String = "", fire_range: float = 0) -> void:
		if target != "":
			aim = target
		else:
			random_range = fire_range
	
	func set_look(target: String, delay: float = 0, duration: float = 0) -> void:
		look = target
		look_delay = delay
		look_duration = duration
	
	func set_tweens(mat: Array = [], mst: Array = [], mpt: Array = [], msit: Array = [], additive: bool = false) -> void:
		if len(mat) > 0:
			move_angle_to.append(mat)
		
		if len(mst) > 0:
			move_speed_to.append(mst)
		
		if len(mpt) > 0:
			move_position_to.append(mpt)
		
		if len(msit) > 0:
			move_size_to.append(msit)
		
		additive_tweens = additive
	
	func get_closest(bullet: Node) -> Node:
		var list: Array = gv.current_scene.get_tree().get_nodes_in_group(aim)
		if len(list) > 0:
			var nearest: Node = list[0]
				
			for en: Node in list:
				if nearest.global_position.distance_to(bullet.global_position) > en.global_position.distance_to(bullet.global_position):
					nearest = en
			return nearest
		return null
	
	func set_attack(delay: float, attack: Card.AttackPattren, free: bool = false) -> void:
		bullet_attack = [delay, attack, free]
	
	func set_abs_position(pos: Array) -> void:
		abs_position = pos
	
	func set_on_hit_effects(ohe: Array) -> void:
		on_hit_effects = ohe
		
	func set_on_kill_effects(oke: Array) -> void:
		on_kill_effects = oke
	
	func set_sprite_and_size(sprite: Texture, frames: int, anm_speed: float, size1: Vector2, size2: Vector2) -> void:
		bullet_sprite = sprite
		animation_frames = frames
		animation_speed = anm_speed
		bullet_sprite_size = size1
		bullet_hitbox_size = size2
		changed_sprite = true
	
	func set_marker(type: String, time: float) -> void:
		marker_type = type
		marker_duration = time
	
	func set_after_image(aid: float, aii: float) -> void:
		after_image_delay = aid
		after_image_interval = aii
	
	func set_sprite_preset(preset: Dictionary, color: Color) -> void:
		bullet_sprite = preset["sprite"]
		animation_frames = preset["frames"]
		animation_speed = preset["anm_speed"]
		bullet_sprite_size = preset["scale"]
		bullet_hitbox_size = preset["hitbox_scale"]
		bullet_color = color
		changed_sprite = true
	
	func set_animation(name: String, delay: float) -> void:
		animation_name = name
		animation_delay = delay 
	
	func set_sfx(sfx: AudioStream = Audio.sfx_shoot) -> void:
		sound_effect = sfx
	
	func set_fade_in(delay: float, duration: float) -> void:
		fade_in_delay = delay
		fade_in_duration = duration
	
	func set_bullet_effect(effect: PackedScene, color: Color = Color.WHITE) -> void:
		bullet_effect = effect
		bullet_effect_color = color
	
	func get_position(j: int) -> Vector2:
		if len(fire_positions) > 1:
			return fire_positions[j]
		else:
			return fire_positions[0]
	
	func get_abs_position(j: int) -> Vector2:
		if len(abs_position) > 1:
			return abs_position[j]
		else:
			return abs_position[0]
	
	func get_angle(j: int) -> float:
		if len(fire_angles) > 1:
			return fire_angles[j]
		else:
			return fire_angles[0]
	
	func get_angle_tween(j: int) -> Array:
		if len(move_angle_to) > 1:
			return move_angle_to[j]
		else:
			return move_angle_to[0]
	
	func get_speed_tween(j: int) -> Array:
		if len(move_speed_to) > 1:
			return move_speed_to[j]
		else:
			return move_speed_to[0]
	
	func get_position_tween(j: int) -> Array:
		if len(move_position_to) > 1:
			return move_position_to[j]
		else:
			return move_position_to[0]
	
	func get_size_tween(j: int) -> Array:
		if len(move_size_to) > 1:
			return move_size_to[j]
		else:
			return move_size_to[0]


func jammed_fire(pl: Node) -> void:
	var attack: Card.AttackPattren = AttackPattren.new(gv.bullet, 1, 1, [0], 0.1, 2500, [Vector2.ZERO], 1000, 20)
	var add_jam: Card.DeckManipulation = DeckManipulation.new("add", gv.jam_card)
	var rand: int
	for i in range(0, 5):
		rand = randi_range(0,1)
		
		if rand == 0:
			attack.play(pl)
		else:
			add_jam.play(pl)
		
		await get_tree().create_timer(0.2).timeout


func photosynthesis(pl: Node) -> void:
	var effect: Card.DeckManipulation = Card.DeckManipulation.new("add", gv.yellow_sub_card1, 2)
	
	effect.play(pl)
	pl.heal(1)


func static_discharge(pl: Node) -> void:
	for enemy: Node in gv.current_scene.get_tree().get_nodes_in_group("enemy"):
		if "charge" in pl.status_effects:
			enemy.take_damage(pl.status_effects["charge"]["stack"] * 2)
	
	StatusEffects.dispel_charge(pl)
