extends Enemy


var awake: bool = false
var fliped: bool = false


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 1, [0, 180], 0.2, 400, [Vector2.ZERO, Vector2.ZERO], 700, 1)


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	scrap = 20
	hp = 50
	$body.position = position
	$StatusEffectsBar.position = position
	$ruby.position = position
	$hp.position = position + Vector2(-20, 64)
	$hp.text = str(hp)


func start() -> void:
	$Animations.play("boot_up")
	await $Animations.animation_finished
	awake = true
	$ShootTimer.start()


func _process(delta: float) -> void:
	if !awake:
		return
	
	if fliped:
		rotation_degrees -= 170 * delta
	else:
		rotation_degrees += 170 * delta


func _on_shoot_timer_timeout() -> void:
	if not is_dead:
		attack.play(self)


func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)
