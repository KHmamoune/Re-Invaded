extends Enemy


var awake: bool = false
var charging: bool = false


func _ready() -> void:
	color = Color.DARK_GREEN
	area_entered.connect(_on_area_entered)
	scrap = 20
	set_up_hp(80, Vector2(0, 40))
	set_up_status_effects(Vector2(-15, 55))


func _process(_delta: float) -> void:
	if !awake:
		return
	
	if !$Animations.is_playing():
		$Animations.play("bite")
	
	if not charging:
		var player: Node = get_tree().get_nodes_in_group("player")[0]
		var t: Tween = create_tween()
		t.tween_property(self, "position", player.position-Vector2(0, 200), 0.4)


func start() -> void:
	$Animations.play("wake_up")
	await $Animations.animation_finished
	$Animations.play("follow")
	awake = true
	$ChargeTimer.start(randf_range(2.0, 4.0))


func _on_charge_timer_timeout() -> void:
	set_charging(true)
	var t: Tween = create_tween()
	flash(Color.YELLOW, 0.5)
	t.tween_property(self, "position", position+Vector2(0, -50), 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_callback(Callable(flash).bind(Color.YELLOW, 0))
	t.tween_property(self, "position", position+Vector2(0, 400), 0.8)
	t.tween_callback(Callable(set_charging).bind(false))
	$ChargeTimer.start(randf_range(2.0, 4.0))


func flash(flash_color: Color, mod: float) -> void:
	$Sprite2D.material.set_shader_parameter("flash_color", flash_color)
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
