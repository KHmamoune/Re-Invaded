extends Node


#info that i need to know globaly
var current_scene: Node
var current_map: Map.MapData
var current_room_type: Map.Type
var player_color: String
var act: String = "Outer Space"
var player: Node 

var game_data: Dictionary = gdt.read_json(gdt.game_data_path)
var story_script: Dictionary = gdt.read_json(gdt.story_script_path)
var card_data: Dictionary = game_data["card_data"]
var mod_data: Dictionary = game_data["modifier_data"]
var area_data: Dictionary = game_data["area_data"]


#areas data
var odd_areas: Array = [area_data["outer_space"],area_data["the_remains"],area_data["the_nest"],area_data["the_heart"]]
var even_areas: Dictionary = {
	1: [area_data["water_facility"],area_data["the_factory"],area_data["red_area"]],
	2: [area_data["pipeworks"],area_data["the_halls"],area_data["the_den"]]
}

var area_backgrounds: Dictionary = {
	"Water Facility": preload("res://Scenes/water_facility_background.tscn") 
}


#bullet presets
var bullet2_preset: Dictionary = {
	"sprite": preload("res://Images/Bullets/bullet2.png"),
	"scale": Vector2(0.3, 0.3),
	"hitbox_scale": Vector2(0.2, 0.25),
	"anm_speed": 0,
	"frames": 1
}

var fire_bullet_preset: Dictionary = {
	"sprite": preload("res://Images/Bullets/fire_bullet.png"),
	"scale": Vector2(0.5, 0.5),
	"hitbox_scale": Vector2(1.4, 0.5),
	"anm_speed": 0.2,
	"frames": 5
}


#loading enemies scenes
var scrap_pile: PackedScene = preload("res://Scenes/scrap_pile.tscn")
var turret: PackedScene = preload("res://Scenes/turret.tscn")
var maxim: PackedScene = preload("res://Scenes/maxim.tscn")
var hex_shooter: PackedScene = preload("res://Scenes/hex_shooter.tscn")
var mine: PackedScene = preload("res://Scenes/mine.tscn")
var radar: PackedScene = preload("res://Scenes/radar.tscn")
var splice: PackedScene = preload("res://Scenes/splice.tscn")
var starly: PackedScene = preload("res://Scenes/starly.tscn")
var security_system: PackedScene = preload("res://Scenes/security_system.tscn")
var code_blue_boss: PackedScene = preload("res://Scenes/code_blue_boss.tscn")
var code_orange_boss: PackedScene = preload("res://Scenes/code_orange_boss.tscn")
var code_red_boss: PackedScene = preload("res://Scenes/code_red_boss.tscn")
var code_green_boss: PackedScene = preload("res://Scenes/code_green_boss.tscn")
var code_yellow_boss: PackedScene = preload("res://Scenes/code_yellow_boss.tscn")
var code_violet_boss: PackedScene = preload("res://Scenes/code_violet_boss.tscn")


#loading status effects icons
var status_icons: Dictionary = {
	"flame": preload("res://Images/Icons/flame.png"),
	"impede": preload("res://Images/Icons/impede.png"),
	"gen_boost": preload("res://Images/Icons/gen_boost.png"),
	"heat": preload("res://Images/Icons/heat.png"),
	"reinforce": preload("res://Images/Icons/reinforced.png"),
	"endurance": preload("res://Images/Icons/endurance.png"),
	"fragile": preload("res://Images/Icons/fragile.png"),
	"self_repair": preload("res://Images/Icons/self_repair.png"),
	"bullet_speed_boost": preload("res://Images/Icons/bullet_speed_boost.png"),
	"gen_impede": preload("res://Images/Icons/gen_impede.png"),
	"charge": preload("res://Images/Icons/charge.png"),
}


#enemy maps and such
#syntax: Battle.EnemyMap.new([{"enemy": *enemy*}], ["enemy_position"])
var os_en_map1: Battle.EnemyMap = Battle.EnemyMap.new([
	{ "enemy": maxim },
	{ "enemy": maxim },
	{ "enemy": turret },
	{ "enemy": turret }
	], [Vector2(275, 400),Vector2(425, 400),Vector2(250, 150),Vector2(450, 150)])

var os_en_map2: Battle.EnemyMap = Battle.EnemyMap.new([
	{ "enemy": mine },
	{ "enemy": mine },
	{ "enemy": mine },
	{ "enemy": mine },
	{ "enemy": mine },
	{ "enemy": mine },
	{ "enemy": hex_shooter },
	{ "enemy": hex_shooter, "fliped": true }
	], [Vector2(125,200), Vector2(200,200), Vector2(275,200), Vector2(425,200), Vector2(500,200), Vector2(575,200), Vector2(200, 100), Vector2(500, 100)])

