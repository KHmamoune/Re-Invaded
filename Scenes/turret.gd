extends Enemy


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [180], 0.2, 800, [Vector2.ZERO], 800, 1)


func _ready() -> void:
	color = Color.WEB_GRAY
	area_entered.connect(_on_area_entered)
	scrap = 10
	hp = 40
	$hp.text = str(hp)


func start() -> void:
	$Animations.play("boot_up")
	await $Animations.animation_finished
	$ShootTimer.start()


func _on_shoot_timer_timeout() -> void:
	if not is_dead:
		$Animations.play("fire")
		attack.play(self)


func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)
