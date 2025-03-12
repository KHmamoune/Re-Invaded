extends PanelContainer


var status: String = ""
var stack: int = 0
var time: float = 0.0


func _ready() -> void:
	update()


func _process(delta: float) -> void:
	%Icon.value = $Timer.time_left


func update() -> void:
	$Timer.wait_time = time
	$Timer.start(time)
	
	%Stack.text = str(stack)
	%Icon.max_value = time
