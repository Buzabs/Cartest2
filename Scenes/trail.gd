extends Line2D

@export var lenght = 40

var point = Vector2()
var car_velocity = Vector2()

func _ready() -> void:
	car_velocity = owner.velocity
	car_velocity.x -= 2 * car_velocity.x

func _process(delta: float) -> void:
	global_position = Vector2(0, 0)
	global_rotation = 0
	
	
	if abs(owner.rotation - car_velocity.angle()) >= 1.8:
	
		point = get_parent().global_position
		
		add_point(point)
		
		while get_point_count() > lenght:
			remove_point(0)
		
	else: 
		if get_point_count() != 0:
			remove_point(0)
			
			
	print(owner.rotation, "\t", car_velocity.angle())
