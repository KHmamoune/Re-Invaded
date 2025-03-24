extends Node


# checking wether the target has the status effect or not and assign the appropriate stack and time to it
func check_and_add(target: Node, status_name: String, stack: int, time: float = 0.0, type: String = "static") -> void:
	if status_name in target.status_effects:
		if type == "static":
			target.status_effects[status_name]["stack"] = stack
		elif type == "additive":
			target.status_effects[status_name]["stack"] += stack
		
		target.status_effects[status_name]["time"] = time
	else:
		target.status_effects[status_name] = {"stack": stack, "time": time}


# setting up the status timer and all its properties
func set_up_timer(target: Node, timer_name: String, callback: Callable, one_shot: bool = true) -> Timer:
	var timer: Timer = Timer.new()
	timer.one_shot = one_shot
	timer.timeout.connect(callback)
	timer.name = timer_name
	target.add_child(timer)
	return timer


func apply_impede(target: Node, duration: float) -> void:
	var impede_timer: Timer
	var og_speed: float = target.speed
	
	if !is_instance_valid(target.get_node_or_null("impede_timer")):
		impede_timer = set_up_timer(target, "impede_timer", dispel_impede.bind(target, og_speed))
	else:
		impede_timer = target.get_node("impede_timer")
	
	if impede_timer.time_left > 0:
		check_and_add(target, "impede", 1, impede_timer.time_left + duration)
		impede_timer.wait_time = impede_timer.time_left + duration
		impede_timer.start(impede_timer.time_left + duration)
		target.update_status_bar()
		return
	
	target.speed = og_speed / 2
	target.default_speed = og_speed / 2
	check_and_add(target, "impede", 1, duration)
	impede_timer.start(duration)
	target.update_status_bar()


func dispel_impede(target: Node, og_speed: float) -> void:
	target.speed = og_speed
	target.default_speed = og_speed
	check_and_add(target, "impede", 0, 0.0)
	target.update_status_bar()


func apply_generation_boost(target: Node, duration: float) -> void:
	var gen_boost_timer: Timer
	if !is_instance_valid(target.get_node_or_null("gen_boost_timer")):
		gen_boost_timer = set_up_timer(target, "gen_boost_timer", dispel_generation_boost.bind(target))
	else:
		gen_boost_timer = target.get_node_or_null("gen_boost_timer")
	
	if gen_boost_timer.time_left > 0:
		gen_boost_timer.start(gen_boost_timer.time_left + duration)
		check_and_add(target, "gen_boost", 1, gen_boost_timer.time_left + duration)
		target.update_status_bar()
		return
	
	target.gen_modifier += 1
	check_and_add(target, "gen_boost", 1, duration)
	gen_boost_timer.start(duration)
	target.update_status_bar()


func dispel_generation_boost(target: Node) -> void:
	target.gen_modifier -= 1
	check_and_add(target, "gen_boost", 0, 0.0)
	target.update_status_bar()


func apply_generation_impede(target: Node, duration: float) -> void:
	var gen_impede_timer: Timer
	if !is_instance_valid(target.get_node_or_null("gen_impede_timer")):
		gen_impede_timer = set_up_timer(target, "gen_impede_timer", dispel_generation_boost.bind(target))
	else:
		gen_impede_timer = target.get_node_or_null("gen_impede_timer")
	
	if gen_impede_timer.time_left > 0:
		check_and_add(target, "gen_impede", 1, gen_impede_timer.time_left + duration)
		gen_impede_timer.start(gen_impede_timer.time_left + duration)
		target.update_status_bar()
		return
	
	target.gen_modifier -= 0.5
	gen_impede_timer.start(duration)
	check_and_add(target, "gen_impede", 1, duration)
	target.update_status_bar()


func dispel_generation_impede(target: Node) -> void:
	target.gen_modifier += 0.5
	check_and_add(target, "gen_impede", 0, 0.0)
	target.update_status_bar()


func apply_flame(target: Node, duration: float) -> void:
	var flame_timer: Timer
	var damage_timer:Timer
	
	if !is_instance_valid(target.get_node_or_null("flame_timer")):
		damage_timer = set_up_timer(target, "damage_timer", damage_flame.bind(target), false)
		flame_timer = set_up_timer(target, "flame_timer", dispel_flame.bind(target, damage_timer))
	else:
		flame_timer = target.get_node_or_null("flame_timer")
		damage_timer = target.get_node_or_null("damage_timer")
	
	if flame_timer.time_left > 0:
		check_and_add(target, "flame", 1, flame_timer.time_left + duration)
		flame_timer.start(flame_timer.time_left + duration)
		target.update_status_bar()
		return
	
	flame_timer.start(duration)
	check_and_add(target, "flame", 1, duration)
	target.update_status_bar()
	
	damage_timer.wait_time = 0.5
	damage_timer.start()


