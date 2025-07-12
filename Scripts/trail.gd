extends Line2D

@export var lenght = 40

var point = Vector2()
var car_velocity = Vector2()

var a
var b
@export var drift_sensibility = 0.5

var drifting = false

func _process(delta: float) -> void:
	global_position = Vector2(0, 0)
	global_rotation = 0
	
	if owner.direction == 1:
		car_velocity = owner.velocity.rotated(0.5 * PI)
	elif owner.direction == -1:
		car_velocity = owner.velocity.rotated(1.5 * PI)
	
	a = owner.rotation - drift_sensibility
	b = owner.rotation + drift_sensibility
	
	if not(car_velocity.angle() > a && car_velocity.angle() < b):
		point = get_parent().global_position
		add_point(point)
		drifting = true
		
		while get_point_count() > lenght:
			remove_point(0)

	else: 
		if get_point_count() != 0:
			remove_point(0)
			drifting = false
			
	#print(owner.rotation, "\t", car_velocity.angle(), "\t", owner.direction)
