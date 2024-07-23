extends Node


var current_scene: Node
var current_map: Map.MapData
var player_color: String

var turret: PackedScene = preload("res://Scenes/turret.tscn")
var maxim: PackedScene = preload("res://Scenes/maxim.tscn")
var hex_shooter: PackedScene = preload("res://Scenes/hex_shooter.tscn")
var mine: PackedScene = preload("res://Scenes/mine.tscn")
var radar: PackedScene = preload("res://Scenes/radar.tscn")
var starly: PackedScene = preload("res://Scenes/starly.tscn")
var security_system: PackedScene = preload("res://Scenes/security_system.tscn")

var en_map1: Battle.EnemyMap = Battle.EnemyMap.new([
	{ "enemy": maxim },
	{ "enemy": maxim },
	{ "enemy": turret },
	{ "enemy": turret }
	], [Vector2(275, 400),Vector2(425, 400),Vector2(250, 150),Vector2(450, 150)])

var en_map2: Battle.EnemyMap = Battle.EnemyMap.new([
	{ "enemy": mine },
	{ "enemy": mine },
	{ "enemy": mine },
	{ "enemy": mine },
	{ "enemy": mine },
	{ "enemy": mine },
	{ "enemy": hex_shooter },
	{ "enemy": hex_shooter, "fliped": true }
	], [Vector2(125,200), Vector2(200,200), Vector2(275,200), Vector2(425,200), Vector2(500,200), Vector2(575,200), Vector2(200, 100), Vector2(500, 100)])
var en_maps: Array = [en_map1, en_map2]

var mini_map1: Battle.EnemyMap = Battle.EnemyMap.new([{ "enemy": radar }], [Vector2(350, 200)])
var mini_map2: Battle.EnemyMap = Battle.EnemyMap.new([{ "enemy": starly }], [Vector2(350, 200)])
var mini_maps: Array = [mini_map1, mini_map2]

var boss_map1: Battle.EnemyMap = Battle.EnemyMap.new([{ "enemy": security_system }], [Vector2(350, 120)])
var boss_maps: Array = [boss_map1]

var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
var laser: PackedScene = preload("res://Scenes/laser.tscn")
var bomb: PackedScene = preload("res://Scenes/bomb.tscn")
var sheild: PackedScene = preload("res://Scenes/sheild.tscn")
var drone: PackedScene = preload("res://Scenes/drone.tscn")

#var attack1 = Card.AttackPattren.new(bullet, 1, 5, 0, 0.1, 1200, Vector2.ZERO, 800, 1)
#var attack2 = Card.AttackPattren.new(bullet, 2, 6, 0, 0.05, 1800, [Vector2(20, 0), Vector2(-20, 0)], 800, 1)
#var attack3 = Card.AttackPattren.new(bullet, 4, 2, [5, 2, -2, -5], 0.5, 800, [Vector2(25,0),Vector2(10,-15),Vector2(-10,-15),Vector2(-25,0)], 500, 10)
#var attack4 = Card.AttackPattren.new(bullet, 2, 20, [-90, 90], 0.05, 500, Vector2.ZERO, 800, 1)
#var attack5 = Card.AttackPattren.new(bullet, 2, 10, [-70, 70], 0.1, 1000, Vector2.ZERO, 3000, 1)
#var attack6 = Card.AttackPattren.new(bullet, 1, 20, 0, 0.05, 1500, Vector2.ZERO, 1200, 1)
#var attack7 = Card.AttackPattren.new(bullet, 1, 8, 0, 0.05, 1200, Vector2.ZERO, 1200, 1)
#var attack8 = Card.AttackPattren.new(laser, 1, 1, [180], 0.1, 1200, Vector2.ZERO, 800, 5)
#var attack9 = Card.AttackPattren.new(bullet, 2, 10, 0, 0.04, 500, [Vector2(-35, 0), Vector2(35, 0)], 800, 1)
#var attack10 = Card.AttackPattren.new(laser, 2, 2, [135, 225], 0.5, 1200, Vector2.ZERO, 800, 5)
#var attack11 = Card.AttackPattren.new(bullet, 4, 10, [90, 180, 270, 360], 0.2, 300, Vector2.ZERO, 800, 1)
#var attack12 = Card.AttackPattren.new(bullet, 4, 10, [90, 180, 270, 360], 0.2, 300, Vector2.ZERO, 800, 1)
#var attack13 = Card.AttackPattren.new(bullet, 2, 10, 0, 0.2, -300, Vector2.ZERO, 1500, 1)
#var attack14 = Card.AttackPattren.new(bullet, 1, 1, 0, 0.1, 600, Vector2.ZERO, 1000, 1)
#var attack15 = Card.AttackPattren.new(bullet, 1, 4, 0, 0.3, 600, Vector2.ZERO, 1000, 1)
#var attack16 = Card.AttackPattren.new(bullet, 1, 1, 0, 0.1, 400, Vector2.ZERO, 410, 1)
#var attack17 = Card.AttackPattren.new(bullet, 2, 50, [90, -90], 0.1, 1000, Vector2.ZERO, 1500, 1)
#var attack18 = Card.AttackPattren.new(bomb, 1, 3, -45, 0.1, 1200, Vector2.ZERO, 800, 1)
#var attack19 = Card.AttackPattren.new(bullet, 1, 1, 0, 0.1, 1200, Vector2.ZERO, 800, 1)

