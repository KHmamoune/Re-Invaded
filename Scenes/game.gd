extends Node2D


@onready var scrap_label: Node = $PlayerUI/UI/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer/Scrap
@onready var time_label: Node = $PlayerUI/UI/MarginContainer2/MarginContainer/VBoxContainer/Time
@onready var energy_bar: Node = $PlayerUI/UI/MarginContainer/MarginContainer/VBoxContainer/Energy
@onready var energy_label: Node = $PlayerUI/UI/MarginContainer/MarginContainer/VBoxContainer/Energy/Label
@onready var health_text_label: Node = $PlayerUI/UI/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/HpText
@onready var health_label: Node = $PlayerUI/UI/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/HpValue
@onready var deck_ui: Node = $PlayerUI/UI/MarginContainer/MarginContainer2/DeckUI
@onready var modifier_ui: Node = $PlayerUI/UI/MarginContainer2/MarginContainer/VBoxContainer/Modifiers_ui
@onready var graze_bar: Node = $PlayerUI/UI/MarginContainer2/MarginContainer/VBoxContainer/Panel/TextureProgressBar
@onready var flash_effect: Node = $Flash/FlashEffect
@onready var background: Node = $Background

@onready var victory_screen: PackedScene = preload("res://Scenes/victory_screen.tscn")
@onready var deck_screen: Node = preload("res://Scenes/deck_menu.tscn").instantiate()
@onready var rest_screen: PackedScene = preload("res://Scenes/rest.tscn")
@onready var act_change_screen: PackedScene = preload("res://Scenes/area_change_ui.tscn")
@onready var enemy: PackedScene = preload("res://Scenes/turret.tscn")
@onready var en_map: Battle.EnemyMap
var victory_canvas: CanvasLayer = CanvasLayer.new()
var map_canvas: CanvasLayer = CanvasLayer.new()
var rest_canvas: CanvasLayer = CanvasLayer.new()
var deck_canvas: CanvasLayer = CanvasLayer.new()
var dialogue_canvas: CanvasLayer = CanvasLayer.new()
var act_change_canvas: CanvasLayer = CanvasLayer.new()
var enemies_dead: bool = false
var prev_state: String
var prev_focus: Node
var player: Node
var map_ui: Node
var time: int = 0
var scrap_count: int = 0
var command_state: String = "hidden"


func _ready() -> void:
	update_scrap(200, "increment")
	$Time.start()
	player = preload("res://Scenes/player.tscn").instantiate()
	
	var color_cards: Array
	var color_starting_cards: Array
	var color_modifier: Modifiers.Modifier
	var color_special_attack: Card.AttackPattren
	
	match gv.player_color:
		"blue":
			player.get_node("Sprite2D").texture = preload("res://Images/Characters/code_blue.png")
			color_cards = gv.blue_cards
			color_starting_cards = gv.blue_starting_cards
			color_modifier = gv.blue_modifier1
			color_special_attack = gv.blue_special_attack
		"orange":
			player.get_node("Sprite2D").texture = preload("res://Images/Characters/code_orange.png")
			color_cards = gv.orange_cards
			color_starting_cards = gv.orange_starting_cards
			color_modifier = gv.orange_modifier1
			color_special_attack = gv.blue_special_attack
		"red":
			player.get_node("Sprite2D").texture = preload("res://Images/Characters/code_red.png")
			color_cards =  gv.red_cards
			color_starting_cards = gv.red_starting_cards
			color_modifier = gv.red_modifier1
			color_special_attack = gv.blue_special_attack
		"green":
			player.get_node("Sprite2D").texture = preload("res://Images/Characters/code_green.png")
			color_cards = gv.green_cards
			color_starting_cards = gv.green_starting_cards
			color_modifier = gv.green_modifier1
			color_special_attack = gv.blue_special_attack
		"yellow":
			player.get_node("Sprite2D").texture = preload("res://Images/Characters/code_yellow.png")
			color_cards =  gv.yellow_cards
			color_starting_cards = gv.yellow_starting_cards
			color_modifier = gv.yellow_modifier1
			color_special_attack = gv.blue_special_attack
		"violet":
			player.get_node("Sprite2D").texture = preload("res://Images/Characters/code_violet.png")
			color_cards =  gv.violet_cards
			color_starting_cards = gv.violet_starting_cards
			color_modifier = gv.violet_modifier1
			color_special_attack = gv.blue_special_attack
	
	# asigning the appropriate starting kit to the player
	for card: Card.CardStats in color_cards:
		gv.cards.append(card)
	for card: Card.CardStats in color_starting_cards:
		player.full_deck.append(card)
	player.add_modifier(color_modifier)
	player.special_attack = color_special_attack
	
	player.add_to_group("player")
	player.position = Vector2(575, 600)
	
	player.freeze.connect(_on_player_freeze)
	player.unfreeze.connect(_on_player_unfreeze)
	player.update_ui.connect(_on_player_update_ui)
	player.show_shuffle_delay.connect(_on_player_show_shuffle_delay)
	player.update_graze_bar.connect(_on_player_update_graze_bar)
	add_child(player)
	gv.player = player
	
	# generating the map and setting the player deck
	reload_map()
	gv.current_scene = self
	add_deck(player.full_deck)
	
	$Animations.play("start_trans")


