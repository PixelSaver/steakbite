extends Tile


@export var right: Node
@export var left: Node

func set_right(is_right: bool) -> void:
	right.visible = is_right
	left.visible = not is_right

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_FOCUS_ENTER:
			#SOUND Spotlight points to empty tile / empty table is highlighted
			pass
