extends Enemy


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	scrap = 40
	hp = 50
	$hp.text = str(hp)


func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)
