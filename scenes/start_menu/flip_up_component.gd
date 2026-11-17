@tool
extends Node
class_name FlipUpComponent

@export_range(0.0, 1.0, .0001) var flip: float = 0.0:
	set(val):
		flip = val
		apply(val)
@export var parent: Control
const PERSPECTIVE_SHADER_MATERIAL = preload("res://assets/perspective_shader_material.tres")
var _parent: Control
var mat: ShaderMaterial

func _ready() -> void: 
	if parent:
		_parent = parent
	else:
		parent = get_parent() as Control
	if not parent or parent == null:
		push_warning("Tweenable <%s> could not find it's parent, queue_free()ing" % self)
		queue_free()
	parent.offset_transform_enabled = true
	mat = PERSPECTIVE_SHADER_MATERIAL.duplicate() as ShaderMaterial
	parent.material = mat
	parent.offset_transform_pivot_ratio = Vector2.ONE * 0.5

## From [0,1] to set the flip visual, 0 is down, 1 is up
func apply(t: float) -> void:
	if parent == null: return
	assert(mat, "Shadermaterial for FlipUpComponent is not initialized")
	mat.set_shader_parameter("x_rot", remap(t, 0, 1, 90, 0))
	parent.offset_transform_position_ratio.y = remap(t, 0, 1, 0.5, 0)
	parent.visible = not is_equal_approx(0., t)
