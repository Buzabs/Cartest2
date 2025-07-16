extends Line2D

@export var lenght := 40

var point := Vector2()

@onready var default_gradient := gradient
var nitro_gradient := Gradient.new()

var is_drawing := false

func _ready() -> void:
	nitro_gradient.colors = [Color.TRANSPARENT, Color.AQUA]
	nitro_gradient.offsets = [0.0, 1.0]

func _process(delta: float) -> void:
	global_position = Vector2(0, 0)
	global_rotation = 0
	
	if StateMachine.current_state == StateMachine.States.NITRO:
			gradient = nitro_gradient
			draw_trial()
	elif StateMachine.current_state == StateMachine.States.DRIFTING:
		draw_trial()
	else: 
		gradient = default_gradient
		is_drawing = false
	
	if !is_drawing: 
		if get_point_count() != 0:
			remove_point(0)
	#print(owner.rotation, "\t", car_velocity.angle(), "\t", owner.direction)

func draw_trial():
	is_drawing = true
	point = get_parent().global_position
	add_point(point)
	while get_point_count() > lenght:
			remove_point(0)
