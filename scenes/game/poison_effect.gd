extends TextureRect
class_name PoisonEffect

var t: Tween

func _ready() -> void:
	SignalBus.game_start.connect(_on_restart)

func _on_restart() -> void:
	hide()

func start_anim() -> void:
	print("Poisined effect")
	show()
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(self, "modulate:a", 1, 0.6)

func set_right(is_right: bool) -> void:
	if is_right:
		self.offset_transform_position_ratio.x = -.5
		self.flip_h = true
	else:
		self.offset_transform_position_ratio.x = 0.
		self.flip_h = false
