extends Node

signal reset_reached
signal race_finished


var reached_checkpoints: int = 0
var laps: int = 0
var max_laps: int = 3

var finished_cars: int = 0

var bracket = []

var drift_time_left: float
var drift_wait_time: float

var drift_time_percentage: int = 0

var can_start: bool

func add_to_bracket(id: String, completed_laps: int):
	if completed_laps == max_laps and id not in bracket:
		bracket.append(id)
		race_finished.emit()
