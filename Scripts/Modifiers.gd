extends Node


enum Types { SHUFFLE, HURT, COMBAT_START, KILL, CREATE, FLAME, DEBUFF, DEATH, HEAL }


class Modifier:
	var modifier_name: String
	var modifier_sprite: String
	var modifier_type: Types
	var modifier_price: int
	var modifier_effect: Callable
	var modifier_description: String
	var modifier_tooltips: Array
	
	func _init(mn: String, ms: String, mt: Types, mp: int, me: Callable, md: String, mtt: Array = []) -> void:
		modifier_name = mn
		modifier_sprite = ms
		modifier_type = mt
		modifier_price = mp
		modifier_effect = me
		modifier_description = md
		modifier_tooltips = mtt
	
	func play(pl: Node) -> void:
		modifier_effect.call(pl)


func blue_capsule(pl: Node) -> void:
	var effect: Card.StatusAffliction = Card.StatusAffliction.new("reinforce", 0, 1, "buff")
	effect.play(pl)


func orange_capsule(pl: Node) -> void:
	var effect: Card.StatusAffliction = Card.StatusAffliction.new("fragile", 0, 1, "debuff")
	effect.play(pl)


func red_capsule(pl: Node) -> void:
	for enemy: Node in  pl.get_tree().get_nodes_in_group("enemy"):
		enemy.take_damage(2)


func green_capsule(pl: Node) -> void:
	pl.hp += 2
	pl.energy = pl.energy_max


func yellow_capsule(pl: Node) -> void:
	pl.energy += 0.5


func violet_capsule(pl: Node) -> void:
	var attack: Card.AttackPattren = Card.AttackPattren.new(preload("res://Scenes/bullet.tscn"), 1, 5, [0], 0.2, 1000, [Vector2.ZERO], 800, 2)
	var drone: Card.AttackPattren = Card.AttackPattren.new(preload("res://Scenes/drone.tscn"), 2, 1, [0], 0.1, 0, [Vector2.ZERO], 800, 0)
	drone.set_tweens([], [], [{"delay": 0, "value": Vector2(50, 0), "dur": 0.2}])
	drone.set_tweens([], [], [{"delay": 0, "value": Vector2(-50, 0), "dur": 0.2}])
	drone.set_drone_properties(3.2)
	drone.set_properties(false, true)
	drone.set_attack(1, attack)
	drone.play(pl)


func return_fire(pl: Node) -> void:
	var start_angle: int = randi_range(0, 9)
	var arr: Array = [start_angle]
	
	for i in range(1, 36):
		arr.append(start_angle + (i * 10))
	
	var attack: Card.AttackPattren = Card.AttackPattren.new(preload("res://Scenes/bullet.tscn"), 36, 1, arr, 0.2, 400, [Vector2.ZERO], 800, 1)
	attack.play(pl)


func dramatic_entrence(pl: Node) -> void:
	for enemy: Node in  pl.get_tree().get_nodes_in_group("enemy"):
		enemy.take_damage(10)
