extends Node


func apply_impede(target: Node, duration: float) -> void:
	var impede_timer: Timer
	if !is_instance_valid(target.get_node_or_null("impede_timer")):
		impede_timer = Timer.new()
	else:
		impede_timer = target.get_node_or_null("impede_timer")
	
	print("applied impede")
	if impede_timer.time_left > 0:
		impede_timer.start(impede_timer.time_left + duration)
		return
	
	var og_speed: float = target.speed
	impede_timer.timeout.connect(dispel_impede.bind(target, og_speed))
	impede_timer.name = "impede_timer"
	target.add_child(impede_timer)
	impede_timer.start(duration)
	target.speed = og_speed / 2
	target.default_speed = og_speed / 2
	target.status_effects["impede"] = 1
	target.update_status_bar()


func dispel_impede(target: Node, og_speed: float) -> void:
	print("dispeled impede")
	target.speed = og_speed
	target.default_speed = og_speed
	target.get_node_or_null("impede_timer").queue_free()
	target.status_effects["impede"] = 0
	target.update_status_bar()


func apply_generation_boost(target: Node, duration: float) -> void:
	var gen_boost_timer: Timer
	print("applied gen_boost")
	if !is_instance_valid(target.get_node_or_null("gen_boost_timer")):
		gen_boost_timer = Timer.new()
	else:
		gen_boost_timer = target.get_node_or_null("gen_boost_timer")
	
	if gen_boost_timer.time_left > 0:
		gen_boost_timer.start(gen_boost_timer.time_left + duration)
		return
	
	gen_boost_timer.timeout.connect(dispel_generation_boost.bind(target))
	gen_boost_timer.name = "gen_boost_timer"
	target.add_child(gen_boost_timer)
	gen_boost_timer.start(duration)
	target.gen_modifier += 1
	target.status_effects["generation boost"] = 1
	target.update_status_bar()


func dispel_generation_boost(target: Node) -> void:
	print("dispeled gen_boost")
	target.gen_modifier -= 1
	target.get_node_or_null("gen_boost_timer").queue_free()
	target.status_effects["generation boost"] = 0
	target.update_status_bar()


func apply_flame(target: Node, duration: float) -> void:
	var flame_timer: Timer
	print("applied flame")
	if !is_instance_valid(target.get_node_or_null("flame_timer")):
		flame_timer = Timer.new()
	else:
		flame_timer = target.get_node_or_null("flame_timer")
	
	if flame_timer.time_left > 0:
		flame_timer.start(flame_timer.time_left + duration)
		return
	
	var damage_timer:Timer = Timer.new()
	flame_timer.name = "flame_timer"
	target.add_child(flame_timer)
	flame_timer.start(duration)
	flame_timer.timeout.connect(dispel_flame.bind(target, damage_timer, flame_timer))
	target.status_effects["flame"] = 1
	target.update_status_bar()
	
	damage_timer.wait_time = 0.5
	damage_timer.timeout.connect(damage_flame.bind(target))
	damage_timer.name = "damage_timer"
	target.add_child(damage_timer)
	damage_timer.start()


func dispel_flame(target: Node, damage_timer: Timer, flame_timer: Timer) -> void:
	print("dispeled flame")
	if is_instance_valid(damage_timer):
		damage_timer.stop()
		damage_timer.queue_free()
	flame_timer.queue_free()
	target.status_effects["flame"] = 0
	target.update_status_bar()


func damage_flame(target: Node) -> void:
	print("damage flame")
	if target.has_method("take_damage"):
		target.take_damage(2)


func apply_heat(target: Node, stack: int) -> void:
	var heat_timer: Timer
	print("applied heat")
	if !is_instance_valid(target.get_node_or_null("heat_timer")):
		heat_timer = Timer.new()
	else:
		heat_timer = target.get_node_or_null("heat_timer")
	
	if heat_timer.time_left > 0:
		heat_timer.start(5)
		target.gen_modifier -= 0.1 * target.status_effects["heat"]
		target.speed -= 40 * target.status_effects["heat"]
		target.status_effects["heat"] += stack
		if target.status_effects["heat"] > 10:
			target.status_effects["heat"] = 10
		target.speed += 40 * target.status_effects["heat"]
		target.gen_modifier += 0.1 * target.status_effects["heat"]
		target.update_status_bar()
		return
	
	if "heat" in target.status_effects:
		target.gen_modifier -= 0.1 * target.status_effects["heat"]
		target.speed -= 40 * target.status_effects["heat"]
		target.status_effects["heat"] += stack
		target.gen_modifier += 0.1 * target.status_effects["heat"]
		target.speed += 40 * target.status_effects["heat"]
	else:
		target.status_effects["heat"] = stack
		target.gen_modifier += 0.1 * stack
		target.speed += 40 * target.status_effects["heat"]
	target.update_status_bar()
	
	heat_timer.timeout.connect(dispel_heat.bind(target))
	heat_timer.name = "heat_timer"
	target.add_child(heat_timer)
	heat_timer.start(5)


func dispel_heat(target: Node) -> void:
	target.gen_modifier -= 0.1 * target.status_effects["heat"]
	target.speed -= 40 * target.status_effects["heat"]
	target.status_effects["heat"] = 0
	target.update_status_bar()


func apply_reinforce(target: Node, stack: int) -> void:
	if "reinforce" in target.status_effects:
		target.status_effects["reinforce"] += stack
	else:
		target.status_effects["reinforce"] = stack
	target.update_status_bar()


func dispel_reinforce(target: Node) -> void:
	target.status_effects["reinforce"] = 0
	target.update_status_bar()


func apply_fragile(target: Node, stack: int) -> void:
	if "fragile" in target.status_effects:
		target.status_effects["fragile"] += stack
	else:
		target.status_effects["fragile"] = stack
	target.update_status_bar()


func dispel_fragile(target: Node) -> void:
	target.status_effects["fragile"] = 0
	target.update_status_bar()


func apply_bullet_speed_boost(target: Node) -> void:
	target.status_effects["bullet_speed_boost"] = 1
	target.update_status_bar()


func dispel_bullet_speed_boost(target: Node) -> void:
	target.status_effects["bullet_speed_boost"] = 0
	target.update_status_bar()


func apply_self_repair(target: Node, duration: float, amount: int) -> void:
	var heal_timer:Timer = Timer.new()
	heal_timer.wait_time = duration
	heal_timer.timeout.connect(self_repair.bind(target, amount))
	heal_timer.name = "heal_timer"
	target.add_child(heal_timer)
	heal_timer.start()


func self_repair(target: Node, amount: int) -> void:
	print("healed")
	if target.has_method("take_damage"):
		target.take_damage(amount)
