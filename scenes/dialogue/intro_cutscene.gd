extends PixelMenu

@export var butler_normal: Texture
@export var butler_punch: Texture
@export var butler_sprite: TextureRect
@export var panel: Panel
@export var balloon: CanvasLayer
@export var controls_label: Control
@export var game: GameContainer

var t: Tween

func _ready():
	panel.modulate.a = 0.0
	butler_sprite.offset_transform_enabled = true
	butler_sprite.offset_transform_position_ratio.x = -0.75
	SignalBus.game_start.connect(func():
		print("Starting")
		start_anim()
	)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)

func start_anim():
	show()
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.tween_property(butler_sprite, "offset_transform_position_ratio:x", 0.0, 0.7)
	t.tween_property(panel, "modulate:a", 1.0, 0.7)
	t.tween_callback(func():
		balloon.start(balloon.dialogue_resource, "", [{ "num_poison" = game.num_poisoned }, { "total" = (game.map_size.x * game.map_size.y) }])
	).set_delay(0.3)

func _on_dialogue_end(_resource):
	print("dialogue end called from intro_cutscene")
	if not self.visible: return
	end_anim()

func end_anim():
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.tween_property(butler_sprite, "offset_transform_position_ratio:x", -0.75, 0.7)
	t.tween_property(panel, "modulate:a", 0.0, 0.7)
	await t.finished
	TurnManager.state = TurnManager.TurnState.STEAK_ONE
	SignalBus.intro_cutscene_finished.emit()
	self.hide()
	self.queue_free()

func _process(_delta):
	if Input.is_action_just_pressed("w") or Input.is_action_just_pressed("s"):
		butler_sprite.show()
		balloon.hide()
		controls_label.hide()
		butler_sprite.texture = butler_punch
		AudioManager.play(AudioManager.Audio.BUTLER_PUNCH)
		await get_tree().create_timer(0.5).timeout
		end_anim()