var sub_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 50, [90, -90], 0.08, 500, [Vector2.ZERO], 1000, 1)
var sub_attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 360, [90], 0.01, 100, [Vector2.ZERO], 800, 1)
var sub_attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 10, 1, [0, 36, 72, 108, 144, 180, 216, 252, 288, 324], 0, 200, [Vector2.ZERO], 200, 1)

var effect1: Card.StatusAffliction = Card.StatusAffliction.new("impede", 2, 1)
var effect2: Card.StatusAffliction = Card.StatusAffliction.new("gen_boost", 2, 1)

#var sub_card1 = Card.CardStats.new(1, "laser fire", "res://Images/Other/LaserFirePicture.png", "attack", "shoot a laser in front of you", Color.YELLOW, [attack8])

var sheild1: Card.AttackPattren = Card.AttackPattren.new(sheild, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 1)

var drone1: Card.AttackPattren = Card.AttackPattren.new(drone, 2, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 1)

#var deck_effect1 = Card.DeckManipulation.new("add", sub_card1)

#var card1 = Card.CardStats.new(1, "rapid fire", "res://Images/Other/reinforced_rounds_card.png", "attack", "shoot a line of fast shots", Color.CYAN, [attack1], 20)
#var card2 = Card.CardStats.new(1, "dual fire", "res://Images/Other/dual_fire_card.png", "attack", "shoot two bursts of very fast shots", Color.CYAN, [attack2], 60)
#var card3 = Card.CardStats.new(2, "burst fire", "res://Images/Other/take_aim_card.png", "attack", "shoot a burst of slow bullets", Color.RED, [attack3], 30)
#var card4 = Card.CardStats.new(2, "spray fire", "res://Images/Other/spray_and_pray_card.png", "attack", "shoot a spray of bullets bullets", Color.CYAN, [attack4])
#var card5 = Card.CardStats.new(2, "bouncy fire", "res://Images/Other/deflection_card.png", "attack", "shoot two bouncing streams of bullets", Color.CYAN, [attack5])
#var card6 = Card.CardStats.new(1, "random fire", "res://Images/Other/force_field_card.png", "attack", "shoot random spray of bullets", Color.CYAN, [attack6])
#var card7 = Card.CardStats.new(3, "aimed fire", "res://Images/Other/AimedFirePicture.png", "attack", "fire shots at closest target", Color.GREEN, [attack7])
#var card8 = Card.CardStats.new(1, "laser fire", "res://Images/Other/LaserFirePicture.png", "attack", "shoot a laser in front of you", Color.YELLOW, [attack8])
#var card9 = Card.CardStats.new(1, "helix shot", "res://Images/Other/HelixFirePicture.png", "attack", "fire two streams of bullets in the shape of a helix", Color.CYAN, [attack9])
#var card10 = Card.CardStats.new(3, "strafe laser", "res://Images/Other/StrafeLaserPicture.png", "attack", "fire two lasers that strafes over the screen", Color.YELLOW, [attack10])
#var card11 = Card.CardStats.new(3, "strafe laser", "res://Images/Other/StrafeLaserPicture.png", "attack", "fire a laser that strafes over the screen", Color.CYAN, [attack11])
#var card12 = Card.CardStats.new(3, "strafe laser", "res://Images/Other/StrafeLaserPicture.png", "attack", "fire a laser that strafes over the screen", Color.CYAN, [attack12])
#var card13 = Card.CardStats.new(1, "strafe laser", "res://Images/Other/StrafeLaserPicture.png", "attack", "fire a laser that strafes over the screen", Color.CYAN, [attack13])
#var card14 = Card.CardStats.new(1, "strafe laser", "res://Images/Other/StrafeLaserPicture.png", "attack", "fire a laser that strafes over the screen", Color.CYAN, [attack14])
#var card15 = Card.CardStats.new(1, "strafe laser", "res://Images/Other/StrafeLaserPicture.png", "attack", "fire a laser that strafes over the screen", Color.CYAN, [attack15])
#var card16 = Card.CardStats.new(1, "strafe laser", "res://Images/Other/StrafeLaserPicture.png", "attack", "fire a laser that strafes over the screen", Color.CYAN, [attack16])
#var card17 = Card.CardStats.new(1, "strafe laser", "res://Images/Other/StrafeLaserPicture.png", "attack", "fire a laser that strafes over the screen", Color.CYAN, [attack17])
#var card18 = Card.CardStats.new(1, "strafe laser", "res://Images/Other/StrafeLaserPicture.png", "attack", "fire a laser that strafes over the screen", Color.CYAN, [attack18])
#var card19 = Card.CardStats.new(1, "strafe laser", "res://Images/Other/HelixFirePicture.png", "attack", "fire a laser that strafes over the screen", Color.CYAN, [effect1, effect2])
#var card21 = Card.CardStats.new(1, "rapid fire", "res://Images/Other/DualFirePicture.png", "attack", "shoot a line of fast shots", Color.YELLOW, [deck_effect1], 20)
#var card22 = Card.CardStats.new(1, "rapid fire", "res://Images/Other/HelixFirePicture.png", "attack", "shoot a line of fast shots", Color.GREEN, [sheild1], 50)
#var card23 = Card.CardStats.new(1, "rapid fire", "res://Images/Other/HelixFirePicture.png", "attack", "shoot a line of fast shots", Color.GREEN, [drone1], 50)
var cards: Array = []

