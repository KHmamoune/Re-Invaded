extends Node


enum Types { SHUFFLE, HURT, COMBAT_START }


class Modifier:
	var modifier_sprite: String
	var modifier_type: Types
	var modifier_price: int
	var modifier_effect: Callable
	var modifier_description: String
	
	func _init(ms: String, mt: Types, mp: int, me: Callable, md: String) -> void:
		modifier_sprite = ms
		modifier_type = mt
		modifier_price = mp
		modifier_effect = me
		modifier_description = md
	
	func play(pl: Node) -> void:
		modifier_effect.call(pl)


func max_hp_on_shuffle(pl: Node) -> void:
	pl.max_hp += 1


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
