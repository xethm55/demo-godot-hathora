extends Node3D

@export var nickname:String:
	set(value):
		nickname = value
		$Sprite3D/SubViewportContainer/SubViewport/VBoxContainer/Nickname.text = nickname
@export var is_local_player:bool:
	set(value):
		$Sprite3D/SubViewportContainer/SubViewport/VBoxContainer/Bubble.is_local_player = value

@onready var container:VBoxContainer = $Sprite3D/SubViewportContainer/SubViewport/VBoxContainer
@onready var bubble_displayer = $Sprite3D/SubViewportContainer/SubViewport/VBoxContainer/Bubble
@onready var nickname_displayer = $Sprite3D/SubViewportContainer/SubViewport/VBoxContainer/Nickname
@onready var subviewport:SubViewport = $Sprite3D/SubViewportContainer/SubViewport
@onready var rendering_sprite:Sprite3D = $Sprite3D


func _ready():
	container.resized.connect(_on_interface_resized)
	nickname_displayer.resized.connect(_on_nickname_label_resized)
	subviewport.size = container.size
	rendering_sprite.offset.x = -nickname_displayer.size.x / 2


func _on_interface_resized():
	subviewport.size = container.size


func _on_nickname_label_resized():
	rendering_sprite.offset.x = -nickname_displayer.size.x / 2
	bubble_displayer.add_theme_constant_override("margin_left", -rendering_sprite.offset.x)

