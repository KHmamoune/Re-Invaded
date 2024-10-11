extends Node2D


@onready var scrap_label: Node = $PlayerUI/UI/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer/Scrap
@onready var time_label: Node = $PlayerUI/UI/MarginContainer2/MarginContainer/VBoxContainer/Time
@onready var energy_bar: Node = $PlayerUI/UI/MarginContainer/MarginContainer/VBoxContainer/Energy
@onready var energy_label: Node = $PlayerUI/UI/MarginContainer/MarginContainer/VBoxContainer/Energy/Label
@onready var health_label: Node = $PlayerUI/UI/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/HpValue
@onready var deck_ui: Node = $PlayerUI/UI/MarginContainer/MarginContainer2/DeckUI
@onready var modifier_ui: Node = $PlayerUI/UI/MarginContainer2/MarginContainer/VBoxContainer/Modifiers_ui
@onready var flash_effect: Node = $Flash/FlashEffect

@onready var victory_screen: PackedScene = preload("res://Scenes/victory_screen.tscn")
@onready var deck_screen: Node = preload("res://Scenes/deck_menu.tscn").instantiate()
@onready var rest_screen: PackedScene = preload("res://Scenes/rest.tscn")
@onready var enemy: PackedScene = preload("res://Scenes/turret.tscn")
@onready var en_map: Battle.EnemyMap = gv.en_maps[floor(randf() * len(gv.en_maps))]
var victory_canvas: CanvasLayer = CanvasLayer.new()
var map_canvas: CanvasLayer = CanvasLayer.new()
var rest_canvas: CanvasLayer = CanvasLayer.new()
var deck_canvas: CanvasLayer = CanvasLayer.new()
var dialogue_canvas: CanvasLayer = CanvasLayer.new()
var enemies_dead: bool = false
var prev_state: String
var prev_focus: Node
var player: Node
var map_ui: Node
var time: int = 0
var scrap_count: int = 0


func _ready() -> void:
	update_scrap(200, "increment")
	$Time.start()
	player = preload("res://Scenes/player.tscn").instantiate()
	
	match gv.player_color:
		"blue":
			player.get_node("Sprite2D").texture = preload("res://Images/Characters/code_blue.png")
			for card: Card.CardStats in gv.blue_cards:
				gv.cards.append(card)
			player.add_modifier(gv.blue_modifier1)
		"orange":
			player.get_node("Sprite2D").texture = preload("res://Images/Characters/code_orange.png")
			for card: Card.CardStats in gv.orange_cards:
				gv.cards.append(card)
			player.add_modifier(gv.orange_modifier1)
		"red":
			player.get_node("Sprite2D").texture = preload("res://Images/Characters/code_red.png")
			for card: Card.CardStats in gv.red_cards:
				gv.cards.append(card)
			player.add_modifier(gv.red_modifier1)
		"green":
			player.get_node("Sprite2D").texture = preload("res://Images/Characters/code_green.png")
			for card: Card.CardStats in gv.green_cards:
				gv.cards.append(card)
			player.add_modifier(gv.green_modifier1)
		"yellow":
			player.get_node("Sprite2D").texture = preload("res://Images/Characters/code_yellow.png")
			for card: Card.CardStats in gv.yellow_cards:
				gv.cards.append(card)
			player.add_modifier(gv.yellow_modifier1)
		"violet":
			player.get_node("Sprite2D").texture = preload("res://Images/Characters/code_violet.png")
			for card: Card.CardStats in gv.violet_cards:
				gv.cards.append(card)
			player.add_modifier(gv.violet_modifier1)
	
	player.add_to_group("player")
	player.position = Vector2(575, 600)
	
	player.freeze.connect(_on_player_freeze)
	player.unfreeze.connect(_on_player_unfreeze)
	player.update_ui.connect(_on_player_update_ui)
	add_child(player)
	
	var map: Map.MapData = Map.MapData.new()
	
	gv.current_map = map
	gv.current_scene = self
	
	add_map(map)
	add_deck(player.full_deck)
	
	map_ui = map_canvas.get_children()[0]
	
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


func _on_player_update_ui() -> void:
	health_label.text = str(player.hp) + " / " + str(player.max_hp)
	deck_ui.deck = player.deck
	deck_ui.current_hand = player.current_hand
	deck_ui.update_deck()
	modifier_ui.update(player.modifiers)


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
		enemies_dead = true
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
	await get_tree().create_timer(1.0).timeout
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


func _on_pick_card(card: Node) -> void:
	card.get_parent().release_focus()
	player.full_deck.append(card.new_card)
	player.shuffle_deck()
	
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
	player.shuffle_deck()
	player.state = "post_combat"


func _on_bought_card(card: Node, price: int) -> void:
	if price <= scrap_count:
		player.full_deck.append(card.new_card)
		update_scrap(price, "decrement")
		card.get_node("../").queue_free()
		player.shuffle_deck()
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


func _on_dialogue_end():
	player.state = "post_combat"


func play_cutscene() -> void:
	match gv.act:
		1:
			play_dialogue(gv.story_script["code_" + gv.player_color]["security_system_defeat"])


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
			new_enemy.rotation_degrees = en_map.enemies[i]["rotate"]
		
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
		play_trans_end("combat")
		en_map = gv.en_maps[floor(randf() * len(gv.en_maps))]
		spawn_enemies()
		
	elif room.type == 2:
		play_trans_end("combat")
		en_map = gv.res_maps[floor(randf() * len(gv.res_maps))]
		spawn_enemies()
		
	elif room.type == 3:
		play_trans_end("in_rest")
		add_rest_screen()
		
	elif room.type == 4:
		play_trans_end("combat")
		en_map = gv.mini_maps[floor(randf() * len(gv.mini_maps))]
		spawn_enemies()
		
	elif room.type == 5:
		play_trans_end("combat")
		en_map = gv.boss_maps[floor(randf() * len(gv.boss_maps))]
		spawn_enemies()


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
	player.shuffle_deck()


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
