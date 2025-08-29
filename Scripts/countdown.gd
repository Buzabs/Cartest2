extends Node2D

@onready var animation = $AnimatedSprite2D

func _ready() -> void:
	GlobalVariables.can_start = false
	animation.play("default")
	

func _process(delta: float) -> void:
	if !animation.is_playing() and !GlobalVariables.can_start:
		GlobalVariables.can_start = true
		animation.play("off")
		print(GlobalVariables.can_start)
