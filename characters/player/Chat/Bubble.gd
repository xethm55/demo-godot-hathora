extends MarginContainer

signal typing(is_typing, text)

const MAX_SIZE_X = 250
var visibility_tweener:Tween
@export var is_local_player:bool = false

@onready var text_label:Label = $VBoxContainer/MarginContainer/MarginContainer/Label
@onready var text_edit:LineEdit = $VBoxContainer/MarginContainer/MarginContainer/LineEdit
@onready var typing_anim:TextureRect = $VBoxContainer/MarginContainer/MarginContainer/TextureRect

var typing_bubble_is_queuing:bool = false

func _ready():
	modulate = Color(1, 1, 1, 0)


func _unhandled_key_input(event):
	if event.is_action_pressed("chat") and is_local_player:
		if visibility_tweener and visibility_tweener.is_running():
			visibility_tweener.stop()
		modulate = Color(1, 1, 1, 1)
		text_label.text = ""
		text_label.visible = false
		text_edit.visible = true
		text_edit.grab_focus()
		typing.emit(true, "", 0)


func _on_line_edit_text_submitted(new_text:String):
	text_edit.text = ""
	text_edit.visible = false
	if new_text.is_empty():
		modulate = Color(1, 1, 1, 0)
		text_label.text = ""
		typing.emit(false, "", 0)
	else:
		update_text(new_text, text_edit.size.x)
		typing.emit(false, new_text, text_edit.size.x)


func update_text(value:String, size_x) -> void:
	text_label.custom_minimum_size.x = min(size_x, MAX_SIZE_X)
	text_label.text = value
	text_label.visible = true
	typing_anim.visible = false
	modulate = Color(1, 1, 1, 1)
	tween_visibility(value.length())


func tween_visibility(text_length:int) -> void:
	if visibility_tweener and visibility_tweener.is_running():
		visibility_tweener.stop()
	visibility_tweener = get_tree().create_tween()
	visibility_tweener.set_trans(Tween.TRANS_EXPO)
	visibility_tweener.set_ease(Tween.EASE_IN)
	visibility_tweener.finished.connect(_on_visibility_tween_finished)
	visibility_tweener.tween_property(self, "modulate", Color(1, 1, 1, 0), clampf(float(text_length) / 20, 5, 20))


func _on_visibility_tween_finished() -> void:
	if typing_bubble_is_queuing:
		typing_bubble_is_queuing = false
		display_typing_bubble()


func show_typing_bubble() -> void:
	if not is_local_player:
		typing_bubble_is_queuing = false
		if visibility_tweener and visibility_tweener.is_running():
			typing_bubble_is_queuing = true
		else:
			display_typing_bubble()


func display_typing_bubble() -> void:
	text_label.visible = false
	typing_anim.visible = true
	modulate = Color(1, 1, 1, 1)


func hide_typing_bubble() -> void:
	if not is_local_player:
		typing_bubble_is_queuing = false
		if visibility_tweener:
			if not visibility_tweener.is_running():
				modulate = Color(1, 1, 1, 0)
		else:
			modulate = Color(1, 1, 1, 0)
