extends PixelMenu
class_name PowerupMenu

const TS = TurnManager.TurnState
@export var player_name_label: RichTextLabel
@export var player_balance: RichTextLabel
@export var powerup_resources: Array[Powerup] = []
@export var first_focus: Control
@export var left_side: Control
@export var right_side: Control
## Container with all the buttons in it
@export var subviewport_cont: SubViewportContainer
@export var continue_button: Control
const PERSPECTIVE_SHADER_MATERIAL = preload("res://assets/perspective_shader_material.tres")
var flip_percentage := 0.0 :
	set(val):
		flip_percentage = val
		_set_flip_percentage(val)
var mat: ShaderMaterial

var t: Tween


func _ready():
	subviewport_cont.offset_transform_enabled = true
	mat = PERSPECTIVE_SHADER_MATERIAL.duplicate()
	subviewport_cont.material = mat
	flip_percentage = 0.
	SignalBus.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(new_state: TS) -> void:
	match new_state:
		TS.POWERUP_ONE:
			start_anim()
		TS.STEAK_ONE:
			end_anim()
		TS.POWERUP_TWO:
			start_anim()
		TS.STEAK_TWO:
			end_anim()

#region Flipping animation
func start_anim() -> void:
	assert(mat, "Shadermaterial for PowerupMenu is not initialized")
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.tween_property(self, "flip_percentage", 1., 0.7)
	#t.tween_property(subviewport_cont, "offset_transform_position_ratio:y", 0.0, 0.7)
	_fill_visuals()
	show() 
	first_focus.grab_focus()
	_assign_focus()
func end_anim() -> void:
	assert(mat, "Shadermaterial for PowerupMenu is not initialized")
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.tween_property(self, "flip_percentage", 0., 0.7)
	#t.tween_property(subviewport_cont, "offset_transform_position_ratio:y", 0.5, 0.7)
	
## From [0,1] to set the flip visual, 0 is down, 1 is up
func _set_flip_percentage(ratio: float) -> void:
	assert(mat, "Shadermaterial for PowerupMenu is not initialized")
	mat.set_shader_parameter("x_rot", remap(ratio, 0, 1, 90, 0))
	subviewport_cont.offset_transform_position_ratio.y = remap(ratio, 0, 1, 0.5, 0)
	visible = not is_equal_approx(0., ratio)
#endregion

func _fill_visuals() -> void:
	# TODO: let players write their names
	var player_name = "Player 1" if TurnManager.state == TurnManager.TurnState.POWERUP_ONE else "Player 2"
	player_name_label.text = "[font_size=50]" + player_name + ": Select a Powerup"
	
	# TODO: hook up player balance
	var balance: int = 0
	player_balance.text = "[font_size=50]Balance: " + str(balance)
	
	var left_side_children = left_side.get_children()
	var right_side_children = right_side.get_children()
	left_side_children.pop_front()
	right_side_children.pop_front()
	
	var combined = left_side_children
	combined.append_array(right_side_children)
	
	for i in combined.size():
		if (i < powerup_resources.size()):
			combined[i].set_visuals(powerup_resources[i])
		elif (combined[i] is PowerupMenuItem):
			combined[i].set_empty()
			combined[i].focus_mode = Control.FOCUS_NONE
			combined[i].mouse_filter = Control.MOUSE_FILTER_IGNORE

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
	
	left_side_children.pop_front()
	right_side_children.pop_front()
	var combined = left_side_children
	combined.append_array(right_side_children)
	var last_idx = powerup_resources.size() - 1
	
	continue_button.focus_neighbor_top = continue_button.get_path_to(combined[last_idx])
	if (last_idx < right_side_children.size()):
		continue_button.focus_neighbor_left = continue_button.get_path_to(combined[last_idx])
	else:
		continue_button.focus_neighbor_left = continue_button.get_path_to(left_side_children[-1])
	
	
	
