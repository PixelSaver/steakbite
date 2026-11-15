extends Resource
class_name Powerup

@export var name: String = "Powerup"
@export var cost: int = 1
@export_multiline var description: String
@export var id: int = 0
@export var texture: Texture2D


func apply(_target_player_id: int) -> void:
	pass
