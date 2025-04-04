extends HBoxContainer

class_name RoomListItem

signal join_existing_room()

@export var room_id:String:
	set(value):
		room_id = value
		$RoomIdLabel.text = value

@export var region:String:
	set(value):
		region = value
		$RoomRegionLabel.text = value


func _on_button_pressed():
	join_existing_room.emit()


func freeze() -> void:
	$Button.disabled = true


func unfreeze() -> void:
	$Button.disabled = false