func dispel_flame(target: Node, damage_timer: Timer) -> void:
	if is_instance_valid(damage_timer):
		damage_timer.stop()
	
	check_and_add(target, "flame", 0, 0.0)
	target.update_status_bar()


func damage_flame(target: Node) -> void:
	if target.has_method("take_damage"):
		target.take_damage(2)


func apply_heat(target: Node, stack: int) -> void:
	var heat_timer: Timer
	if !is_instance_valid(target.get_node_or_null("heat_timer")):
		heat_timer = set_up_timer(target, "impede_timer", dispel_heat.bind(target))
	else:
		heat_timer = target.get_node_or_null("heat_timer")
	
	if heat_timer.time_left > 0:
		heat_timer.start(5)
		target.gen_modifier -= 0.1 * target.status_effects["heat"]["stack"]
		target.speed -= 40 * target.status_effects["heat"]["stack"]
		target.status_effects["heat"]["stack"] += stack
		target.status_effects["heat"]["time"] = 5
		if target.status_effects["heat"]["stack"] > 10:
			target.status_effects["heat"]["stack"] = 10
			apply_meltdown(target)
		target.speed += 40 * target.status_effects["heat"]["stack"]
		target.gen_modifier += 0.1 * target.status_effects["heat"]["stack"]
		target.update_status_bar()
		return
	
	if "heat" in target.status_effects:
		target.gen_modifier -= 0.1 * target.status_effects["heat"]["stack"]
		target.speed -= 40 * target.status_effects["heat"]["stack"]
		target.status_effects["heat"]["stack"] += stack
		target.status_effects["heat"]["time"] = 5
		target.gen_modifier += 0.1 * target.status_effects["heat"]["stack"]
		target.speed += 40 * target.status_effects["heat"]["stack"]
	else:
		target.status_effects["heat"] = {"stack": 0, "time": 0.0}
		target.status_effects["heat"]["stack"] = stack
		target.status_effects["heat"]["time"] = 5
		target.gen_modifier += 0.1 * stack
		target.speed += 40 * target.status_effects["heat"]["stack"]
	target.update_status_bar()
	
	heat_timer.start(5)


func dispel_heat(target: Node) -> void:
	target.gen_modifier -= 0.1 * target.status_effects["heat"]["stack"]
	target.speed -= 40 * target.status_effects["heat"]["stack"]
	target.status_effects["heat"]["stack"] = 0
	target.status_effects["heat"]["time"] = 0.0
	target.update_status_bar()
	dispel_meltdown(target)


func apply_meltdown(target: Node) -> void:
	check_and_add(target, "meltdown", 1)
	target.update_status_bar()


func dispel_meltdown(target: Node) -> void:
	check_and_add(target, "meltdown", 0)
	target.update_status_bar()


func apply_reinforce(target: Node, stack: int) -> void:
	check_and_add(target, "reinforce", stack, 0.0, "additive")
	target.update_status_bar()


func dispel_reinforce(target: Node) -> void:
	check_and_add(target, "reinforce", 0)
	target.update_status_bar()


func apply_fragile(target: Node, stack: int) -> void:
	check_and_add(target, "fragile", stack, 0.0, "additive")
	target.update_status_bar()


func dispel_fragile(target: Node) -> void:
	check_and_add(target, "fragile", 0)
	target.update_status_bar()


func apply_bullet_speed_boost(target: Node) -> void:
	check_and_add(target, "bullet_speed_boost", 1)
	target.update_status_bar()


func dispel_bullet_speed_boost(target: Node) -> void:
	check_and_add(target, "bullet_speed_boost", 0)
	target.update_status_bar()


func apply_heat_boss(target: Node) -> void:
	check_and_add(target, "heat_boss", 1)
	target.update_status_bar()


func apply_endurance(target: Node, stack: int) -> void:
	check_and_add(target, "endurance", stack, 0.0, "additive")
	target.update_status_bar()


func dispel_endurance(target: Node, stack: int) -> void:
	check_and_add(target, "endurace", stack)
	target.update_status_bar()


func apply_self_repair(target: Node, duration: float, amount: int) -> void:
	var heal_timer:Timer = set_up_timer(target, "heal_timer", self_repair.bind(target, amount))
	check_and_add(target, "self_repair", 1)
	heal_timer.wait_time = duration
	heal_timer.start()
	target.update_status_bar()


func self_repair(target: Node, amount: int) -> void:
	if target.has_method("take_damage"):
		target.take_damage(amount)


func apply_charge(target: Node, stack: int) -> void:
	check_and_add(target, "charge", stack, 0.0, "additive")
	target.update_status_bar()


func dispel_charge(target: Node) -> void:
	check_and_add(target, "charge", 0)
	target.update_status_bar()
