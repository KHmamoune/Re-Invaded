extends PanelContainer

var tooltip: Dictionary

func update(tip: String) -> void:
	match tip:
		"flame":
			%icon.texture = preload("res://Images/Icons/flame.png")
			%title.text = "Flame:"
			%description.text = "Enemies that are afflicted by flame lose 2 hp every 0.5 seconds."
		"impede":
			%icon.texture = preload("res://Images/Icons/impede.png")
			%title.text = "Impede:"
			%description.text = "Halves movement speed."
		"generation boost":
			%icon.texture = preload("res://Images/Icons/gen_boost.png")
			%title.text = "Generation Boost:"
			%description.text = "Increases Energy generation by 1."
		"reinforce":
			%icon.texture = preload("res://Images/Icons/reinforced.png")
			%title.text = "Reinforced:"
			%description.text = "Increases attack damage by x."
		"heat":
			%icon.texture = preload("res://Images/Icons/heat.png")
			%title.text = "Heat:"
			%description.text = "Increases Energy generation and movement speed by 10% per stack (caps at 10)."
		"fragile":
			%icon.texture = preload("res://Images/Icons/heat.png")
			%title.text = "Fragile:"
			%description.text = "take 150% damage, on hit lose 1 fragile."
