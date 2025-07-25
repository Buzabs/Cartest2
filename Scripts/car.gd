extends CharacterBody2D

@export var rotation_speed := 1.5 #predkosc obrotu
@export var speed := 400 #predkosc
@export var acc := 200 #przyspieszenie
@export var decc := 300 #zwalnianie

@export var drift_sensibility := 0.5
var rotation_max: float
var rotation_min: float
var car_velocity = Vector2()

@onready var animation = $AnimatedSprite2D
@onready var nitro_cooldown = $NitroCooldown

var rotation_direction := 0 #kierunek obrotu
var direction := 0 #kierunek
var nitro := 0 #input

var can_nitro := true

@export var nitro_speed := 0

func _physics_process(delta: float) -> void: #TYLKO PROCESY FIZYCZNE!!!!!!!!!
	get_input()

	if direction != 0:
		var movement_vector = Vector2.UP.rotated(rotation) * direction #tworzy wektor na podstawie kierunku i obrotu
		velocity = velocity.move_toward(movement_vector * speed, acc * delta)
		if nitro && can_nitro == true:
			nitro_boost(movement_vector * delta)
			
	else:
		velocity = velocity.move_toward(Vector2.ZERO, decc * delta)
	
	if velocity != Vector2.ZERO: 
		rotation += rotation_direction * (velocity.length() * rotation_speed) / speed  * delta #stopniowe zwiększanie prędkości obrotu		
	
	move_and_slide()
	
func get_input():
	rotation_direction = Input.get_axis("Left", "Right")
	direction = Input.get_axis("Down", "Up")
	nitro = Input.is_action_just_pressed("Nitro")
	
func change_state(new_state: int):
	#var previous_state := state | To jeśli będziemy chcieli coś robić na zmianie stanu
	StateMachine.current_state = new_state
		
func nitro_boost(movement_vector):
	nitro_cooldown.start()
	velocity = movement_vector * speed * nitro_speed
	move_and_slide() 
	can_nitro = false
	change_state(StateMachine.States.NITRO)
	
func _process(delta: float) -> void: #wszystko inne oprócz fizyki
	
	if StateMachine.current_state == StateMachine.States.NITRO:
		return
	
	if direction == 1:
		car_velocity = velocity.rotated(0.5 * PI)
	elif direction == -1:
		car_velocity = velocity.rotated(1.5 * PI)
		
	rotation_min = rotation - drift_sensibility
	rotation_max = rotation + drift_sensibility
	
	if velocity == Vector2.ZERO: StateMachine.current_state = change_state(StateMachine.States.IDLE)
	else:
		animation.speed_scale = velocity.length() / speed
		
		#Sprawdzanie czy driftuje
		if not(car_velocity.angle() > rotation_min && car_velocity.angle() < rotation_max):
			change_state(StateMachine.States.DRIFTING)	
		else: change_state(StateMachine.States.DRIVING)
		
	if StateMachine.current_state in [StateMachine.States.DRIVING, StateMachine.States.DRIFTING]:
		animation.play("default")
	elif StateMachine.current_state == StateMachine.States.IDLE:
		animation.stop()
		
	
	
	
	print(StateMachine.current_state)


func _on_timer_timeout() -> void:
	can_nitro = true
	
	if velocity.length() > 0:
		change_state(StateMachine.States.DRIVING)
	else:
		change_state(StateMachine.States.IDLE)
