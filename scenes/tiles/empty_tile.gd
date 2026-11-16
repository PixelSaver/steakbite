extends Tile


@export var right: Node
@export var left: Node

func set_right(is_right: bool) -> void:
	right.visible = is_right
	left.visible = not is_right