var os_en_map3: Battle.EnemyMap = Battle.EnemyMap.new([
	{ "enemy": hex_shooter },
	{ "enemy": hex_shooter },
	{ "enemy": turret, "rotate": -45 },
	{ "enemy": turret, "rotate": 45 }
	], [Vector2(275, 200),Vector2(425, 200),Vector2(150, 300),Vector2(550, 300)])

var os_en_map4: Battle.EnemyMap = Battle.EnemyMap.new([
	{ "enemy": turret, "rotate": -5 },
	{ "enemy": turret, "rotate": -10 },
	{ "enemy": turret, "rotate": 10 },
	{ "enemy": turret, "rotate": 5 },
	{ "enemy": maxim }
	], [Vector2(100, 200),Vector2(250, 200),Vector2(450, 200),Vector2(600, 200),Vector2(350, 100)])

var en_maps: Dictionary = {
	"Outer Space": [os_en_map1, os_en_map2, os_en_map3, os_en_map4]
}

var os_mini_map1: Battle.EnemyMap = Battle.EnemyMap.new([{ "enemy": radar }], [Vector2(350, 200)])
var os_mini_map2: Battle.EnemyMap = Battle.EnemyMap.new([{ "enemy": starly }], [Vector2(350, 200)])
var os_mini_map3: Battle.EnemyMap = Battle.EnemyMap.new([{ "enemy": splice }, { "enemy": splice }], [Vector2(250, -150), Vector2(450, -150)])

var mini_maps: Dictionary = {
	"Outer Space": [os_mini_map1, os_mini_map2, os_mini_map3]
}

var boss_map1: Battle.EnemyMap = Battle.EnemyMap.new([{ "enemy": security_system }], [Vector2(350, 120)])
var boss_map2: Battle.EnemyMap = Battle.EnemyMap.new([{ "enemy": code_blue_boss }], [Vector2(350, 50)])
var boss_map3: Battle.EnemyMap = Battle.EnemyMap.new([{ "enemy": code_orange_boss }], [Vector2(350, 50)])
var boss_map4: Battle.EnemyMap = Battle.EnemyMap.new([{ "enemy": code_red_boss }], [Vector2(350, 50)])
var boss_map5: Battle.EnemyMap = Battle.EnemyMap.new([{ "enemy": code_green_boss }], [Vector2(350, 50)])
var boss_map6: Battle.EnemyMap = Battle.EnemyMap.new([{ "enemy": code_yellow_boss }], [Vector2(350, 50)])
var boss_map7: Battle.EnemyMap = Battle.EnemyMap.new([{ "enemy": code_violet_boss }], [Vector2(350, 50)])

var boss_maps: Dictionary = {
	"Outer Space": boss_map2,
	"Water Facility": boss_map2,
	"The Factory": boss_map3,
	"Red Area": boss_map4,
	"Pipeworks": boss_map5,
	"The Halls": boss_map6,
	"The Den": boss_map7,
}

var res_map1: Battle.EnemyMap = Battle.EnemyMap.new([
	{ "enemy": scrap_pile }, 
	{ "enemy": scrap_pile }, 
	{ "enemy": scrap_pile }
	], [Vector2(350, 200), Vector2(150, 230), Vector2(550, 230)])
	
var res_map2: Battle.EnemyMap = Battle.EnemyMap.new([
	{ "enemy": scrap_pile },
	{ "enemy": scrap_pile },
	{ "enemy": scrap_pile },
	{ "enemy": scrap_pile }
	], [Vector2(150, 150), Vector2(300, 200), Vector2(400, 200), Vector2(550, 150)])
	
var res_map3: Battle.EnemyMap = Battle.EnemyMap.new([
	{ "enemy": scrap_pile },
	{ "enemy": scrap_pile },
	{ "enemy": scrap_pile },
	{ "enemy": scrap_pile },
	], [Vector2(320, 200), Vector2(380, 200), Vector2(100, 250), Vector2(600, 250)])
var res_maps: Array = [res_map1, res_map2, res_map3]

#loading animations for attacks
var animation1: PackedScene = preload("res://Scenes/fire_shockwave.tscn")
var animation2: PackedScene = preload("res://Scenes/special_fire_animation.tscn")
var animation3: PackedScene = preload("res://Scenes/buff_animation.tscn")
var animation4: PackedScene = preload("res://Scenes/debuff_animation.tscn")

var attack_animations: Dictionary = {
	"shockwave": animation1,
	"special_fire": animation2,
	"buff_animation": animation3,
	"debuff_animation": animation4,
}

