extends MultiplayerSynchronizer

@export var direction:Vector2 = Vector2.ZERO
@export var rotation:int = 0
@export var jumping:bool = false
@export var is_typing:bool = false

var is_mouse_exit:bool = false
var last_mouse_velocity_x_on_exit:float = 0.0


func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


func _process(delta):
	if is_typing:
		direction = Vector2.ZERO
		rotation = 0
	else:
		direction = Input.get_vector("right", "left", "backward", "forward")
		if Input.get_last_mouse_velocity().x:
			rotation = -1 * sign(Input.get_last_mouse_velocity().x)
		elif is_mouse_exit:
			rotation = -1 * sign(last_mouse_velocity_x_on_exit)
		else:
			rotation = 0
		if Input.is_action_just_pressed("jump"):
			jump.rpc()


func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		is_mouse_exit = false
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
		last_mouse_velocity_x_on_exit = Input.get_last_mouse_velocity().x
		is_mouse_exit = true


@rpc("any_peer", "call_local", "reliable")
func jump():
	jumping = true
