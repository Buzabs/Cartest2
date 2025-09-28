class_name level
extends Node

var Player = player.new()

const End_screen = preload("res://Scenes/player/race_end.tscn")
const Car = preload("res://Scenes/player/Car.tscn")

@onready var path: Path2D = %Track
@onready var path_follow: PathFollow2D = %TrackFollow
@onready var start_position: Node2D = %PlayerStartPos

var lap_counter_text: RichTextLabel
var bracket_text: RichTextLabel 
var nitro_progress: ProgressBar 

var checkpoints_arr = []
var checkpoints_count: int = 0

var cars_arr = []

var stop_counting_laps = false

func initialize_ui(car):
	lap_counter_text = car.get_node("%PlayerUI").get_node("%LapCount")
	bracket_text = car.get_node("%PlayerUI").get_node("%Bracket")
	nitro_progress = car.get_node("%PlayerUI").get_node("%NitroProgress")
	

func _ready() -> void:
	stop_counting_laps = false
	
	var player_car = Car.instantiate()
	add_child(player_car)
	player_car.position = start_position.position
	
	initialize_ui(player_car)
	
	GlobalVariables.laps = 0
	checkpoints_arr = get_tree().get_nodes_in_group("Checkpoints")
	cars_arr = get_tree().get_nodes_in_group("Cars")
	checkpoints_count = checkpoints_arr.size()
	GlobalVariables.reached_checkpoints = 0
	lap_counter_text.text += "LAP: 0 / " + str(GlobalVariables.max_laps)
	GlobalVariables.race_finished.connect(_on_car_finished_race)
	
	print(GlobalVariables.bracket.is_empty())
	

func get_path_direction(pos):
	var offset = path.curve.get_closest_offset(pos)
	path_follow.progress = offset
	return path_follow.transform.x

func _on_lap_counter_body_entered(_body: Node2D) -> void:
	if GlobalVariables.reached_checkpoints == checkpoints_count and !stop_counting_laps:
		GlobalVariables.laps += 1
		lap_counter_text.text = "LAP: " + str(GlobalVariables.laps) + " / " + str(GlobalVariables.max_laps)
		GlobalVariables.reached_checkpoints = 0
		GlobalVariables.reset_reached.emit()
		
	if !stop_counting_laps: GlobalVariables.add_to_bracket(Player.player_id, GlobalVariables.laps)
		

func _on_car_finished_race():
	GlobalVariables.finished_cars += 1
	for i in GlobalVariables.bracket:
		print(i)
	if GlobalVariables.finished_cars == cars_arr.size():
		for i in GlobalVariables.bracket:
			bracket_text.text += i + "\n"
		var race_end_ui = End_screen.instantiate()
		add_child(race_end_ui)
		get_tree().set_deferred("paused", true)
			
	
	

func _process(delta: float) -> void:
	nitro_progress.value = GlobalVariables.drift_time_percentage
	