var blue_effect1: Card.StatusAffliction = Card.StatusAffliction.new("reinforce", 0, 2)
var blue_card1: Card.CardStats = Card.CardStats.new(2, "Reinforced Rounds", "res://Images/Other/reinforced_rounds_card.png", "skill", "gain 2 reinforced.", Color.CYAN, [{"effect": blue_effect1}], 120, ["reinforce"])
var blue_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 20, [0], 0.05, 1500, [Vector2.ZERO], 1200, 4)
var blue_card2: Card.CardStats = Card.CardStats.new(2, "Spray and Pray", "res://Images/Other/spray_and_pray_card.png", "attack", "lob a barrage of randomly aimed bullets, 4 damage", Color.CYAN, [{"effect": blue_attack1}])
var blue_attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 6, [0], 0.05, 1800, [Vector2(20, 0), Vector2(-20, 0)], 800, 2)
var blue_card3: Card.CardStats = Card.CardStats.new(1, "Dual Fire", "res://Images/Other/dual_fire_card.png", "attack", "fire two bursts of fast bullets, 2 damage.", Color.CYAN, [{"effect": blue_attack2}])

var orange_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [0], 0.1, 800, [Vector2.ZERO], 800, 5)
var orange_effect1: Card.StatusAffliction = Card.StatusAffliction.new("flame", 5, 1)
var orange_effect2: Card.StatusAffliction = Card.StatusAffliction.new("heat", 0, 1)
var orange_card1: Card.CardStats = Card.CardStats.new(1, "Flare", "res://Images/Other/flare_card.png", "attack", "fire a shot that applies flame on hit, gain 1 heat, 5 damage.", Color.ORANGE, [{"effect": orange_attack1}, {"effect": orange_effect2}], 40, ["flame", "heat"])
var orange_attack2_1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 5, [-10], 0.1, 1200, [Vector2.ZERO], 800, 2)
var orange_attack2_2: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 5, [10], 0.1, 1200, [Vector2.ZERO], 800, 2)
var orange_effect3: Card.StatusAffliction = Card.StatusAffliction.new("flame", 0.6, 1)
var orange_card2: Card.CardStats = Card.CardStats.new(1, "Flare", "res://Images/Other/flame_thrower_card.png", "attack", "shoot a spray of flames that apply flame on hit, 3 damage.", Color.ORANGE, [{"effect": orange_attack2_1}, {"delay": 0.6, "effect": orange_attack2_2}, {"delay": 0.6, "effect": orange_attack2_1}, {"delay": 0.6, "effect": orange_attack2_2}], 110, ["flame"])
var orange_attack3: Card.AttackPattren = Card.AttackPattren.new(bomb, 1, 3, [-45], 0.1, 1200, [Vector2.ZERO], 800, 1)
var orange_card3: Card.CardStats = Card.CardStats.new(2, "Explosion Shower", "res://Images/Other/explosion_shower_card.png", "attack", "shoot 3 bombs that explode after.", Color.ORANGE, [{"effect": orange_attack3}])

