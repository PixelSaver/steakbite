@tool
extends Button
class_name DefaultButton

@export var label: RichTextLabel
@export_multiline var button_text: String = "Default Button":
	set(value):
		button_text = value
		if is_instance_valid(label):
			label.text = value
var t : Tween

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		return
	call_deferred("_ensure_label")
	self.add_theme_color_override("font_color", Color("#0000"))

func _ensure_label():
	if label: return
	if self.custom_minimum_size == Vector2.ZERO:
		self.custom_minimum_size = Vector2(150, 80) 
	
	for child in get_children():
		if child is RichTextLabel:
			return
	label = RichTextLabel.new()
	add_child(label)
	label.owner = get_tree().edited_scene_root # required for editor persistence
	label.fit_content = true
	label.scroll_active = false
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.shortcut_keys_enabled = false
	label.clip_contents = false
	label.text = button_text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.bbcode_enabled = true
	label.set_anchors_preset(Control.PRESET_FULL_RECT)

func _ready() -> void:
	self.pivot_offset_ratio = Vector2(0.5, 0.5)
	self.pressed.connect(_on_pressed)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_MOUSE_ENTER:
			_hover()
		NOTIFICATION_MOUSE_EXIT:
			_unhover()
		NOTIFICATION_FOCUS_ENTER:
			_hover()
		NOTIFICATION_FOCUS_EXIT:
			_unhover()

func _on_pressed() -> void:
	#SOUND end turn button pressed (becomes other guys turn)
	AudioManager.play(AudioManager.Audio.endTurn)
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT)
	t.tween_property(self, "scale", Vector2.ONE * 0.95, 0.07)
	t.tween_property(self, "scale", Vector2.ONE * 1.1, 0.07)
	

func _hover() -> void:
	#SOUND end turn button hovered
	AudioManager.play(AudioManager.Audio.buttonSoft)
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(self, "scale", Vector2.ONE * 1.1, 0.7)
	
func _unhover() -> void:
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(self, "scale", Vector2.ONE, 0.7)
