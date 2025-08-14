extends Node

signal reset_reached
signal race_finished

var reached_checkpoints: int = 0
var laps: int = 0
var max_laps: int = 3

var finished_cars = 0

var bracket = []
