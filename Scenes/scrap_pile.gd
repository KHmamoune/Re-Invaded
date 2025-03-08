extends Enemy


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	scrap = 40
	set_up_hp(20, Vector2(0, 50))
	set_up_status_effects(Vector2(-15, 65))