#character stats
var character_stats: Dictionary = {
	"blue": {
		"hp": 5,
		"speed": 400,
		"energy": 5,
		"gen_modifier": 1,
	},
	"orange": {
		"hp": 6,
		"speed": 350,
		"energy": 4,
		"gen_modifier": 0.8,
	},
	"red": {
		"hp": 4,
		"speed": 450,
		"energy": 5,
		"gen_modifier": 1.2,
	},
	"green": {
		"hp": 8,
		"speed": 300,
		"energy": 4,
		"gen_modifier": 1,
	},
	"yellow": {
		"hp": 4,
		"speed": 500,
		"energy": 6,
		"gen_modifier": 1.4,
	},
	"violet": {
		"hp": 5,
		"speed": 400,
		"energy": 4,
		"gen_modifier": 0.8,
	},
}


#loading bullets and spawnable things
var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
var laser: PackedScene = preload("res://Scenes/laser.tscn")
var bomb: PackedScene = preload("res://Scenes/bomb.tscn")
var explosion: PackedScene = preload("res://Scenes/explosion.tscn")
var shield: PackedScene = preload("res://Scenes/shield.tscn")
var drone: PackedScene = preload("res://Scenes/drone.tscn")

var jam_card: Card.CardStats = Card.CardStats.new(1, card_data["jam"]["title"], card_data["jam"]["image"], card_data["card_types"]["junk"], card_data["jam"]["description"], Color.BLUE_VIOLET, [{}], 0, ["exhaust"])

var sub_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 50, [90, -90], 0.08, 500, [Vector2.ZERO], 1000, 1)
var sub_attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 360, [90], 0.01, 100, [Vector2.ZERO], 800, 1)
var sub_attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 10, 1, [0, 36, 72, 108, 144, 180, 216, 252, 288, 324], 0, 200, [Vector2.ZERO], 200, 1)

var effect1: Card.StatusAffliction = Card.StatusAffliction.new("impede", 2, 1)
var effect2: Card.StatusAffliction = Card.StatusAffliction.new("gen_boost", 2, 1)

var shield1: Card.AttackPattren = Card.AttackPattren.new(shield, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 1)

var drone1: Card.AttackPattren = Card.AttackPattren.new(drone, 2, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 1)

var blue_effect1: Card.StatusAffliction = Card.StatusAffliction.new("reinforce", 0, 1, "buff")
var blue_card1: Card.CardStats = Card.CardStats.new(2, card_data["reinforced_rounds"]["title"], card_data["reinforced_rounds"]["image"], card_data["card_types"]["skill"], card_data["reinforced_rounds"]["description"], Color.CYAN, [{"effect": blue_effect1}], 120, ["reinforce", "exhaust"])
var blue_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 20, [0], 0.05, 1500, [Vector2.ZERO], 1200, 1)
var blue_card2: Card.CardStats = Card.CardStats.new(2, card_data["spray_and_pray"]["title"], card_data["spray_and_pray"]["image"], card_data["card_types"]["attack"], card_data["spray_and_pray"]["description"], Color.CYAN, [{"effect": blue_attack1}])
var blue_attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 6, [0], 0.05, 1800, [Vector2(20, 0), Vector2(-20, 0)], 800, 1)
var blue_card3: Card.CardStats = Card.CardStats.new(1, card_data["dual_fire"]["title"], card_data["dual_fire"]["image"], card_data["card_types"]["attack"], card_data["dual_fire"]["description"], Color.CYAN, [{"effect": blue_attack2}])

var blue_effect2: Card.DeckManipulation = Card.DeckManipulation.new("shuffle")
var blue_card4: Card.CardStats = Card.CardStats.new(1, card_data["reload"]["title"], card_data["reload"]["image"], card_data["card_types"]["skill"], card_data["reload"]["description"], Color.CYAN, [{"effect": blue_effect2}])
var blue_attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [0], 0.1, 1200, [Vector2.ZERO], 1200, 10)
var blue_card5: Card.CardStats = Card.CardStats.new(1, card_data["empty_magazine"]["title"], card_data["empty_magazine"]["image"], card_data["card_types"]["attack"], card_data["empty_magazine"]["description"], Color.CYAN, [{"effect": blue_attack3}])

