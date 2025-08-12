class_name level
extends Node2D


@onready var path = %Track
@onready var path_follow = %TrackFollow
@onready var lap_counter_text = %LapCount

@export var max_laps: int = 3

var checkpoints = []
var checkpoints_count: int = 0

func _ready() -> void:
	GlobalVariables.laps = 0
	checkpoints = get_tree().get_nodes_in_group("Checkpoints")
	checkpoints_count = checkpoints.size()
	GlobalVariables.reached_checkpoints = 0
	lap_counter_text.text += "LAP: 0 / " + str(max_laps)
	


func get_path_direction(pos):
	var offset = path.curve.get_closest_offset(pos)
	path_follow.progress = offset
	return path_follow.transform.x



func _on_lap_counter_body_entered(_body: Node2D) -> void:
	print("hello")
	if GlobalVariables.reached_checkpoints == checkpoints_count:
		GlobalVariables.laps += 1
		lap_counter_text.text = "LAP: " + str(GlobalVariables.laps) + " / " + str(max_laps)
		GlobalVariables.reached_checkpoints = 0
		GlobalVariables.reset_reached.emit()
