extends Area2D


signal dead


var hp: int = 50
var is_dead: bool = false
var scrap: int = 10
var status_effects: Dictionary = {}

@onready var bullet: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var attack: Card.AttackPattren = Card.AttackPattren.new(bullet, 1, 1, [180], 0.2, 800, [Vector2.ZERO], 800, 1)


func _ready() -> void:
	$hp.text = str(hp)


func start() -> void:
	$Animations.play("boot_up")
	await $Animations.animation_finished
	$ShootTimer.start()


func take_damage(dmg: int) -> void:
	Audio.play_sfx(Audio.sfx_hit)
	hp -= dmg
	$hp.text = str(hp)
	
	if hp <= 0 and !is_dead:
		is_dead = true
		$Hurtbox.set_deferred("disabled", true)
		emit_signal("dead")
		queue_free()


func _on_shoot_timer_timeout() -> void:
	if not is_dead:
		$Animations.play("RESET")
		$Animations.play("fire")
		attack.play(self)


func shoot(bul: Node, _seconds: float, sfx: AudioStream = Audio.sfx_shoot) -> void:
	bul.set_collision_mask_value(1, true)
	Audio.play_sfx(sfx)
	get_parent().add_child(bul)

func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)
