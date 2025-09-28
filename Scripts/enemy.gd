extends CharacterBody2D

@export var max_speed := 250
@export var steer_force := 0.2
@export var look_ahead := 100
@export var num_rays := 8
@export var id: String 

var ray_directions = []
var interest = []
var danger = [] 

var Level = level.new()

var laps: int = 0

var direction := Vector2.ZERO
var acc := Vector2.ZERO

func _ready() -> void:
	laps = -1
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)

func _physics_process(delta: float) -> void:
	if GlobalVariables.can_start:
		set_interest()
		set_danger()
		choose_direction()
		var desired_velocity = direction.rotated(rotation) * max_speed
		velocity = velocity.lerp(desired_velocity, steer_force)
		rotation = velocity.angle()
		move_and_collide(velocity * delta)
		
func set_interest():
	if owner and owner.has_method("get_path_direction"):
		var path_direction = get_parent().get_path_direction(position)
		for i in num_rays:
			var d = ray_directions[i].rotated(rotation).dot(path_direction)
			interest[i] = max(0, d)
	else:
		set_default_interest()	


func set_default_interest():
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation).dot(transform.x)
		interest[i] = max(0, d)

func set_danger():
	var space_state = get_world_2d().direct_space_state
	for i in num_rays:
		var query = PhysicsRayQueryParameters2D.create(position, position + ray_directions[i].rotated(rotation) * look_ahead)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		danger[i] = 1.0 if result else 0.0
		
func choose_direction():
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	direction = Vector2.ZERO
	for i in num_rays:
		direction += ray_directions[i] * interest[i]
	direction = direction.normalized()


func _on_enemy_finish_line_body_entered(_body: Node2D) -> void:
	laps += 1
	GlobalVariables.add_to_bracket(id, laps)
	print("Enemy laps: ", laps)
	
	
