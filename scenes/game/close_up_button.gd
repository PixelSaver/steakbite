extends Button
class_name CloseUpButton

var t: Tween
func _notification(what: int) -> void:
	if t and t.is_running(): t.kill()
	match what:
		NOTIFICATION_FOCUS_ENTER:
			#SOUND Close up steak yes/no button hover
			AudioManager.play(AudioManager.Audio.buttonHover)
			t = create_tween().set_ease(Tween.EASE_OUT)
			t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
			t.tween_property(self, "modulate", Color.RED, 0.6)
			AudioManager.play(AudioManager.Audio.buttonHover)
		NOTIFICATION_FOCUS_EXIT:
			t = create_tween().set_ease(Tween.EASE_OUT)
			t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
			t.tween_property(self, "modulate", Color.WHITE, 0.6)
