extends Enemy


var awake: bool = false
var fliped: bool = false


@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 2, 1, [0, 180], 0.2, 400, [Vector2.ZERO, Vector2.ZERO], 700, 1)


func _ready() -> void:
	color = Color.DIM_GRAY
	area_entered.connect(_on_area_entered)
	scrap = 20
	set_up_hp(50, Vector2(0, 65))
	set_up_status_effects(Vector2(-15, 80))
	$body.position = position
	$ruby.position = position


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


func hit_flash() -> void:
	$body.material.set_shader_parameter("flash_modifier", 1)
	await get_tree().create_timer(0.02).timeout
	$body.material.set_shader_parameter("flash_modifier", 0)
