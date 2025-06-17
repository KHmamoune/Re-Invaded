extends Enemy


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var explosion: PackedScene = preload("res://Scenes/explosion.tscn")
@onready var attack1: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 140, [90, -90], 0.05, 300, [Vector2.ZERO], 1200, 1)
@onready var attack2: Card.AttackPattren = Card.AttackPattren.new(explosion, 1, 1, [0], 0.05, 0, [Vector2.ZERO], 1200, 1)
@onready var attack3: Card.AttackPattren = Card.AttackPattren.new(bullet, 8, 8, [0, 45, 90, 135, 180, 225, 270, 315], 0.1, 300, [Vector2.ZERO], 1200, 1)


func _ready() -> void:
	attack3.set_change_values([5,5,5,5,5,5,5,5])


func show_indicator():
	Audio.play_sfx(Audio.sfx_alert)
	$Indicator.visible = true
	await get_tree().create_timer(0.2).timeout
	$Indicator.visible = false


func at1() -> void:
	$Animations.play("fly")
	$AfterImageTimer.start()
	Audio.play_sfx(Audio.sfx_blast_off)
	create_tween().tween_property(self, "position:y", position.y - 500, 2).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(2.5).timeout
	position.x += 75
	rotation_degrees += 180
	attack1.play(self)
	show_indicator()
	create_tween().tween_property(self, "position:y", position.y + 1500, 2.5)
	await get_tree().create_timer(3).timeout
	position.x -= 500
	rotation_degrees += 180
	show_indicator()
	create_tween().tween_property(self, "position:y", position.y - 1500, 2.5)
	await get_tree().create_timer(3).timeout
	position = Vector2(500,300)
	rotation_degrees = -60
	create_tween().tween_property(self, "position", Vector2(-500, 100), 2)
	await get_tree().create_timer(2.5).timeout
	position = Vector2(150,-300)
	rotation_degrees = 180
	create_tween().tween_property(self, "position:y", position.y + 300, 1).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(1.4).timeout
	$Animations.play("flash")


func at2() -> void:
	$Animations.play("fly")
	$AfterImageTimer.start()
	Audio.play_sfx(Audio.sfx_blast_off)
	create_tween().tween_property(self, "position:y", position.y - 500, 2).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(2.5).timeout
	position.x -= 75
	rotation_degrees += 180
	attack1.play(self)
	show_indicator()
	create_tween().tween_property(self, "position:y", position.y + 1500, 2.5)
	await get_tree().create_timer(3).timeout
	position.x += 500
	rotation_degrees += 180
	show_indicator()
	create_tween().tween_property(self, "position:y", position.y - 1500, 2.5)
	await get_tree().create_timer(3).timeout
	position = Vector2(-500,300)
	rotation_degrees = 60
	create_tween().tween_property(self, "position", Vector2(500, 100), 2)
	await get_tree().create_timer(2.5).timeout
	position = Vector2(-150,-300)
	rotation_degrees = 180
	create_tween().tween_property(self, "position:y", position.y + 300, 1).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(1.4).timeout
	$Animations.play("flash")


func explode():
	attack2.play(self)
	attack3.play(self)
	visible = false
	await get_tree().create_timer(1).timeout
	queue_free()


func _on_after_image_timer_timeout() -> void:
	var after_image_instance: Node = preload("res://Scenes/after_image.tscn").instantiate()
	after_image_instance.get_node("Sprite2D").texture = $Sprite2D.texture
	after_image_instance.get_node("Sprite2D").hframes = $Sprite2D.hframes
	after_image_instance.scale = $Sprite2D.scale
	after_image_instance.rotation = rotation
	after_image_instance.global_position = global_position
	get_parent().add_child(after_image_instance)