var orange_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [0], 0.1, 800, [Vector2.ZERO], 800, 5)
var orange_effect1: Card.StatusAffliction = Card.StatusAffliction.new("flame", 5, 1, "debuff")
var flame_card1: Card.CardStats = Card.CardStats.new(1, "", "", "", "", Color.ORANGE, [{"effect": orange_effect1}])
var orange_effect2: Card.StatusAffliction = Card.StatusAffliction.new("heat", 0, 1, "buff")
var orange_card1: Card.CardStats = Card.CardStats.new(1, card_data["flare"]["title"], card_data["flare"]["image"], card_data["card_types"]["attack"], card_data["flare"]["description"], Color.ORANGE, [{"effect": orange_attack1}, {"effect": orange_effect2}], 40, ["flame", "heat"])
var orange_attack2_1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 5, [-10], 0.1, 1200, [Vector2.ZERO], 800, 1)
var orange_attack2_2: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 5, [10], 0.1, 1200, [Vector2.ZERO], 800, 1)
var orange_effect3: Card.StatusAffliction = Card.StatusAffliction.new("flame", 0.6, 1, "debuff")
var flame_card2: Card.CardStats = Card.CardStats.new(1, "", "", "", "", Color.ORANGE, [{"effect": orange_effect3}])
var orange_card2: Card.CardStats = Card.CardStats.new(1, card_data["flame_thrower"]["title"], card_data["flame_thrower"]["image"], card_data["card_types"]["attack"], card_data["flame_thrower"]["description"], Color.ORANGE, [{"effect": orange_attack2_1}, {"delay": 0.4, "effect": orange_attack2_2}, {"delay": 0.4, "effect": orange_attack2_1}, {"delay": 0.4, "effect": orange_attack2_2}], 110, ["flame"])
var orange_attack3: Card.AttackPattren = Card.AttackPattren.new(bomb, 1, 3, [-45], 0.1, 1200, [Vector2.ZERO], 800, 1)
var orange_card3: Card.CardStats = Card.CardStats.new(2, card_data["explosion_shower"]["title"], card_data["explosion_shower"]["image"], card_data["card_types"]["attack"], card_data["explosion_shower"]["description"], Color.ORANGE, [{"effect": orange_attack3}])

var orange_attack4: Card.AttackPattren = Card.AttackPattren.new(explosion, 1, 7, [0], 0.2, 0, [Vector2.ZERO], 1200, 1)
var orange_card4: Card.CardStats = Card.CardStats.new(2, card_data["nuclear_fusion"]["title"], card_data["nuclear_fusion"]["image"], card_data["card_types"]["attack"], card_data["nuclear_fusion"]["description"], Color.ORANGE, [{"effect": orange_attack4}])

var red_attack1_1: Card.AttackPattren = Card.AttackPattren.new(bullet, 4, 1, [5, 2, -2, -5], 0.5, 800, [Vector2(25,0),Vector2(10,-15),Vector2(-10,-15),Vector2(-25,0)], 500, 5)
var red_attack1_2: Card.AttackPattren = Card.AttackPattren.new(bullet, 5, 1, [5, 2.5, 0, -2.5, -5], 0.5, 800, [Vector2.ZERO], 500, 5)
var red_card1: Card.CardStats = Card.CardStats.new(1, card_data["double_burst"]["title"], card_data["double_burst"]["image"], card_data["card_types"]["attack"], card_data["double_burst"]["description"], Color.RED, [{"effect": red_attack1_1}, {"delay": 0.05, "effect": red_attack1_2}])
var red_effect1_1: Card.StatusAffliction = Card.StatusAffliction.new("impede", 2, 1, "debuff")
var red_effect1_2: Card.StatusAffliction = Card.StatusAffliction.new("gen_boost", 2, 1, "buff")
var red_card2: Card.CardStats = Card.CardStats.new(1, card_data["rewire"]["title"], card_data["rewire"]["image"], card_data["card_types"]["skill"], card_data["rewire"]["description"], Color.RED, [{"effect": red_effect1_1}, {"delay": 0.1 ,"effect": red_effect1_2}], 80, ["impede", "generation boost"])
var red_attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 20, 1, [50,45,40,35,30,25,20,15,10,5,-5,-10,-15,-20,-25,-30,-35,-40,-45,-50], 0.1, 1200, [Vector2.ZERO], 800, 2)
var red_card3: Card.CardStats = Card.CardStats.new(1, card_data["fan_shot"]["title"], card_data["fan_shot"]["image"], card_data["card_types"]["attack"], card_data["fan_shot"]["description"], Color.RED, [{"effect": red_attack3}])

