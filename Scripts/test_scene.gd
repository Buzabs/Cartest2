class_name level
extends Node2D


@onready var path = %Track
@onready var path_follow = %TrackFollow
@onready var lap_counter_text = %LapCount
@onready var bracket_text = %Bracket
@onready var nitro_progress: ProgressBar = $Car/CanvasLayer/NitroProgress

var checkpoints_arr = []
var checkpoints_count: int = 0

var cars_arr = []

var player_id = "PlayerCar"

func _ready() -> void:
	GlobalVariables.laps = 0
	checkpoints_arr = get_tree().get_nodes_in_group("Checkpoints")
	cars_arr = get_tree().get_nodes_in_group("Cars")
	checkpoints_count = checkpoints_arr.size()
	GlobalVariables.reached_checkpoints = 0
	lap_counter_text.text += "LAP: 0 / " + str(GlobalVariables.max_laps)
	GlobalVariables.race_finished.connect(_on_car_finished_race)
	

func get_path_direction(pos):
	var offset = path.curve.get_closest_offset(pos)
	path_follow.progress = offset
	return path_follow.transform.x

func _on_lap_counter_body_entered(_body: Node2D) -> void:
	if GlobalVariables.reached_checkpoints == checkpoints_count:
		GlobalVariables.laps += 1
		lap_counter_text.text = "LAP: " + str(GlobalVariables.laps) + " / " + str(GlobalVariables.max_laps)
		GlobalVariables.reached_checkpoints = 0
		GlobalVariables.reset_reached.emit()
		
	if GlobalVariables.laps == GlobalVariables.max_laps and player_id not in GlobalVariables.bracket:
		GlobalVariables.bracket.append(player_id)
		GlobalVariables.race_finished.emit()

func _on_car_finished_race():
	GlobalVariables.finished_cars += 1
	if cars_arr.size() == GlobalVariables.finished_cars:
		for i in GlobalVariables.bracket:
			bracket_text.text += i + "\n"

func _process(delta: float) -> void:
	nitro_progress.value = GlobalVariables.drift_time_percentage
