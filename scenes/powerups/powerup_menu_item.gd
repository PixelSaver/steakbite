extends Button

class_name PowerupMenuItem

@export var is_empty : bool
func _ready() -> void:
	self.focus_entered.connect(_set_focus.bind(true))
	self.focus_exited.connect(_set_focus.bind(false))

func _set_focus(entered: bool) -> void:
	if (entered):
		self.modulate = Color.RED
	else:
		self.modulate = Color.WHITE