var green_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 8, [0], 0.05, 1200, [Vector2.ZERO], 1200, 2)
var green_card1: Card.CardStats = Card.CardStats.new(2, card_data["take_aim"]["title"], card_data["take_aim"]["image"], card_data["card_types"]["attack"], card_data["take_aim"]["description"], Color.GREEN, [{"effect": green_attack1}])
var green_attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 10, [0], 0.05, 900, [Vector2.ZERO], 1200, 4)
var green_sub_shield1: Card.AttackPattren = Card.AttackPattren.new(shield, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 1)
var green_card2: Card.CardStats = Card.CardStats.new(3, card_data["cover_fire"]["title"], card_data["cover_fire"]["image"], card_data["card_types"]["attack"], card_data["cover_fire"]["description"], Color.GREEN, [{"effect": green_attack2}])
var green_shield1: Card.AttackPattren = Card.AttackPattren.new(shield, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 1)
var green_card3: Card.CardStats = Card.CardStats.new(2, card_data["force_field"]["title"], card_data["force_field"]["image"], card_data["card_types"]["defence"], card_data["force_field"]["description"], Color.GREEN, [{"effect": green_shield1}])
var green_shield2: Card.AttackPattren = Card.AttackPattren.new(shield, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 1)
var green_card4: Card.CardStats = Card.CardStats.new(0, card_data["deflection"]["title"], card_data["deflection"]["image"], card_data["card_types"]["defence"], card_data["deflection"]["description"], Color.GREEN, [{"effect": green_shield2}])

var green_effect1: Card.StatusAffliction = Card.StatusAffliction.new("endurance", 0, 2, "buff")
var green_card5: Card.CardStats = Card.CardStats.new(2, card_data["withstand"]["title"], card_data["withstand"]["image"], card_data["card_types"]["defence"], card_data["withstand"]["description"], Color.GREEN, [{"effect": green_effect1}], 150, ["endurance", "exhaust"])
var green_effect2: Card.StatusAffliction = Card.StatusAffliction.new("charge", 0, 1, "buff")
var green_card6: Card.CardStats = Card.CardStats.new(1, card_data["charge_up"]["title"], card_data["charge_up"]["image"], card_data["card_types"]["skill"], card_data["charge_up"]["description"], Color.GREEN, [{"effect": green_effect2}], 150, ["charge"])
var green_card7: Card.CardStats = Card.CardStats.new(3, card_data["static_discharge"]["title"], card_data["static_discharge"]["image"], card_data["card_types"]["attack"], card_data["static_discharge"]["description"], Color.GREEN, [{"effect": Card.static_discharge}], 150, ["charge"])

var yellow_sub_attack1: Card.AttackPattren = Card.AttackPattren.new(laser, 1, 1, [0], 0.1, 1200, [Vector2.ZERO], 800, 5)
var yellow_sub_card1: Card.CardStats = Card.CardStats.new(1, card_data["blast"]["title"], card_data["blast"]["image"], card_data["card_types"]["attack"], card_data["blast"]["description"], Color.YELLOW, [{"effect": yellow_sub_attack1}], 0, ["exhaust"])
var yellow_attack1: Card.AttackPattren = Card.AttackPattren.new(laser, 3, 1, [-2, 2, 0], 0.1, 1200, [Vector2.ZERO], 800, 5)
var yellow_card1: Card.CardStats = Card.CardStats.new(1, card_data["shine"]["title"], card_data["shine"]["image"], card_data["card_types"]["attack"], card_data["shine"]["description"], Color.YELLOW, [{"effect": yellow_attack1}])
var yellow_attack2: Card.AttackPattren = Card.AttackPattren.new(laser, 2, 2, [-45, 45], 0.5, 1200, [Vector2.ZERO], 800, 5)
var yellow_card2: Card.CardStats = Card.CardStats.new(2, card_data["laser_sweep"]["title"], card_data["laser_sweep"]["image"], card_data["card_types"]["attack"], card_data["laser_sweep"]["description"], Color.YELLOW, [{"effect": yellow_attack2}])
var yellow_effect1: Card.DeckManipulation = Card.DeckManipulation.new("add", yellow_sub_card1)
var yellow_card3: Card.CardStats = Card.CardStats.new(1, card_data["blast_store"]["title"], card_data["blast_store"]["image"], card_data["card_types"]["skill"], card_data["blast_store"]["description"], Color.YELLOW, [{"effect": yellow_effect1}], 50, [yellow_sub_card1])

var yellow_card4: Card.CardStats = Card.CardStats.new(1, card_data["photosynthesis"]["title"], card_data["photosynthesis"]["image"], card_data["card_types"]["skill"], card_data["photosynthesis"]["description"], Color.YELLOW, [{"effect": Card.photosynthesis}], 50, ["exhaust", yellow_sub_card1])

