extends Button

@export var tweenable: Tweenable
@onready var arrow_cont: Control = $CenterContainer/Control
@export var noise: NoiseTexture2D
var t: Tween

func _ready() -> void:
	tweenable.tween_value = 1.0

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_FOCUS_ENTER:
			_hover()
		NOTIFICATION_FOCUS_EXIT:
			_hover(false)

func _process(_delta: float) -> void:
	var _t := Time.get_ticks_msec() / 50.0
	var x = noise.noise.get_noise_2d(
		_t, 0.0
	) -0.5
	var y = noise.noise.get_noise_2d(
		0.0, _t
	) 
	arrow_cont.offset_transform_position = Vector2(x * 50, y * 20)

func _hover(is_hovered:bool=true) -> void:
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	if is_hovered:
		t.tween_property(tweenable, "tween_value", 0.0, 0.4)
	else:
		t.tween_property(tweenable, "tween_value", 1.0, 0.4)
