extends PixelMenu
class_name PowerupMenu

@export var first_focus: Control
@export var left_side: Control
@export var right_side: Control
@export var continue_button: Control
@export var powerup_resources: Array[Powerup] = []

var t: Tween

func _ready():
	start_anim()

func start_anim() -> void:
	_fill_powerups()
	show() 
	first_focus.grab_focus()
	_assign_focus()
	pass
func end_anim() -> void: 
	hide()
	pass

func _fill_powerups() -> void:
	var left_side_children = left_side.get_children()
	var right_side_children = right_side.get_children()
	
	var combined = left_side_children
	combined.append_array(right_side_children)
	
	for i in combined.size():
		if (i < powerup_resources.size()):
			combined[i].set_visuals(powerup_resources[i])
		elif (combined[i] is PowerupMenuItem):
			combined[i].set_empty()
			combined[i].focus_mode = Control.FOCUS_NONE

func _assign_focus() -> void:
	var left_side_children = left_side.get_children()
	var right_side_children = right_side.get_children()
	
	assert(left_side_children.size() == right_side_children.size(),
		"Powerup menu sides must be the same height!")
	
	for i in left_side_children.size():
		var left : Control = left_side_children[i]
		var right : Control = right_side_children[i]
		if (right is Panel):
			right = continue_button
		
		if (i > 0):
			left.focus_neighbor_top = left.get_path_to(left_side_children[i - 1])
			right.focus_neighbor_top = right.get_path_to(right_side_children[i - 1])
		if (i < left_side_children.size() - 1):
			var left_bot = left_side_children[i + 1]
			var right_bot = right_side_children[i + 1]
			left.focus_neighbor_bottom = left.get_path_to(left_side_children[i + 1])
			if left_bot.is_empty:
				left.focus_neighbor_bottom = left.get_path_to(continue_button)
			right.focus_neighbor_bottom = right.get_path_to(right_side_children[i + 1])
			if right_bot is PowerupMenuItem && right_bot.is_empty:
				right.focus_neighbor_bottom = right.get_path_to(continue_button)
		
		left.focus_neighbor_right = left.get_path_to(right)
		if right is PowerupMenuItem && right.is_empty:
			left.focus_neighbor_right = left.get_path_to(continue_button)
		right.focus_neighbor_left = right.get_path_to(left)
		
	var combined = left_side_children
	combined.append_array(right_side_children)
	var last_idx = powerup_resources.size() - 1
	
	continue_button.focus_neighbor_top = continue_button.get_path_to(combined[last_idx])
	if (last_idx < right_side_children.size()):
		continue_button.focus_neighbor_left = continue_button.get_path_to(combined[last_idx])
	else:
		continue_button.focus_neighbor_left = continue_button.get_path_to(left_side_children[-1])
	
	
	
