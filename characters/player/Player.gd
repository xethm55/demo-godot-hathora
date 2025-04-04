extends CharacterBody3D

class_name Player

signal text_message_received(from_player_id:int, text:String, text_size_x:int)

@export var player_id:int:
	set(value):
		player_id = value
		$PlayerInputSynchronizer.set_multiplayer_authority(value)
@export var nickname:String
@export var speed = 5.0
@export var jump_speed = 6.0
@export var exported_velocity:Vector3

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var spring_arm:SpringArm3D = $SpringArm3D
@onready var model:GobotSkin = $GobotSkin
@onready var player_input_synchonizer:MultiplayerSynchronizer = $PlayerInputSynchronizer
@onready var chat_interface = $Interface

var _is_typing:bool = false


func _ready():
	print("Poping player with authority id: ", player_id)
	chat_interface.nickname = nickname
	chat_interface.is_local_player = is_local_authority()
	if is_local_authority():
		chat_interface.bubble_displayer.typing.connect(_on_typing)
	$SpringArm3D/Camera3D.current = is_local_authority()


func _physics_process(delta):
	velocity = exported_velocity
	
	var direction = (transform.basis * Vector3(player_input_synchonizer.direction.x, 0, player_input_synchonizer.direction.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	if player_input_synchonizer.rotation:
		rotate_y(deg_to_rad(2) * player_input_synchonizer.rotation)
	
	if player_input_synchonizer.jumping and is_on_floor():
		velocity.y = jump_speed
	player_input_synchonizer.jumping = false
	velocity.y -= gravity * delta
	
	move_and_slide()
	
	exported_velocity = velocity


func _process(delta):
	var real_velocity = get_real_velocity()
	if not is_on_floor() and real_velocity.y > 0:
		model.jump()
	elif not is_on_floor() and real_velocity.y < 0:
		model.fall()
	elif Vector2(real_velocity.x, real_velocity.z).length() > 0:
		model.run()
	elif player_input_synchonizer.rotation:
		model.walk()
	else:
		model.idle()
	
	if player_input_synchonizer.is_typing != _is_typing:
		if player_input_synchonizer.is_typing:
			chat_interface.bubble_displayer.show_typing_bubble()
		else:
			chat_interface.bubble_displayer.hide_typing_bubble()
	_is_typing = player_input_synchonizer.is_typing


func is_local_authority():
	return player_id == multiplayer.get_unique_id()


func _on_typing(is_typing:bool, text:String, text_size_x:int):
	player_input_synchonizer.is_typing = false
	if is_typing:
		player_input_synchonizer.is_typing = true
	elif text.length():
		send_text_message(text, text_size_x)


func send_text_message(text:String, text_size_x:int) -> void:
	receive_text_message_to_server.rpc_id(1, text, text_size_x)


@rpc("any_peer", "call_remote", "reliable")
func receive_text_message_to_server(text:String, text_size_x:int) -> void:
	if text.length() > chat_interface.bubble_displayer.text_edit.max_length:
		text = text.left(chat_interface.bubble_displayer.text_edit.max_length)
	text_message_received.emit(multiplayer.get_remote_sender_id(), text, text_size_x)
	