var red_attack1_1: Card.AttackPattren = Card.AttackPattren.new(bullet, 4, 1, [5, 2, -2, -5], 0.5, 800, [Vector2(25,0),Vector2(10,-15),Vector2(-10,-15),Vector2(-25,0)], 500, 10)
var red_attack1_2: Card.AttackPattren = Card.AttackPattren.new(bullet, 5, 1, [5, 2.5, 0, -2.5, -5], 0.5, 800, [Vector2.ZERO], 500, 10)
var red_card1: Card.CardStats = Card.CardStats.new(1, "Double Burst", "res://Images/Other/double_burst_card.png", "attack", "fire 2 burst shots, 5 damage.", Color.RED, [{"effect": red_attack1_1}, {"delay": 0.05, "effect": red_attack1_2}])
var red_effect1_1: Card.StatusAffliction = Card.StatusAffliction.new("impede", 2, 1)
var red_effect1_2: Card.StatusAffliction = Card.StatusAffliction.new("gen_boost", 2, 1)
var red_card2: Card.CardStats = Card.CardStats.new(1, "Rewire", "res://Images/Other/rewire_card.png", "skill", "apply 1 impede, gain generation boost for 2 seconds.", Color.RED, [{"effect": red_effect1_1}, {"effect": red_effect1_2}], 80, ["impede", "generation boost"])
var red_attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 20, 1, [50,45,40,35,30,25,20,15,10,5,-5,-10,-15,-20,-25,-30,-35,-40,-45,-50], 0.1, 1200, [Vector2.ZERO], 800, 2)
var red_card3: Card.CardStats = Card.CardStats.new(1, "Fan Shot", "res://Images/Other/fan_shot_card.png", "attack", "fire 20 bullets in a fan shape that, 2 damage.", Color.RED, [{"effect": red_attack3}])