func _process(_delta: float) -> void:
	energy_bar.value = player.energy
	var energy_text: String = str(int(player.energy) % player.energy_max)
	
	if player.energy >= player.energy_max:
		energy_text = str(player.energy_max)
	
	energy_label.text = energy_text + " / " + str(player.energy_max)


func _input(event: InputEvent) -> void:
	if player.state != "post_combat" and player.state != "in_map" and player.state != "in_rest" and player.state != "in_deck":
		return
	
	if event.is_action_pressed("show_map") and deck_screen.state == "hidden":
		change_map_state()
	
	if event.is_action_pressed("show_deck") and map_ui.state == "hidden":
		change_deck_state()
	
	if event.is_action_pressed("command"):
		if command_state == "hidden":
			$CmdLayer.show()
			command_state = "visible"
			$CmdLayer/cmd.grab_focus()
			player.state = "CMD"
		else:
			$CmdLayer.hide()
			command_state = "hidden"
			$CmdLayer/cmd.release_focus()
			player.state = "post_combat"


func _on_player_update_ui() -> void:
	health_label.text = str(player.hp) + " / " + str(player.max_hp)
	
	if float(player.hp) / player.max_hp <= 0.25:
		health_text_label.set("theme_override_colors/font_color", Color.RED)
		health_label.set("theme_override_colors/font_color", Color.RED)
	elif float(player.hp) / player.max_hp <= 0.5:
		health_text_label.set("theme_override_colors/font_color", Color.ORANGE)
		health_label.set("theme_override_colors/font_color", Color.ORANGE)
	else:
		health_text_label.set("theme_override_colors/font_color", Color.GREEN)
		health_label.set("theme_override_colors/font_color", Color.GREEN)
	
	deck_ui.deck = player.deck
	deck_ui.current_hand = player.current_hand
	deck_ui.update_deck()
	modifier_ui.update(player.modifiers)


func _on_player_update_graze_bar(graze_points: int) -> void:
	graze_bar.value = graze_points


func _on_player_show_shuffle_delay(delay: float) -> void:
	deck_ui.show_delay(delay)


func _on_player_freeze() -> void:
	flash_effect.visible = true


func _on_player_unfreeze() -> void:
	flash_effect.visible = false


func _on_enemy_death(scrap: int) -> void:
	update_scrap(scrap, "increment")
	for modifier: Modifiers.Modifier in player.modifiers["kill"]:
		modifier.play(player)
	
	await get_tree().create_timer(0.1).timeout
	
	if get_tree().get_nodes_in_group("enemy").is_empty() and not enemies_dead:
		modulate_background(0)
		enemies_dead = true
		for bullet: Node in get_tree().get_nodes_in_group("bullet"):
			bullet.fade_out()
		add_victory_screen()


func update_scrap(scrap: int, method: String) -> void:
	var i: int = scrap_count
	if method == "increment":
		scrap_count = scrap_count + scrap
	else:
		scrap_count = scrap_count - scrap
	
	while true:
		scrap_label.text = str(i)
		if (i <= scrap_count) == (i >= scrap_count):
			break
		
		if method == "increment":
			i += 1
		elif method == "decrement":
			i -= 1
		
		await get_tree().create_timer(0.01).timeout


