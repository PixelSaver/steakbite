extends PixelMenu

@export var butler_normal: Texture
@export var butler_punch: Texture
@export var butler_sprite: TextureRect
@export var balloon: IntroBalloon
@export var controls_label: Control

func _ready():
	SignalBus.game_start.connect(func():
		print("Starting")
		start_anim()
	)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)

func start_anim():
	show()
	balloon.start(balloon.dialogue_resource)

func _on_dialogue_end(_resource):
	if not self.visible: return
	end_anim()

func end_anim():
	TurnManager.state = TurnManager.TurnState.STEAK_ONE
	SignalBus.game_state_changed.emit(TurnManager.TurnState.STEAK_ONE)
	SignalBus.intro_cutscene_finished.emit()
	self.hide()
	self.queue_free()

func _process(_delta):
	if Input.is_action_just_pressed("space"):
		balloon.visible = false
		controls_label.visible = false
		butler_sprite.texture = butler_punch
		await get_tree().create_timer(0.5).timeout
		end_anim()