var violet_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [0], 0.1, 2500, [Vector2.ZERO], 1000, 15)
var violet_card1: Card.CardStats = Card.CardStats.new(1, card_data["shooting_target"]["title"], card_data["shooting_target"]["image"], card_data["card_types"]["attack"], card_data["shooting_target"]["description"], Color.BLUE_VIOLET, [{"delay": 0.1, "effect": violet_attack1}])
var violet_drone1: Card.AttackPattren = Card.AttackPattren.new(drone, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 0)
var violet_drone_sub_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 10, [0], 0.2, 1200, [Vector2.ZERO], 1200, 2)
var violet_card2: Card.CardStats = Card.CardStats.new(2, card_data["violet_detector"]["title"], card_data["violet_detector"]["image"], card_data["card_types"]["summon"], card_data["violet_detector"]["description"], Color.BLUE_VIOLET, [{"effect": violet_drone1}])
var violet_drone2: Card.AttackPattren = Card.AttackPattren.new(drone, 5, 1, [0], 0.1, 500, [Vector2(0, 100),Vector2(40, 150),Vector2(-40, 150),Vector2(80, 200),Vector2(-80, 200)], 800, 5)
var violet_card3: Card.CardStats = Card.CardStats.new(1, card_data["charging_force"]["title"], card_data["charging_force"]["image"], card_data["card_types"]["summon"], card_data["charging_force"]["description"], Color.BLUE_VIOLET, [{"effect": violet_drone2}])

var violet_card4: Card.CardStats = Card.CardStats.new(1, card_data["jammed_fire"]["title"], card_data["jammed_fire"]["image"], card_data["card_types"]["attack"], card_data["jammed_fire"]["description"], Color.BLUE_VIOLET, [{"effect": Card.jammed_fire}], 150, [jam_card])

var cards: Array = []
var blue_cards: Array = [blue_card1, blue_card2, blue_card3, blue_card4, blue_card5]
var orange_cards: Array = [orange_card1, orange_card2, orange_card3, orange_card4]
var red_cards: Array = [red_card1, red_card2, red_card3]
var green_cards: Array = [green_card1, green_card2, green_card3, green_card4, green_card5]
var yellow_cards: Array = [yellow_card1, yellow_card2, yellow_card3, yellow_card4]
var violet_cards: Array = [violet_card1, violet_card2, violet_card3, violet_card4]

var blue_starting_cards: Array = [blue_card1, blue_card2, blue_card3]
var blue_modifier1: Modifiers.Modifier = Modifiers.Modifier.new(mod_data["blue_capsule"]["title"], mod_data["blue_capsule"]["image"], Modifiers.Types.KILL, 0, Callable(Modifiers.blue_capsule), mod_data["blue_capsule"]["description"], ["reinforce"])
var orange_starting_cards: Array = [orange_card1, orange_card2, orange_card3]
var orange_modifier1: Modifiers.Modifier = Modifiers.Modifier.new(mod_data["orange_capsule"]["title"], mod_data["orange_capsule"]["image"], Modifiers.Types.FLAME, 0, Callable(Modifiers.orange_capsule), mod_data["orange_capsule"]["description"], ["flame", "fragile"])
var red_starting_cards: Array = [red_card1, red_card2, red_card3]
var red_modifier1: Modifiers.Modifier = Modifiers.Modifier.new(mod_data["red_capsule"]["title"], mod_data["red_capsule"]["image"], Modifiers.Types.DEBUFF, 0, Callable(Modifiers.red_capsule), mod_data["red_capsule"]["description"])
var green_starting_cards: Array = [green_card1, green_card2, green_card3, green_card4]
var green_modifier1: Modifiers.Modifier = Modifiers.Modifier.new(mod_data["green_capsule"]["title"], mod_data["green_capsule"]["image"], Modifiers.Types.DEATH, 0, Callable(Modifiers.green_capsule), mod_data["green_capsule"]["description"])
var yellow_starting_cards: Array = [yellow_card1, yellow_card2, yellow_card3]
var yellow_modifier1: Modifiers.Modifier = Modifiers.Modifier.new(mod_data["yellow_capsule"]["title"], mod_data["yellow_capsule"]["image"], Modifiers.Types.CREATE, 0, Callable(Modifiers.yellow_capsule), mod_data["yellow_capsule"]["description"])
var violet_starting_cards: Array = [violet_card1, violet_card2, violet_card3]
var violet_modifier1: Modifiers.Modifier = Modifiers.Modifier.new(mod_data["violet_capsule"]["title"], mod_data["violet_capsule"]["image"], Modifiers.Types.COMBAT_START, 0, Callable(Modifiers.violet_capsule), mod_data["violet_capsule"]["description"])
var other_cards: Array = [orange_card1, red_card2, violet_card3, blue_card1, green_card2, yellow_card3]