func add_victory_screen() -> void:
	var vs: Node = victory_screen.instantiate()
	await get_tree().create_timer(1).timeout
	player.state = "cutscene"
	vs.pick_card.connect(_on_pick_card)
	vs.pick_modifier.connect(_on_pick_modifier)
	vs.skiped_card.connect(_on_skiped_card)
	
	victory_canvas.add_child(vs)
	victory_canvas.layer = 2
	vs.position.x = 0
	add_child(victory_canvas)


func add_rest_screen() -> void:
	var rest_ui: Node = rest_screen.instantiate()
	rest_ui.bought_card.connect(_on_bought_card)
	rest_ui.bought_modifier.connect(_on_bought_modifier)
	rest_ui.healed_player.connect(_on_healed_player)
	rest_canvas.add_child(rest_ui)
	rest_canvas.layer = 0
	add_child(rest_canvas)


# adding the act choise screen after boss fights
func add_act_change_screen() -> void:
	var acs: Node = act_change_screen.instantiate()
	await get_tree().create_timer(0.5).timeout
	player.state = "cutscene"
	acs.connect("act_chosen", Callable(_on_act_choose))
	
	# this block of code will need to be changed for future acts
	match gv.player_color:
		"blue", "orange", "red": 
			acs.data = gv.even_areas[2]
		"green", "yellow", "violet": 
			acs.data = gv.even_areas[1]
	
	act_change_canvas.add_child(acs)
	act_change_canvas.layer = 2
	add_child(act_change_canvas)


func _on_act_choose(act_name: String) -> void:
	gv.act = act_name
	var t: Tween = create_tween()
	t.tween_property(act_change_canvas.get_child(0), "modulate:a", 0, 0.4)
	t.tween_callback(act_change_canvas.get_child(0).queue_free)
	
	await play_trans_start()
	background.remove_child(background.get_child(1))
	background.add_child(gv.area_backgrounds[act_name].instantiate())
	background.get_child(1).position = Vector2(226, -176)
	await play_trans_end("post_combat")
	reload_map()


func reload_map() -> void:
	map_canvas.queue_free()
	map_canvas = CanvasLayer.new()
	
	var map: Map.MapData = Map.MapData.new()
	gv.current_map = map
	add_map(map)


