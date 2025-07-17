extends CharacterBody2D

@export var max_speed := 400
@export var steer_force := 0.1
@export var look_ahead := 100
@export var num_rays := 8

var ray_directions = []
var interest = []
var danger = [] 

@onready var path = %Track
@onready var path_follow = %TrackFollow

var direction := Vector2.ZERO
#var enemy_velocity := Vector2.ZERO
var acc := Vector2.ZERO

func _ready() -> void:
	 
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)

func _physics_process(delta: float) -> void:
	set_interest()
	set_danger()
	choose_direction()
	var desired_velocity = direction.rotated(rotation) * max_speed
	velocity = velocity.lerp(desired_velocity, steer_force)
	rotation = velocity.angle()
	move_and_collide(velocity * delta)

func set_interest():
	var path_direction = get_path_direction(position)
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation).dot(path_direction)
		interest[i] = max(0, d)


func set_default_interest():
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation).dot(transform.x)
		interest[i] = max(0, d)

func set_danger():
	var space_state = get_world_2d().direct_space_state
	for i in range(num_rays):
		var query = PhysicsRayQueryParameters2D.create(position, position + ray_directions[i].rotated(rotation) * look_ahead)
		var result = space_state.intersect_ray(query)
		danger[i] = 1.0 if result else 0.0
		
func choose_direction():
	for i in range(num_rays):
		if danger[i] > 0.0:
			interest[i] = 0.0
	direction = Vector2.ZERO
	for i in range(num_rays):
		direction += ray_directions[i] * interest[i]
	direction = direction.normalized()

func get_path_direction(pos):
	var offset = path.curve.get_closest_offset(pos)
	path_follow.v_offset = offset
	return path_follow.transform.x
	
