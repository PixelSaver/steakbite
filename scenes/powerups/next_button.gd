extends Button

@export var outline: Control

var t: Tween

func _ready() -> void:
	self.focus_entered.connect(_set_focus.bind(true))
	self.focus_exited.connect(_set_focus.bind(false))
	self.pressed.connect(func():
		if TurnManager.state == TurnManager.TurnState.POWERUP_ONE:
			TurnManager.state = TurnManager.TurnState.STEAK_ONE
		elif TurnManager.state == TurnManager.TurnState.POWERUP_TWO:
			TurnManager.state = TurnManager.TurnState.STEAK_TWO
	)
	self.pivot_offset_ratio = Vector2(0.5, 0.5)

func _set_focus(entered: bool) -> void:
	if t and t.is_running(): t.kill()
	t = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	if (entered):
		outline.visible = true
		t.tween_property(self, "scale", Vector2.ONE * 1.08, 0.3)
	else:
		outline.visible = false
		t.tween_property(self, "scale", Vector2.ONE * 1., 1.)