var green_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 8, [0], 0.05, 1200, [Vector2.ZERO], 1200, 2)
var green_card1: Card.CardStats = Card.CardStats.new(2, "Take Aim", "res://Images/Other/take_aim_card.png", "attack", "fire shots at closest target, 2 damage", Color.GREEN, [{"effect": green_attack1}])
var green_attack2: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 10, [0], 0.05, 900, [Vector2.ZERO], 1200, 4)
var green_sub_shield1: Card.AttackPattren = Card.AttackPattren.new(sheild, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 1)
var green_card2: Card.CardStats = Card.CardStats.new(3, "Cover Fire", "res://Images/Other/cover_fire_card.png", "attack", "fire bullets that have shields, 4 damage", Color.GREEN, [{"effect": green_attack2}])
var green_shield1: Card.AttackPattren = Card.AttackPattren.new(sheild, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 1)
var green_card3: Card.CardStats = Card.CardStats.new(2, "Force Field", "res://Images/Other/force_field_card.png", "defence", "make a shield that protects you for 2 seconds", Color.GREEN, [{"effect": green_shield1}])
var green_shield2: Card.AttackPattren = Card.AttackPattren.new(sheild, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 1)
var green_card4: Card.CardStats = Card.CardStats.new(0, "Deflection", "res://Images/Other/deflection_card.png", "defence", "deflect nearby shots", Color.GREEN, [{"effect": green_shield2}])

var yellow_sub_attack1: Card.AttackPattren = Card.AttackPattren.new(laser, 1, 1, [180], 0.1, 1200, [Vector2.ZERO], 800, 5)
var yellow_sub_card1: Card.CardStats = Card.CardStats.new(1, "Blast", "res://Images/Other/blast_card.png", "attack", "fire a laser", Color.YELLOW, [{"effect": yellow_sub_attack1}])
var yellow_attack1: Card.AttackPattren = Card.AttackPattren.new(laser, 3, 1, [178, 182, 180], 0.1, 1200, [Vector2.ZERO], 800, 5)
var yellow_card1: Card.CardStats = Card.CardStats.new(1, "Shine", "res://Images/Other/shine_card.png", "attack", "fire a laser, 5 damage", Color.YELLOW, [{"effect": yellow_attack1}])
var yellow_attack2: Card.AttackPattren = Card.AttackPattren.new(laser, 2, 2, [135, 225], 0.5, 1200, [Vector2.ZERO], 800, 5)
var yellow_card2: Card.CardStats = Card.CardStats.new(2, "Sweep", "res://Images/Other/laser_sweep_card.png", "attack", "fire 2 lasers that sweep a large area, 5 damge", Color.YELLOW, [{"effect": yellow_attack2}])
var yellow_effect1: Card.DeckManipulation = Card.DeckManipulation.new("add", yellow_sub_card1)
var yellow_card3: Card.CardStats = Card.CardStats.new(1, "Blast Store", "res://Images/Other/blast_store_card.png", "skill", "add a blast to your deck", Color.YELLOW, [{"effect": yellow_effect1}], 50, [yellow_sub_card1])

var violet_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [0], 0.1, 2500, [Vector2.ZERO], 1200, 15)
var violet_card1: Card.CardStats = Card.CardStats.new(1, "Shooting Target", "res://Images/Other/shooting_target_card.png", "attack", "fire a high damaging shot. 15 damage", Color.BLUE_VIOLET, [{"effect": violet_attack1}])
var violet_drone1: Card.AttackPattren = Card.AttackPattren.new(drone, 1, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 0)
var violet_drone_sub_attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 10, [0], 0.2, 1200, [Vector2.ZERO], 1200, 2)
var violet_card2: Card.CardStats = Card.CardStats.new(2, "Violet Detector", "res://Images/Other/violet_detector_card.png", "summon", "summon a turret that shoots the closest enemy.", Color.BLUE_VIOLET, [{"effect": violet_drone1}])
var violet_drone2: Card.AttackPattren = Card.AttackPattren.new(drone, 5, 1, [0], 0.1, 500, [Vector2(0, 100),Vector2(40, 150),Vector2(-40, 150),Vector2(80, 200),Vector2(-80, 200)], 800, 5)
var violet_card3: Card.CardStats = Card.CardStats.new(1, "Charging Force", "res://Images/Other/charging_force_card.png", "summon", "summon a volley of raming turrets", Color.BLUE_VIOLET, [{"effect": violet_drone2}])

