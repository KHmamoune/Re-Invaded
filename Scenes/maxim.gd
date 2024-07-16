extends Area2D


signal dead


var hp: int = 40
var is_dead: bool = false
var awake: bool = false
var charging: bool = false
var scrap: int = 20
var status_effects: Dictionary = {}


func _process(_delta: float) -> void:
	if !awake:
		return
	
	if !$Animations.is_playing():
		$Animations.play("bite")
	
	if not charging:
		var player: Node = get_tree().get_nodes_in_group("player")[0]
		var t: Tween = create_tween()
		t.tween_property(self, "position", player.position-Vector2(0, 200), 0.4)


func _ready() -> void:
	$hp.text = str(hp)


func start() -> void:
	$Animations.play("wake_up")
	await $Animations.animation_finished
	$Animations.play("follow")
	awake = true
	$ChargeTimer.start(randf_range(2.0, 4.0))


func take_damage(dmg: int) -> void:
	Audio.play_sfx(Audio.sfx_hit)
	hp -= dmg
	$hp.text = str(hp)
	
	if hp <= 0 and !is_dead:
		is_dead = true
		$Hurtbox.set_deferred("disabled", true)
		emit_signal("dead")
		queue_free()


func _on_charge_timer_timeout() -> void:
	set_charging(true)
	var t: Tween = create_tween()
	flash(Color.YELLOW, 0.5)
	t.tween_property(self, "position", position+Vector2(0, -50), 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_callback(Callable(flash).bind(Color.YELLOW, 0))
	t.tween_property(self, "position", position+Vector2(0, 400), 0.8)
	t.tween_callback(Callable(set_charging).bind(false))
	$ChargeTimer.start(randf_range(2.0, 4.0))


func flash(color: Color, mod: float) -> void:
	$Sprite2D.material.set_shader_parameter("flash_color", color)
	$Sprite2D.material.set_shader_parameter("flash_modifier", mod)


func set_charging(val: bool) -> void:
	charging = val
	if charging == true:
		Audio.play_sfx(Audio.sfx_flash)
	
	if charging == false:
		position = position + Vector2(0, -900)


func _on_body_entered(body: Node) -> void:
	if body.has_method("lose_health"):
		body.lose_health()

func update_status_bar() -> void:
	$StatusEffectsBar.update_status_effects(status_effects)