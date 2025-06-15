extends PanelContainer

var tooltip: Dictionary

func update(tip: String) -> void:
	match tip:
		"flame":
			%icon.texture = preload("res://Assets/Icons/flame.png")
			%title.text = "Flame:"
			%description.text = "Enemies that are afflicted by flame lose 2 hp every 0.5 seconds."
		"impede":
			%icon.texture = preload("res://Assets/Icons/impede.png")
			%title.text = "Impede:"
			%description.text = "Halves movement speed."
		"generation boost":
			%icon.texture = preload("res://Assets/Icons/gen_boost.png")
			%title.text = "Generation Boost:"
			%description.text = "Increases Energy generation by 1."
		"reinforce":
			%icon.texture = preload("res://Assets/Icons/reinforced.png")
			%title.text = "Reinforced:"
			%description.text = "Increases attack damage by x."
		"heat":
			%icon.texture = preload("res://Assets/Icons/heat.png")
			%title.text = "Heat:"
			%description.text = "Increases Energy generation and movement speed by 10% per stack (max of 10)."
		"fragile":
			%icon.texture = preload("res://Assets/Icons/fragile.png")
			%title.text = "Fragile:"
			%description.text = "take 150% damage, on hit lose 1 fragile."
		"endurance":
			%icon.texture = preload("res://Assets/Icons/endurance.png")
			%title.text = "Endurance:"
			%description.text = "negate the next X instances of damage."
		"exhaust":
			%icon.texture = null
			%title.text = "Exaust:"
			%description.text = "remove the card from the deck until the end of combat."
		"self_repair":
			%icon.texture = preload("res://Assets/Icons/self_repair.png")
			%title.text = "Self Repair:"
			%description.text = "restore hp every X seconds."
		"bullet_speed_boost":
			%icon.texture = preload("res://Assets/Icons/bullet_speed_boost.png")
			%title.text = "Bullet speed boost:"
			%description.text = "increase the speed of all bullets by 200."
		"generation_impede":
			%icon.texture = preload("res://Assets/Icons/gen_impede.png")
			%title.text = "Generation impede:"
			%description.text = "reduce energy generation by 0.5."
		"charge":
			%icon.texture = preload("res://Assets/Icons/charge.png")
			%title.text = "Charge:"
			%description.text = "used for certain card effects."
