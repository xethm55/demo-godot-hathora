extends CenterContainer

signal join_new_room(region)

var room_list_item_scene:PackedScene = preload("res://Interfaces/RoomListItem.tscn")
@onready var room_list_anchor:VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var nickname_line_edit:LineEdit = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var new_room_join_button:Button = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/Button
@onready var region_option_button:OptionButton = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/OptionButton
@onready var loading_region_list_label:Label = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/Label

var ping_calc_scene:PackedScene = preload("res://Tools/PingCalculator.tscn")

var _region_name_max_length:int
var _best_ping:int = 999999
var _best_ping_region_index:int = 0
var _remaining_region_ping_to_calculate:Array[Hathora.Region]


func _ready():
	_region_name_max_length = Hathora.REGION_NAMES.values().reduce(func(max:String, val:String): return val if val.length() > max.length() else max).length()
	for region in Hathora.Region.values():
		region_option_button.add_item(format_region_text(region), region)


func format_region_text(region:Hathora.Region, ping:int = -1) -> String:
	return "{region} {ping}ms".format({"region":"%-*s" % [_region_name_max_length, Hathora.REGION_NAMES[region]], "ping":"%4s" % (ping if ping != -1 else "? ")})


func show_alert(message:String) -> void:
	$AcceptDialog.dialog_text = message
	$AcceptDialog.show()


func hide_alert() -> void:
	$AcceptDialog.hide()


func show_connecting_popup() -> void:
	$PopupPanel.show()


func hide_connecting_popup() -> void:
	$PopupPanel.hide()


func add_room_to_list(room_id:String, region:String) -> RoomListItem:
	var new_room_list_item:RoomListItem = room_list_item_scene.instantiate()
	room_list_anchor.add_child(new_room_list_item)
	new_room_list_item.room_id = room_id
	new_room_list_item.region = region
	return new_room_list_item


func clean_room_list() -> void:
	for room_list_item in room_list_anchor.get_children():
		room_list_item.queue_free()


func display_empty_room_list() -> void:
	var empty_label:Label = Label.new()
	empty_label.text = "Empty room list"
	room_list_anchor.add_child(empty_label)


func _on_button_pressed():
	join_new_room.emit(region_option_button.selected)


func freeze() -> void:
	nickname_line_edit.editable = false
	new_room_join_button.disabled = true
	for room_list_item in room_list_anchor.get_children():
		if not room_list_item is Label:
			room_list_item.freeze()


func unfreeze() -> void:
	nickname_line_edit.editable = true
	new_room_join_button.disabled = false
	for room_list_item in room_list_anchor.get_children():
		if not room_list_item is Label:
			room_list_item.unfreeze()


func _on_ready() -> void:
	var res = await HathoraSDK.discovery_v2.get_ping_service_endpoints().async()
	if res.is_error():
		show_alert(res.as_error().message)
		return
	for ping_service in res.get_data():
		_remaining_region_ping_to_calculate.push_back(ping_service.region)
		var ping_calculator = PingCalculator.new(ping_service.host, ping_service.port, ping_service.region)
		ping_calculator.done_calculation.connect(_on_ping_calculated)
		ping_calculator.lost_service_connection.connect(_on_ping_lost_service_connection)
		add_child(ping_calculator)
		var error:Error = ping_calculator.start_calculate_ping_to_host()
		if error:
			_remaining_region_ping_to_calculate.erase(ping_service.region)
			ping_calculator.queue_free()
			show_alert("Error " + str(error) + " when trying to create a coonection to ping service")


func _on_ping_calculated(region:Hathora.Region, ping:int) -> void:
	region_option_button.set_item_text(region, format_region_text(region, ping))
	if ping < _best_ping:
		_best_ping = ping
		region_option_button.selected = region_option_button.get_item_index(region)
	_remaining_region_ping_to_calculate.erase(region)
	if _remaining_region_ping_to_calculate.is_empty():
		region_option_button.disabled = false
		new_room_join_button.disabled = false
		loading_region_list_label.hide()


func _on_ping_lost_service_connection(code:int, reason:String) -> void:
	show_alert("Ping service webSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
