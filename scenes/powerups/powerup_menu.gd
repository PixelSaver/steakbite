extends PixelMenu
class_name PowerupMenu

@export var first_focus: Control
@export var left_side: Control
@export var right_side: Control

var t: Tween

func start_anim() -> void:
	show() 
	first_focus.grab_focus()
	pass
func end_anim() -> void: 
	hide()
	pass

func _assign_focus() -> void:
	var left_side_children = left_side.get_children()
	var right_side_children = right_side.get_children()
