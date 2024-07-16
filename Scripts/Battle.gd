extends Node


class EnemyMap:
	var enemies: Array
	var positions: Array
	
	func _init(en: Array, po: Array) -> void:
		enemies = en
		positions = po
