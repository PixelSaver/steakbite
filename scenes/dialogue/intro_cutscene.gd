extends Control

@export var butler_normal: Texture
@export var butler_punch: Texture
@export var butler_sprite: TextureRect
@export var balloon: CanvasLayer
@export var controls_label: Control

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)

func _on_dialogue_end(_resource):
	end_anim()

func _process(_delta):
	if Input.is_action_just_pressed("space"):
		butler_sprite.show()
		balloon.hide()
		controls_label.hide()
		butler_sprite.texture = butler_punch
		await get_tree().create_timer(0.5).timeout
		end_anim()
		
func end_anim():
	SignalBus.game_state_changed.emit(TurnManager.TurnState.STEAK_ONE)
	TurnManager.state = TurnManager.TurnState.STEAK_ONE
	self.queue_free()