var blue_special_attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 3, 10, [-10, 0, 10], 0.1, 800, [Vector2(40, 0),Vector2(0, 0),Vector2(-40, 0)], 1000, 2)
var blue_special_card: Card.CardStats = Card.CardStats.new(0, "", "", "", "", Color.BLUE, [{"effect": blue_special_attack}])
var orange_special_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 4, [10], 0.05, 300, [Vector2(0, 0)], 300, 1)
var orange_special_attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 4, [-10], 0.05, 300, [Vector2(0, 0)], 300, 1)
var orange_special_card: Card.CardStats = Card.CardStats.new(0, "", "", "", "", Color.ORANGE, [{"effect": orange_effect2}, {"effect": orange_special_attack1}, {"delay": 0.2, "effect": orange_special_attack2}, {"delay": 0.2, "effect": orange_special_attack1}, {"delay": 0.2, "effect": orange_special_attack2}])
var red_special_attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 5, 3, [-2, -1, 0, 1, 2], 0.1, 800, [Vector2(0, 0)], 1000, 2)
var red_special_effect: Card.StatusAffliction = Card.StatusAffliction.new("gen_impede", 2, 1, "debuff")
var red_special_card: Card.CardStats = Card.CardStats.new(0, "", "", "", "", Color.RED, [{"effect": red_special_effect}, {"effect": red_special_attack}])
var green_special_attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 5, 2, [160, 170, 180, 190, 200], 0.2, 800, [Vector2(0, 0)], 1800, 3)
var green_special_card: Card.CardStats = Card.CardStats.new(0, "", "", "", "", Color.GREEN, [{"effect": green_special_attack}])
var yellow_special_attack: Card.DeckManipulation = Card.DeckManipulation.new("add", yellow_sub_card1, 3)
var yellow_special_card: Card.CardStats = Card.CardStats.new(0, "", "", "", "", Color.YELLOW, [{"effect": yellow_special_attack}])
var violet_special_attack: Card.AttackPattren = Card.AttackPattren.new(drone, 3, 1, [0], 0.1, 0, [Vector2(0, 0)], 1000, 0)
var violet_special_sub_attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 15, [0], 0.1, 800, [Vector2(0, 0)], 1000, 2)
var violet_special_card: Card.CardStats = Card.CardStats.new(0, "", "", "", "", Color.BLUE_VIOLET, [{"effect": violet_special_attack}])

var modifier1: Modifiers.Modifier = Modifiers.Modifier.new(mod_data["dramatic_entrance"]["title"], mod_data["dramatic_entrance"]["image"], Modifiers.Types.COMBAT_START, 30, Callable(Modifiers.dramatic_entrence), mod_data["dramatic_entrance"]["description"])
var modifier2: Modifiers.Modifier = Modifiers.Modifier.new(mod_data["return_fire"]["title"], mod_data["return_fire"]["image"], Modifiers.Types.COMBAT_START, 30, Callable(Modifiers.return_fire), mod_data["return_fire"]["description"])
var modifiers: Array = [modifier1, modifier2, blue_modifier1]

var cards_dictionary: Dictionary = {
	"reinforced_rounds": blue_card1,
	"spray_and_pray": blue_card2,
	"dual_fire": blue_card3,
	"flare": orange_card1,
	"flame_thrower": orange_card2,
	"exposion_shower": orange_card3,
	"double_burst": red_card1,
	"rewire": red_card2,
	"fan_shot": red_card3,
	"take_aim": green_card1,
	"cover_fire": green_card2,
	"force_field": green_card3,
	"deflection": green_card4,
	"blast": yellow_sub_card1,
	"shine": yellow_card1,
	"laser_sweep": yellow_card2,
	"blast_store": yellow_card3,
	"shooting_target": violet_card1,
	"violet_detector": violet_card2,
	"charging_force": violet_card3,
	"reload": blue_card4,
	"jammed_fire": violet_card4,
	"withstand": green_card5,
	"nuclear_fusion": orange_card4,
	"photosynthesis": yellow_card4,
	"charge_up": green_card6,
	"empty_magazine": blue_card5,
	"static_discharge": green_card7,
	"jam": jam_card,
}

