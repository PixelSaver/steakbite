extends Control

@export var butler_normal: Texture
@export var butler_punch: Texture
@export var butler_sprite: TextureRect
@export var balloon: CanvasLayer
@export var controls_label: Control

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)

func _on_dialogue_end(_resource):
	self.queue_free()

func _process(delta):
	if Input.is_action_just_pressed("space"):
		balloon.visible = false
		controls_label.visible = false
		butler_sprite.texture = butler_punch
		await get_tree().create_timer(0.5).timeout
		self.queue_free()
