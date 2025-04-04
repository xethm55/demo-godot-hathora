extends Node

var token:String = ""
var player_nickname:String

@onready var main_camera_anchor:Node3D = $Node3D
@onready var main_camera:Camera3D = $Node3D/Camera3D
@onready var menu_ui:CenterContainer = $MenuUI
@onready var control_panel:CenterContainer = $CenterContainer

var is_control_panel_showable:bool = false

func _ready():
	# When exporting the project as a build to deploy on Hathora,
	# modify the Dockerfile to add --server on the line where godot is called to execute the .pck file
	# For debuging purpose you can add --server in the project config at editor/run/main_run_args,
	# to start the server localy
	if "--server" in OS.get_cmdline_args():
		set_process(false)
		remove_child(menu_ui)
		remove_child(control_panel)
	else:
		$MenuUI.join_new_room.connect(_on_join_new_room)
		$Network.connected_to_server.connect(_on_connected_to_server)
		$Network.server_disconnected.connect(_on_server_disconnected)
		$Network.connection_failed.connect(_on_connection_failed)
		$MenuUI.nickname_line_edit.text_changed.connect(_on_nickname_changed)
		player_nickname = $MenuUI.nickname_line_edit.placeholder_text
		if await login_hathora():
			list_lobbies()


func _process(delta):
	main_camera_anchor.rotate_y(0.10 * delta)


func _input(event):
	if event.is_action_pressed("panel") and is_control_panel_showable:
		control_panel.visible = !control_panel.visible


func _unhandled_key_input(event):
	if event.is_action_released("leave"):
		if $Network.is_client_connected:
			$Network.close_connection()
			$MenuUI.show()
			$MenuUI.hide_alert()
			$MenuUI.hide_connecting_popup()
			unfreeze_menu_interface()


func login_hathora() -> bool:
	var res = await HathoraSDK.auth_v1.login_anonymous().async()
	if res.is_error():
		$MenuUI.show_alert(res.as_error().message)
		return false
	else:
		token = res.get_data().token
		return true


func list_lobbies() -> void:
	var res = await HathoraSDK.lobby_v3.list_active_public(token).async()
	if res.is_error():
		$MenuUI.show_alert(res.as_error().message)
	else:
		$MenuUI.clean_room_list()
		if res.is_empty():
			$MenuUI.display_empty_room_list()
		else:
			for room_data in res.get_data():
				var new_room_list_item:RoomListItem = $MenuUI.add_room_to_list(room_data.roomId, Hathora.REGION_NAMES[room_data.region])
				new_room_list_item.join_existing_room.connect(_on_join_existing_room.bind(new_room_list_item.room_id))
	$LobbyRefreshTimer.start($LobbyRefreshTimer.wait_time)


func _on_lobby_refresh_timer_timeout():
	list_lobbies()


func _on_join_new_room(region:Hathora.Region) -> void:
	freeze_menu_interface()
	$MenuUI.show_connecting_popup()
	# for local client debuging, to bypass hathora room creation and directly connect to a local server
	#join_local()
	#return
	var res = await  HathoraSDK.lobby_v3.create(token, Hathora.Visibility.PUBLIC, region).async()
	if res.is_error():
		$MenuUI.show_alert(res.as_error().message)
		unfreeze_menu_interface()
	else:
		join_room(res.get_data().roomId)


func _on_join_existing_room(room_id:String) -> void:
	$MenuUI.show_connecting_popup()
	join_room(room_id)


func freeze_menu_interface() -> void:
	$LobbyRefreshTimer.stop()
	$MenuUI.freeze()


func unfreeze_menu_interface() -> void:
	$LobbyRefreshTimer.start($LobbyRefreshTimer.wait_time)
	$MenuUI.unfreeze()


func join_room(room_id:String) -> void:
	var res = await HathoraSDK.room_v2.get_connection_info(room_id).async()
	if res.is_error():
		$MenuUI.show_alert(res.as_error().message)
		unfreeze_menu_interface()
		$MenuUI.hide_connecting_popup()
	else:
		var connection_info = res.get_data()
		if connection_info.status != Hathora.RoomStatus.ACTIVE:
			join_room(room_id)
		else:
			var error:Error = $Network.create_client(connection_info.exposedPort.host, connection_info.exposedPort.port)
			if error:
				$MenuUI.show_alert("Error number ", error, "while creating a connection to server")
				unfreeze_menu_interface()
				$MenuUI.hide_connecting_popup()


# can be called from "join" button click to bypass all hathora room create and connect local server
func join_local():
	var error:Error = $Network.create_client("localhost", 54321)
	if error:
		$MenuUI.show_alert("Error number ", error, "while creating a connection to server")
		unfreeze_menu_interface()
		$MenuUI.hide_connecting_popup()


func _on_connected_to_server() -> void:
	freeze_menu_interface()
	$MenuUI.hide()
	$MenuUI.hide_connecting_popup()
	main_camera.current = false
	$Network.send_nickname(player_nickname)
	is_control_panel_showable = true
	control_panel.visible = true


func _on_server_disconnected() -> void:
	$MenuUI.show()
	$MenuUI.show_alert("Disconnected from server")
	unfreeze_menu_interface()
	$MenuUI.hide_connecting_popup()
	main_camera.current = true
	is_control_panel_showable = false
	control_panel.visible = false


func _on_connection_failed() -> void:
	$MenuUI.show_alert("Failed to connect to server")
	unfreeze_menu_interface()
	$MenuUI.hide_connecting_popup()
	main_camera.current = true
	is_control_panel_showable = false
	control_panel.visible = false


func _on_nickname_changed(new_nickname:String) -> void:
	player_nickname = new_nickname
