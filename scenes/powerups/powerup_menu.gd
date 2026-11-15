extends PixelMenu
class_name PowerupMenu

@export var first_focus: Control
@export var left_side: Control
@export var right_side: Control
@export var continue_button: Control

var t: Tween

func _ready():
	start_anim()

func start_anim() -> void:
	show() 
	first_focus.grab_focus()
	_assign_focus()
	pass
func end_anim() -> void: 
	hide()
	pass

func _assign_focus() -> void:
	var left_side_children = left_side.get_children()
	var right_side_children = right_side.get_children()
	
	assert(left_side_children.size() == right_side_children.size(),
		"Powerup menu sides must be the same height!")
	
	for i in left_side_children.size():
		var left : Control = left_side_children[i]
		var right : Control = right_side_children[i]
		if (right is Panel):
			right = right.get_node("./AspectRatioContainer/Next Button")
		# assign top and bottom
		if (i > 0):
			left.focus_neighbor_top = left.get_path_to(left_side_children[i - 1])
			right.focus_neighbor_top = right.get_path_to(right_side_children[i - 1])
		if (i < left_side_children.size() - 1):
			var left_bot = left_side_children[i + 1]
			var right_bot = right_side_children[i + 1]
			if !left_bot.is_empty:
				left.focus_neighbor_bottom = left.get_path_to(left_side_children[i + 1])
			else:
				left.focus_neighbor_bottom = "."
			if right_bot is PowerupMenuItem && !right_bot.is_empty:
				right.focus_neighbor_bottom = right.get_path_to(right_side_children[i + 1])
			else:
				right.focus_neighbor_bottom = right.get_path_to(continue_button)
		# assign left and right
		if right is PowerupMenuItem && !right.is_empty:
			left.focus_neighbor_right = left.get_path_to(right)
		else:
			left.focus_neighbor_right = left.get_path_to(continue_button)
		if !left.is_empty:
			right.focus_neighbor_left = right.get_path_to(left)
		else:
			right.focus_neighbor_left = "."
		
