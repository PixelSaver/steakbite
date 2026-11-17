extends PixelMenu
class_name Credits

signal end_animationing
@export var flip_comp: FlipUpComponent
@export var exit_credits: DefaultButton
var t: Tween 

func _ready() -> void:
	hide()
	exit_credits.pressed.connect(end_anim)
	await get_tree().process_frame
	flip_comp.flip = 0.0

func start_anim() -> void: 
	show()
	AudioManager.play(AudioManager.Audio.powerMenuFlipDown)
	exit_credits.grab_focus()
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.tween_property(self, "offset_transform_position_ratio:y", 0.0, 0.7)
	t.tween_property(flip_comp, "flip", 1.0, 0.7)
func end_anim() -> void: 
	end_animationing.emit()
	AudioManager.play(AudioManager.Audio.powerMenuFlipDown)
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.tween_property(flip_comp, "flip", 0.0, 0.7)
	t.tween_property(self, "offset_transform_position_ratio:y", -1.0, 0.7)
	await t.finished
	hide()
