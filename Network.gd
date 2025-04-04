extends Node

signal connected_to_server()
signal server_disconnected()
signal connection_failed()

var is_client_connected:bool = false

var player_scene:PackedScene = preload("res://characters/player/Player.tscn")

@export var players_anchor:Node3D

var multiplayer_peer = WebSocketMultiplayerPeer.new()

func _enter_tree():
	# When exporting the project as a build to deploy on Hathora,
	# modify the Dockerfile to add --server on the line where godot is called to execute the .pck file
	# For debuging purpose you can add --server in the project config at editor/run/main_run_args,
	# to start the server localy
	if "--server" in OS.get_cmdline_args():
		create_server()


func create_server():
	multiplayer_peer.peer_connected.connect(_on_connected_player)
	multiplayer_peer.peer_disconnected.connect(_on_disconnected_player)
	var error:Error = multiplayer_peer.create_server(54321)
	if error:
		printerr("Error during server creation: ", error)
	else:
		multiplayer.set_multiplayer_peer(multiplayer_peer)
		


func create_client(host:String, port:int) -> Error:
	if multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.disconnect(_on_connected_to_server)
	if multiplayer.server_disconnected.is_connected(_on_server_disconnected):
		multiplayer.server_disconnected.disconnect(_on_server_disconnected)
	if multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.disconnect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	var error:Error
	# Switch the needed protocol. Website host like itch.io needs a secure protocol.
	# From local it's not requiered, but the deployed version on hatohra should be switched to TCP instead of TLS
	if OS.has_feature("web"):
		error = multiplayer_peer.create_client("wss://" + host + ":" + str(port), TLSOptions.client(X509Certificate.new()))
	else:
		error = multiplayer_peer.create_client("ws://" + host + ":" + str(port), TLSOptions.client(X509Certificate.new()))
	if not error:
		multiplayer.set_multiplayer_peer(multiplayer_peer)
	return error


func close_connection() -> void:
	multiplayer_peer.close()
	is_client_connected = false


func send_nickname(value:String) -> void:
	receive_nickname.rpc_id(1, value)


func spawn_player(id:int, nickname:String) -> void:
	var new_player:Player = player_scene.instantiate()
	new_player.player_id = id
	new_player.name = str(id)
	new_player.nickname = nickname
	new_player.text_message_received.connect(_on_text_message_received)
	players_anchor.add_child(new_player)


@rpc("any_peer", "call_remote", "reliable")
func receive_nickname(value:String) -> void:
	if not players_anchor.has_node(str(multiplayer.get_remote_sender_id())):
		spawn_player(multiplayer.get_remote_sender_id(), value)


@rpc("authority", "call_remote", "reliable")
func receive_text_message(from_player_id:int, text:String, text_size_x:int):
	if players_anchor.has_node(str(from_player_id)):
		players_anchor.get_node(str(from_player_id)).chat_interface.bubble_displayer.update_text(text, text_size_x)


func _on_connected_player(id:int) -> void:
	print("New player ", id, " is connected")


func _on_disconnected_player(id:int) -> void:
	print("Player ", id, " is disconnected")
	if players_anchor.has_node(str(id)):
		players_anchor.get_node(str(id)).queue_free()


func _on_connected_to_server() -> void:
	print("Connected to server")
	is_client_connected = true
	connected_to_server.emit()


func _on_server_disconnected() -> void:
	print("Disconnected from server")
	is_client_connected = false
	server_disconnected.emit()


func _on_connection_failed() -> void:
	print("Failed to connect to server")
	connection_failed.emit()


func _on_text_message_received(from_player_id:int, text:String, text_size_x:int) -> void:
	for player in players_anchor.get_children():
		if player.player_id != from_player_id:
			receive_text_message.rpc_id(player.player_id, from_player_id, text, text_size_x)