func _ready() -> void:
	Engine.max_fps = 60
	
	blue_attack1.set_aim("", 20)
	
	blue_attack3.set_on_kill_effects([blue_card4])
	
	yellow_sub_attack1.set_properties(false, true)
	yellow_sub_attack1.set_laser_properties(0.5)
	yellow_sub_attack1.set_sfx(Audio.sfx_laser)
	
	yellow_attack1.set_properties(false, true)
	yellow_attack1.set_laser_properties(0.5)
	yellow_attack1.set_sfx(Audio.sfx_laser)
	
	yellow_attack2.set_properties(false, true)
	yellow_attack2.set_tweens([{"delay": 0.1, "value": 45, "dur": 0.2}], [])
	yellow_attack2.set_tweens([{"delay": 0.1, "value": -45, "dur": 0.2}], [])
	yellow_attack2.set_laser_properties(0.5)
	yellow_attack2.set_sfx(Audio.sfx_laser)
	
	orange_special_attack1.set_sprite_preset(fire_bullet_preset, Color.WHITE)
	orange_special_attack1.set_change_values([-5])
	orange_special_attack2.set_sprite_preset(fire_bullet_preset, Color.WHITE)
	orange_special_attack2.set_change_values([5])
	
	orange_attack1.set_on_hit_effects([flame_card1])
	orange_attack1.set_sprite_and_size(preload("res://Images/Bullets/flare.png"), 4, 1, Vector2(0.4,0.3), Vector2(0.4,0.3))
	orange_attack1.set_bullet_effect(preload("res://Scenes/fire_bullet_effect.tscn"))
	
	orange_attack2_1.set_properties(false, false, true)
	orange_attack2_1.set_change_values([5])
	orange_attack2_1.set_on_hit_effects([flame_card2])
	orange_attack2_1.set_tweens([], [], [], [{"delay": 0, "value": Vector2(2,2), "dur": 0.2}])
	orange_attack2_1.set_sprite_preset(fire_bullet_preset, Color.WHITE)
	orange_attack2_2.set_properties(false, false, true)
	orange_attack2_2.set_change_values([-5])
	orange_attack2_2.set_on_hit_effects([flame_card2])
	orange_attack2_2.set_tweens([], [], [], [{"delay": 0, "value": Vector2(2,2), "dur": 0.2}])
	orange_attack2_2.set_sprite_preset(fire_bullet_preset, Color.WHITE)
	
	orange_attack3.set_change_values([45])
	orange_attack3.set_tweens([], [{"delay": 0, "value": 0, "dur": 0.8}])
	orange_attack3.set_bomb_properties(2, Vector2(1, 1), 10)
	
	orange_attack4.set_marker("marker", 0.2)
	orange_attack4.set_change_values([], [], [Vector2(0, -100)])
	
	green_special_attack.set_look("enemy", 0.2, 2)
	
	green_attack1.set_aim("enemy")
	
	green_attack2.set_aim("", 40)
	green_attack2.set_attack(0, green_sub_shield1)
	
	green_shield1.set_shield_properties(2, Vector2(1,1))
	green_shield1.set_properties(false, true)
	
	green_sub_shield1.set_shield_properties(5, Vector2(0.5, 0.5))
	green_sub_shield1.set_properties(false, true)
	
	green_shield2.set_shield_properties(0.5, Vector2(1,1), true)
	green_shield2.set_properties(false, true)
	
	violet_special_attack.set_tweens([], [], [{
		"delay": 0, "value": Vector2(0, -40), "dur": 0.2
	}])
	violet_special_attack.set_tweens([], [], [{
		"delay": 0, "value": Vector2(-40, -40), "dur": 0.2
	}])
	violet_special_attack.set_tweens([], [], [{
		"delay": 0, "value": Vector2(40, -40), "dur": 0.2
	}])
	violet_special_attack.set_drone_properties(2)
	violet_special_attack.set_attack(0.1, violet_special_sub_attack)
	
	violet_attack1.set_animation("shockwave", 0)
	
	violet_drone1.set_drone_properties(5)
	violet_drone1.set_tweens([], [], [{"delay": 0, "value": Vector2(0, -100), "dur": 0.4}])
	violet_drone1.set_attack(2, violet_drone_sub_attack1)
	violet_drone1.set_look("enemy")
	violet_drone1.set_sprite_and_size(preload("res://Images/Characters/violet_detector.png"), 1, 0, Vector2(0.4,0.4), Vector2(1,1))
	
	violet_drone2.set_drone_properties(10)
	violet_drone2.set_tweens([], [{"delay": 0, "value": 1000, "dur": 1}], [])
	violet_drone2.set_tweens([], [{"delay": 0, "value": 1000, "dur": 1}], [])
	violet_drone2.set_tweens([], [{"delay": 0, "value": 1000, "dur": 1}], [])
	violet_drone2.set_tweens([], [{"delay": 0, "value": 1000, "dur": 1}], [])
	violet_drone2.set_tweens([], [{"delay": 0, "value": 1000, "dur": 1}], [])
	violet_drone2.set_sprite_and_size(preload("res://Images/Characters/charger.png"), 2, 0.5, Vector2(0.4,0.4), Vector2(1.5,2))
