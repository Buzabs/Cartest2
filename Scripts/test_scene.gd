extends Node2D

@onready var path = $Track
@onready var path_follow = $Track/TrackFollow

func get_path_direction(pos):
	var offset = path.curve.get_closest_offset(pos)
	path_follow.progress = offset
	return path_follow.transform.x
