@tool
extends Button
class_name SteakTile

@export var left: Sprite2D
@export var right: Sprite2D
## Holder variable to access the current tween, so that
## stopping current tween is super easy.
var t: Tween
## template signal here for now, nothing listens to it
signal steak_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	focus_entered.connect(_on_mouse.bind(true))
	focus_exited.connect(_on_mouse.bind(false))
	pressed.connect(_on_pressed)
	
	# to make sure self expands around center instead of 
	# top left corner
	offset_transform_pivot_ratio = Vector2.ONE * 0.5

func set_right(is_right: bool) -> void:
	if is_right:
		left.hide()
		right.show()
	else:
		left.show()
		right.hide()
func _on_mouse(entered:bool) -> void:
	#DEBUG
	return
	# stops the previous tween where it last was
	@warning_ignore("unreachable_code")
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	if entered: # Highlight the steak
		t.tween_property(self, "offset_transform_scale", Vector2.ONE * 1.1, 0.7)
		# negative y is upwards
		t.tween_property(self, "offset_transform_position_ratio:y", -0.1, 0.7)
	else: # Unhighlight the steak
		t.tween_property(self, "offset_transform_scale", Vector2.ONE, 0.7)
		t.tween_property(self, "offset_transform_position_ratio:y", 0.0, 0.7)
		pass

func _on_pressed() -> void: # pressed
	steak_pressed.emit()