var blue_cards: Array = [blue_card1, blue_card2, blue_card3]
var blue_modifier1: Modifiers.Modifier = Modifiers.Modifier.new("res://Images/Other/charging_force_card.png", Modifiers.Types.SHUFFLE, 100, Callable(Modifiers.max_hp_on_shuffle), "increase max hp by 1 whenever you shuffle")
var blue_modifier2: Modifiers.Modifier = Modifiers.Modifier.new("res://Images/Other/blast_store_card.png", Modifiers.Types.HURT, 100, Callable(Modifiers.return_fire), "fire bullets when you get hit")
var blue_modifier3: Modifiers.Modifier = Modifiers.Modifier.new("res://Images/Other/flare_card.png", Modifiers.Types.COMBAT_START, 100, Callable(Modifiers.dramatic_entrence), "deal 10 damage to all enemies at the start of combat")
var orange_cards: Array = [orange_card1, orange_card2, orange_card3]
var red_cards: Array = [red_card1, red_card2, red_card3]
var green_cards: Array = [green_card1, green_card2, green_card3, green_card4]
var yellow_cards: Array = [yellow_card1, yellow_card2, yellow_card3]
var violet_cards: Array = [violet_card1, violet_card2, violet_card3]
var other_cards: Array = [orange_card1, red_card2, violet_card3, blue_card1, green_card2, yellow_card3]

