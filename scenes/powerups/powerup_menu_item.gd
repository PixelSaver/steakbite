extends Button

class_name PowerupMenuItem

@export var is_empty: bool
@export var outline: Control
@export var icon_container: Control
@export var power_icon: TextureRect
@export var power_name: RichTextLabel
@export var cost_label: RichTextLabel
@export var description_label: RichTextLabel

var resource: Powerup
var t: Tween

func _ready() -> void:
	self.focus_entered.connect(_on_focus.bind(true))
	self.focus_exited.connect(_on_focus.bind(false))
	icon_container.pivot_offset_ratio = Vector2(0.5, 0.5)
	self.pressed.connect(_use)

func _use() -> void:
	#SOUND Powerup is bought / used
	var is_player_one = true if TurnManager.state == TurnManager.TurnState.POWERUP_ONE else false
	var scene_root = get_tree().current_scene
	var main = scene_root as Main
	if not main and scene_root != self:
		push_warning("Main isn't scene root for Game")
	resource.apply(is_player_one, main)
	SignalBus.balance_changed.emit()
	pass

func set_visuals(_resource: Powerup) -> void:
	self.resource = _resource
	power_icon.texture = _resource.texture
	power_name.text = "[font_size=35]" + _resource.name
	cost_label.text = "[font_size=35]Cost: " + str(_resource.cost)
	description_label.text = "[font_size=20]" + _resource.description
	self.focus_mode = Control.FOCUS_ALL

func set_empty() -> void:
	is_empty = true
	power_icon.texture = null
	power_name.clear()
	cost_label.clear()
	description_label.clear()
	self.focus_mode = Control.FOCUS_NONE

func _on_focus(entered: bool) -> void:
	if t and t.is_running(): t.kill()
	t = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	if (entered):
		#SOUND Powerup menu item is hovered over / focused on
		outline.visible = true
		t.tween_property(icon_container, "scale", Vector2.ONE * 1.08, 0.3)
	else:
		outline.visible = false
		t.tween_property(icon_container, "scale", Vector2.ONE * 1., 1.)
