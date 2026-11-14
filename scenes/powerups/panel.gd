extends Panel

var t: Tween
func _ready() -> void:
	self.mouse_entered.connect(_hover.bind(true))
	self.mouse_exited.connect(_hover.bind(false))
	
func _hover(entered:bool) -> void:
	if t and t.is_running(): 
		t.kill()
	t = create_tween().set_trans(Tween.TRANS_QUINT)
	t.set_ease(Tween.EASE_OUT).set_parallel(true)
	if entered:
		t.tween_property(self, "scale", Vector2.ONE * 1.1, 0.3)
		t.tween_property(self, "modulate", Color.RED, 0.3)
	else:
		t.tween_property(self, "scale", Vector2.ONE * 1., 1.)
		t.tween_property(self, "modulate", Color.WHITE, 0.3)