func _ready() -> void:
	#attack4.set_change_values([9, -9], [80, 80])
	
	#attack5.set_properties(true)
	
	blue_attack1.set_aim("", 20)
	
	yellow_attack1.set_properties(false, true)
	yellow_attack1.set_laser_properties(0.1)
	
	#attack7.set_aim("enemy")
	
	#attack9.set_tweens([[0.2, 45, 0.2], [0.2, -45, 0.2], [0.2, 45, 0.2], [0.2, -45, 0.2],[0.2, 45, 0.2], [0.2, -45, 0.2],[0.2, 45, 0.2], [0.2, -45, 0.2],[0.2, 45, 0.2], [0.2, -45, 0.2],[0.2, 45, 0.2], [0.2, -45, 0.2]], [])
	#attack9.set_tweens([[0.2, -45, 0.2], [0.2, 45, 0.2], [0.2, -45, 0.2], [0.2, 45, 0.2],[0.2, -45, 0.2], [0.2, 45, 0.2],[0.2, -45, 0.2], [0.2, 45, 0.2],[0.2, -45, 0.2], [0.2, 45, 0.2],[0.2, -45, 0.2], [0.2, 45, 0.2]], [])
	
	yellow_attack2.set_properties(false, true)
	yellow_attack2.set_tweens([{"delay": 0.1, "value": 225, "dur": 0.2}], [])
	yellow_attack2.set_tweens([{"delay": 0.1, "value": 135, "dur": 0.2}], [])
	yellow_attack2.set_laser_properties(0.2)
	
	#attack11.set_tweens([[0, 450, 0.6], [0.2, 360, 0.1]],[[0.6, 0, 0.05], [0.7, 500, 0]])
	#attack11.set_tweens([[0, 540, 0.6], [0.2, 0, 0.1]],[[0.6, 0, 0.05], [0.7, 500, 0]])
	#attack11.set_tweens([[0, 630, 0.6], [0.2, 360, 0.1]],[[0.6, 0, 0.05], [0.7, 500, 0]])
	#attack11.set_tweens([[0, 720, 0.6], [0.2, 0, 0.1]],[[0.6, 0, 0.05], [0.7, 500, 0]])
	
	#attack12.set_tweens([[0, 450, 0.6], [0.2, "enemy", 0.1]],[[0.6, 0, 0.05], [0.7, 500, 0]])
	#attack12.set_tweens([[0, 540, 0.6], [0.2, "enemy", 0.1]],[[0.6, 0, 0.05], [0.7, 500, 0]])
	#attack12.set_tweens([[0, 630, 0.6], [0.2, "enemy", 0.1]],[[0.6, 0, 0.05], [0.7, 500, 0]])
	#attack12.set_tweens([[0, 720, 0.6], [0.2, "enemy", 0.1]],[[0.6, 0, 0.05], [0.7, 500, 0]])
	
	#attack13.set_tweens([[0.4, "enemy", 0]], [[0, 0, 0.4], [0.1, 800, 0.4]], [[0, Vector2(50, 0), 0.4]])
	#attack13.set_tweens([[0.4, "enemy", 0]], [[0, 0, 0.4], [0.1, 800, 0.4]], [[0, Vector2(-50, 0), 0.4]])
	
	#attack14.set_attack(0, sub_attack1)
	#attack15.set_attack(0, sub_attack2)
	#attack16.set_attack(1, sub_attack3)
	#sub_attack2.set_change_values([10], [])
	
	#attack17.set_abs_position([Vector2(225, 0), Vector2(925, 0)])
	#attack17.set_change_values([], [], [Vector2(0, 10), Vector2(0, 10)])
	
	orange_attack1.set_on_hit_effects([orange_effect1])
	orange_attack1.set_sprite_and_size(preload("res://Images/Bullets/flare.png"), 4, 1, Vector2(0.4,0.3), Vector2(0.4,0.3))
	
	orange_attack2_1.set_properties(false, false, true)
	orange_attack2_1.set_change_values([5])
	orange_attack2_1.set_on_hit_effects([orange_effect3])
	orange_attack2_1.set_tweens([], [], [], [{"delay": 0, "value": Vector2(2,2), "dur": 0.2}])
	orange_attack2_1.set_sprite_and_size(preload("res://Images/Bullets/explosion.png"), 12, 2, Vector2(1,1), Vector2(1.5,0.5))
	orange_attack2_2.set_properties(false, false, true)
	orange_attack2_2.set_change_values([-5])
	orange_attack2_2.set_on_hit_effects([orange_effect3])
	orange_attack2_2.set_tweens([], [], [], [{"delay": 0, "value": Vector2(2,2), "dur": 0.2}])
	orange_attack2_2.set_sprite_and_size(preload("res://Images/Bullets/explosion.png"), 12, 2, Vector2(1,1), Vector2(1.5,0.5))
	
	orange_attack3.set_change_values([45])
	orange_attack3.set_tweens([], [{"delay": 0, "value": 0, "dur": 0.8}])
	orange_attack3.set_bomb_properties(2, Vector2(1, 1), 10)
	
	green_attack1.set_aim("enemy")
	
	green_attack2.set_aim("", 40)
	green_attack2.set_attack(0, green_sub_shield1)
	
	green_shield1.set_sheild_properties(2, Vector2(1,1))
	green_shield1.set_properties(false, true)
	
	green_sub_shield1.set_sheild_properties(5, Vector2(0.5, 0.5))
	green_sub_shield1.set_properties(false, true)
	
	green_shield2.set_sheild_properties(0.5)
	green_shield2.set_properties(false, true)
	
	violet_drone_sub_attack1.set_aim("enemy")
	
	violet_drone1.set_drone_properties(5)
	violet_drone1.set_tweens([], [], [{"delay": 0, "value": Vector2(0, -100), "dur": 0.4}])
	violet_drone1.set_attack(2, violet_drone_sub_attack1)
	
	violet_drone2.set_drone_properties(10)
	violet_drone2.set_tweens([], [{"delay": 0, "value": 1000, "dur": 1}], [])
	violet_drone2.set_tweens([], [{"delay": 0, "value": 1000, "dur": 1}], [])
	violet_drone2.set_tweens([], [{"delay": 0, "value": 1000, "dur": 1}], [])
	violet_drone2.set_tweens([], [{"delay": 0, "value": 1000, "dur": 1}], [])
	violet_drone2.set_tweens([], [{"delay": 0, "value": 1000, "dur": 1}], [])
	violet_drone2.set_sprite_and_size(preload("res://Images/Characters/charger.png"), 2, 0.5, Vector2(0.4,0.4), Vector2(1.5,2))
