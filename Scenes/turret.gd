extends Enemy


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [180], 0.2, 800, [Vector2.ZERO], 800, 1)


func _ready() -> void:
	color = Color.WEB_GRAY
	area_entered.connect(_on_area_entered)
	scrap = 10
	set_up_hp(40, Vector2(0, 55))
	set_up_status_effects(Vector2(-15, 70))


func start() -> void:
	$Animations.play("boot_up")
	await $Animations.animation_finished
	$ShootTimer.start()


func _on_shoot_timer_timeout() -> void:
	if not is_dead:
		$Animations.play("fire")
		attack.play(self)
