extends Resource
class_name Powerup

@export var name: String = "Powerup"
@export var cost: int = 1
@export_multiline var description: String
@export var id: int = 0
@export var texture: Texture2D


func apply(_is_player_one: bool) -> void:
	pass
