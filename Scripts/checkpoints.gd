class_name checkpoints
extends Area2D

var reached: bool

func _ready() -> void:
	reached = false
	GlobalVariables.reset_reached.connect(_on_finish_line_reached)
	
func _on_finish_line_reached():
	reached = false

func _on_body_entered(body: Node2D) -> void:
	if !reached and body.has_method("car_collision_id"):
		GlobalVariables.reached_checkpoints += 1
		reached = true
		#print(GlobalVariables.reached_checkpoints)
