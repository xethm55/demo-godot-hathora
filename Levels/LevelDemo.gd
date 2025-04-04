extends Node3D

@onready var hathora_decoration:StaticBody3D = $HathoraDecoration/Body

func _ready():
	$SlopeBlocks/Slope1/MeshInstance3D.create_convex_collision()


func _physics_process(delta):
	hathora_decoration.rotate_y(1 * delta)
