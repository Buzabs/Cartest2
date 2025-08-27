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
@onready var drift_timer: = $DriftTimer

var rotation_direction := 0 #kierunek obrotu
var direction := 0 #kierunek
var nitro := 0 #input

var can_nitro := true #czy moze uzyc nitro
var nitro_comp := false #czy nitro jest naladowane

@export var nitro_speed := 0

func _ready() -> void:
	nitro_comp = false
	GlobalVariables.drift_wait_time = drift_timer.wait_time

func _physics_process(delta: float) -> void: #TYLKO PROCESY FIZYCZNE!!!!!!!!!
	get_input()

	if direction != 0:
		var movement_vector = Vector2.UP.rotated(rotation) * direction #tworzy wektor na podstawie kierunku i obrotu
		velocity = velocity.move_toward(movement_vector * speed, acc * delta)
		if nitro && can_nitro && nitro_comp:
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
	can_nitro = false
	nitro_comp = false
	nitro_cooldown.start()
	velocity = movement_vector * speed * nitro_speed
	move_and_slide() 
	GlobalVariables.drift_time_percentage = 100
	change_state(StateMachine.States.NITRO)
	
func _process(_delta: float) -> void: #wszystko inne oprócz fizyki
	GlobalVariables.drift_time_left = drift_timer.time_left
	
	
	if StateMachine.current_state == StateMachine.States.DRIFTING: #pasek ladowania nitro
		if drift_timer.is_stopped() and !nitro_comp:
			drift_timer.start()
			print("Starting drift timer, is_stopped:", drift_timer.is_stopped())
			print("nitro_comp: ", nitro_comp)


			
		if not drift_timer.is_stopped():
			var percent = ((1 - drift_timer.time_left / drift_timer.wait_time) * 100)
			GlobalVariables.drift_time_percentage = clamp(percent, 0, 100)
		elif nitro_comp: 
			GlobalVariables.drift_time_percentage = 100
	elif StateMachine.current_state == StateMachine.States.NITRO:
		if not nitro_cooldown.is_stopped():
			var percent = (nitro_cooldown.time_left / nitro_cooldown.wait_time) * 100	
			GlobalVariables.drift_time_percentage = clamp(percent, 0, 100)
		else:
			GlobalVariables.drift_time_percentage = 0
	elif StateMachine.current_state in [StateMachine.States.IDLE, StateMachine.States.DRIVING, StateMachine.States.NITRO]: 
		if !nitro_comp:
			drift_timer.stop()
			GlobalVariables.drift_time_percentage = 0
	
	if direction == 1:
		car_velocity = velocity.rotated(0.5 * PI)
	elif direction == -1:
		car_velocity = velocity.rotated(1.5 * PI)
		
	rotation_min = rotation - drift_sensibility
	rotation_max = rotation + drift_sensibility
	
	if StateMachine.current_state != StateMachine.States.NITRO:
		if velocity == Vector2.ZERO: StateMachine.current_state = change_state(StateMachine.States.IDLE)
		else:
			animation.speed_scale = velocity.length() / speed
		
		#Sprawdzanie czy driftuje
		if not(car_velocity.angle() > rotation_min && car_velocity.angle() < rotation_max) and velocity != Vector2.ZERO:
			change_state(StateMachine.States.DRIFTING)	
		elif velocity != Vector2.ZERO: 
			change_state(StateMachine.States.DRIVING)
			drift_timer.stop() 
		elif velocity == Vector2.ZERO:
			change_state(StateMachine.States.IDLE)
			drift_timer.stop() 
			
	if StateMachine.current_state in [StateMachine.States.DRIVING, StateMachine.States.DRIFTING]:
		animation.play("default")
	elif StateMachine.current_state == StateMachine.States.IDLE:
		animation.stop()
		
	print("Current State: ", StateMachine.current_state)

	print("Drift Timer Time Left: ", drift_timer.time_left)

	print("Nitro Cooldown Time Left: ", nitro_cooldown.time_left)

	print("Drift Time Percentage: ", GlobalVariables.drift_time_percentage)
		

	
func _on_timer_timeout() -> void: #nitro cooldown timer
	can_nitro = true
	nitro_comp = false
	if velocity == Vector2.ZERO:
		change_state(StateMachine.States.IDLE)
	else:
		change_state(StateMachine.States.DRIVING)
	
		

func car_collision_id():
	pass


func _on_drift_timer_timeout() -> void:
		nitro_comp = true

	