func _on_pick_card(card: Node) -> void:
	card.get_parent().release_focus()
	player.full_deck.append(card.new_card)
	player.shuffle_deck(0.01)
	
	var t1: Tween = create_tween()
	var t2: Tween = create_tween()
	t1.tween_property(card, "position:y", -50, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t1.tween_property(card, "position:y", 600, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t1.parallel().tween_property(card, "scale", Vector2(0.6, 0.6), 1)
	t2.tween_property(victory_canvas.get_child(0), "modulate:a", 0, 1.2)
	
	await t1.finished
	await t2.finished
	remove_child(victory_canvas)
	victory_canvas.get_child(0).queue_free()
	deck_screen.update(player.full_deck, player.modifiers)
	await get_tree().create_timer(0.1).timeout
	player.state = "post_combat"
	
	if gv.current_room_type == Map.Type.BOSS:
		player.state = "in_dialogue"
		play_cutscene()


func _on_pick_modifier(modifier: Node) -> void:
	modifier.get_parent().release_focus()
	player.add_modifier(modifier.new_modifier)
	deck_screen.update(player.full_deck, player.modifiers)
	var curr_victory_screen: Node = victory_canvas.get_child(0)
	
	var t1: Tween = create_tween()
	var t2: Tween = create_tween()
	t1.tween_property(modifier, "position:y", -50, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t1.tween_property(modifier, "position:y", 600, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t1.parallel().tween_property(modifier, "scale", Vector2(0.6, 0.6), 1)
	t2.tween_property(curr_victory_screen.get_node("VBoxContainer/reward_cards"), "modulate:a", 0, 1.2)
	await t2.finished
	curr_victory_screen.get_node("VBoxContainer/reward_cards").get_child(0).queue_free()
	curr_victory_screen.generate_cards()
	create_tween().tween_property(curr_victory_screen.get_node("VBoxContainer/Text"), "modulate:a", 1, 0.5)
	create_tween().tween_property(curr_victory_screen.get_node("VBoxContainer/reward_cards"), "modulate:a", 1, 0.5)


func _on_skiped_card() -> void:
	remove_child(victory_canvas)
	victory_canvas.get_child(0).queue_free()
	player.shuffle_deck(0.01)
	player.state = "post_combat"


func _on_bought_card(card: Node, price: int) -> void:
	if price <= scrap_count:
		player.full_deck.append(card.new_card)
		update_scrap(price, "decrement")
		card.get_node("../").queue_free()
		player.shuffle_deck(0.01)
		deck_screen.update(player.full_deck, player.modifiers)


func _on_bought_modifier(modifier: Node, price: int) -> void:
	if price <= scrap_count:
		player.add_modifier(modifier.new_modifier)
		update_scrap(price, "decrement")
		modifier.get_node("../").queue_free()
		modifier_ui.update(player.modifiers)
		deck_screen.update(player.full_deck, player.modifiers)


func _on_healed_player(price: int) -> void:
	if price < scrap_count and player.hp < player.max_hp:
		update_scrap(price, "decrement")
		player.hp += 1
		player.emit_signal("update_ui")


func _on_dialogue_end() -> void:
	await get_tree().create_timer(0.1).timeout
	player.state = "post_combat"
	if gv.act == "Outer Space":
		add_act_change_screen()


func play_cutscene() -> void:
	match gv.act:
		"Outer Space":
			play_dialogue(gv.story_script["code_" + gv.player_color]["security_system_defeat"])
		_:
			player.state = "post_combat"


func play_dialogue(script: Array) -> void:
	var dialogue_screen: Node = preload("res://Scenes/dialogue_ui.tscn").instantiate()
	dialogue_screen.dialogue_script = script
	dialogue_screen.connect("dialogue_done", _on_dialogue_end)
	dialogue_canvas.add_child(dialogue_screen)
	add_child(dialogue_canvas)


func spawn_enemies() -> void:
	for i in range(len(en_map.enemies)):
		var new_enemy: Node = en_map.enemies[i]["enemy"].instantiate()
		
		if en_map.enemies[i].has("fliped"):
			new_enemy.fliped = en_map.enemies[i]["fliped"]
		
		if en_map.enemies[i].has("rotate"):
			new_enemy.rotate_by(en_map.enemies[i]["rotate"])
		
		new_enemy.dead.connect(Callable(_on_enemy_death))
		new_enemy.add_to_group("enemy")
		new_enemy.global_position = en_map.positions[i] + Vector2(225,0)
		add_child(new_enemy)


func add_map(map: Map.MapData) -> void:
	var new_map: Node = preload("res://Scenes/map.tscn").instantiate()
	map_canvas.add_child(new_map)
	new_map.position -= Vector2(0.0, 650)
	
	map.generate_map()
	new_map.selected.connect(on_room_select)
	for layer: Array in map.map_data:
		for room: Map.Room in layer:
			var new_room: Node = preload("res://Scenes/map_room.tscn").instantiate()
			new_room.add_to_group("rooms")
			new_room.set_room(room)
			new_map.get_node("Rooms").add_child(new_room)
			
			if room.y_cord == 0 and room.type != 0:
				new_room.set_availiable(true)
			
			for next_room: Map.Room in room.next_rooms:
				var link: Line2D = create_line(room, next_room)
				link.z_index = new_room.z_index - 1
				new_map.get_node("Rooms").add_child(link)
	
	new_map.place_cursor()
	add_child(map_canvas)
	map_ui = new_map


#adding the deck menu to the scene tree
func add_deck(deck: Array) -> void:
	deck_canvas.add_child(deck_screen)
	deck_screen.position -= Vector2(0.0, -650)
	add_child(deck_canvas)
	deck_screen.update(deck, player.modifiers)


func create_line(room: Map.Room, next_room: Map.Room) -> Line2D:
	var link: Line2D = Line2D.new()
	link.add_point(Vector2(room.x_position, room.y_position))
	if next_room.type == Map.Type.BOSS:
		link.add_point(Vector2(next_room.x_position, next_room.y_position + 100))
	else:
		link.add_point(Vector2(next_room.x_position, next_room.y_position))
	link.default_color = Color.AQUA
	return link


# handles the outcome when the player picks a room on the map
func on_room_select(room: Map.Room) -> void:
	enemies_dead = false
	for curr_room in get_tree().get_nodes_in_group("rooms"):
		curr_room.set_availiable(false)
		if room.next_rooms.has(curr_room.room):
			curr_room.set_availiable(true)
	
	change_map_state()
	
	if rest_canvas.get_child_count() > 0:
		rest_canvas.get_child(0).queue_free()
		remove_child(rest_canvas)
	
	await play_trans_start()
	gv.current_room_type = room.type
	
	if room.type == 1:
		modulate_background(100)
		play_trans_end("combat")
		en_map = gv.en_maps[gv.act][floor(randf() * len(gv.en_maps[gv.act]))]
		spawn_enemies()
		
	elif room.type == 2:
		modulate_background(100)
		play_trans_end("combat")
		en_map = gv.res_maps[floor(randf() * len(gv.res_maps))]
		spawn_enemies()
		
	elif room.type == 3:
		play_trans_end("in_rest")
		add_rest_screen()
		
	elif room.type == 4:
		modulate_background(100)
		play_trans_end("combat")
		en_map = gv.mini_maps[gv.act][floor(randf() * len(gv.mini_maps[gv.act]))]
		spawn_enemies()
		
	elif room.type == 5:
		modulate_background(100)
		play_trans_end("combat")
		en_map = gv.boss_maps[gv.boss_maps[gv.act]]
		spawn_enemies()


# changing the map state whether it is hidden or opened
func change_map_state() -> void:
	if map_ui.state == "hidden":
		create_tween().tween_property(map_ui, "position", Vector2(0,0), 0.5)
		map_ui.state = "visible"
		prev_state = player.state
		player.state = "in_map"
	elif map_ui.state == "visible":
		create_tween().tween_property(map_ui, "position", Vector2(0,-650), 0.5)
		map_ui.state = "hidden"
		player.state = prev_state


func change_deck_state() -> void:
	if deck_screen.state == "hidden":
		create_tween().tween_property(deck_screen, "position", Vector2(0,0), 0.5)
		deck_screen.state = "visible"
		prev_state = player.state
		player.state = "in_deck"
		prev_focus = get_viewport().gui_get_focus_owner()
		deck_screen.get_node("PanelContainer/VBoxContainer/HBoxContainer2/ScrollContainer/Cards").get_child(0).grab_focus()
	elif deck_screen.state == "visible":
		create_tween().tween_property(deck_screen, "position", Vector2(0,650), 0.5)
		deck_screen.state = "hidden"
		player.state = prev_state
		if prev_focus != null:
			prev_focus.grab_focus()


func _on_time_timeout() -> void:
	time += 1
	var h: int = time / 3600
	var m: int = (time / 60) % 60
	var s: int = time % 60
	time_label.text = '%02d : %02d : %02d' % [h, m, s]


func play_trans_start() -> void:
	#remove all of the player status effects
	player.status_effects = {}
	player.update_status_bar()
	#play the blast off animation
	player.state = "cutscene"
	Audio.play_sfx(Audio.sfx_blast_off)
	var tween: Tween = create_tween()
	tween.tween_property(player, "position:y", player.position.y + 30, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "position:y", -100, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
	$Animations.play("slide_trans")
	await $Animations.animation_finished
	player.energy = 0
	restore_cards()
	player.shuffle_deck(0.01)


func restore_cards() -> void:
	for c: Card.CardStats in player.exhausted_cards:
		player.full_deck.append(c)
		player.exhausted_cards.erase(c)


func play_trans_end(state: String) -> void:
	player.position = Vector2(575, 800)
	$Animations.play("start_trans")
	await $Animations.animation_finished
	
	var tween: Tween = create_tween()
	tween.tween_property(player, "position:y", 450, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "position", Vector2(575, 600), 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	for en in get_tree().get_nodes_in_group("enemy"):
		en.start()
	player.state = state
	
	if state == "combat":
		for modifier: Modifiers.Modifier in player.modifiers["combat_start"]:
			modifier.play(player) 


func _on_cmd_add_card_to_player(card: RefCounted) -> void:
	player.deck.append(card)
	player.full_deck.append(card)
	_on_player_update_ui()


func modulate_background(value: float) -> void:
	var t:Tween = create_tween()
	t.tween_property(background.get_node("DarkEffect"), "color", Color(0, 0, 0, value/255), 0.5)
