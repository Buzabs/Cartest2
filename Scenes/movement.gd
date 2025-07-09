extends CharacterBody2D

@export var rotation_speed = 1.5 #predkosc obrotu
@export var speed = 400 #predkosc
@export var acc = 200 #przyspieszenie
@export var decc = 300

@onready var animation = $AnimatedSprite2D

var rotation_direction = 0 #kierunek obrotu
var direction = 0 #kierunek




func _physics_process(delta: float) -> void:
	get_input()
	
	
	
	
	if direction != 0:
		var movement_vector = Vector2.UP.rotated(rotation) * direction #tworzy wektor na podstawie kierunku i obrotu
		velocity = velocity.move_toward(movement_vector * speed, acc * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, decc * delta)
	
	if velocity != Vector2.ZERO: 
		rotation += rotation_direction * (velocity.length() * rotation_speed) / speed  * delta
		animation.speed_scale = velocity.length() / speed
		animation.play("default")
	else:
		animation.stop()
	
	print(velocity.length())
	
	
	move_and_slide()
	
func get_input():
	rotation_direction = Input.get_axis("Left", "Right")
	direction = Input.get_axis("Down", "Up")
	
	
