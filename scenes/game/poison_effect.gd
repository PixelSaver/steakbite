extends TextureRect


var t: Tween

func start_anim() -> void:
	if t and t.is_running(): t.kill()
	
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(self, "modulate:a", 1, 0.6)
