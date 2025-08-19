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

var can_nitro := true
var nitro_comp := false

@export var nitro_speed := 0

func _ready() -> void:
	
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
	nitro_cooldown.start()
	velocity = movement_vector * speed * nitro_speed
	move_and_slide() 
	can_nitro = false
	nitro_comp = false
	change_state(StateMachine.States.NITRO)
	
func _process(_delta: float) -> void: #wszystko inne oprócz fizyki
	GlobalVariables.drift_time_left = drift_timer.time_left
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
		else: 
			change_state(StateMachine.States.DRIVING)
			drift_timer.stop() 
		
	if StateMachine.current_state in [StateMachine.States.DRIVING, StateMachine.States.DRIFTING]:
		animation.play("default")
	elif StateMachine.current_state == StateMachine.States.IDLE:
		animation.stop()
		
		
	if StateMachine.current_state == StateMachine.States.DRIFTING:
		if not drift_timer.is_stopped():
			GlobalVariables.drift_time_percentage = ((1 - drift_timer.time_left / drift_timer.wait_time) * 100)
			print(GlobalVariables.drift_time_percentage)
		else: 
			drift_timer.start()
	else: 
		drift_timer.stop()
		GlobalVariables.drift_time_percentage = 0
	

	


func _on_timer_timeout() -> void: #nitro cooldown timer
	can_nitro = true
	
	if velocity.length() > 0:
		change_state(StateMachine.States.DRIVING)
	else:
		change_state(StateMachine.States.IDLE)
		


func car_collision_id():
	pass


func _on_drift_timer_timeout() -> void:
		nitro_comp = true
