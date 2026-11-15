extends Button

@export var outline: Control

func _ready() -> void:
	self.focus_entered.connect(_set_focus.bind(true))
	self.focus_exited.connect(_set_focus.bind(false))

func _set_focus(entered: bool) -> void:
	if (entered):
		outline.visible = true
	else:
		outline.visible = false
