extends CharacterBody2D

@export var rotation_speed = 1.5 #predkosc obrotu
@export var speed = 400 #predkosc
@export var acc = 200 #przyspieszenie
@export var decc = 300 #zwalnianie

@onready var animation = $AnimatedSprite2D
@onready var trail = $AnimatedSprite2D/TrialPos/Trail

var rotation_direction = 0 #kierunek obrotu
var direction = 0 #kierunek

var state = StateMachine.States.IDLE #bierzący stan

func _physics_process(delta: float) -> void: #TYLKO PROCESY FIZYCZNE!!!!!!!!!
	get_input()

	if direction != 0:
		var movement_vector = Vector2.UP.rotated(rotation) * direction #tworzy wektor na podstawie kierunku i obrotu
		velocity = velocity.move_toward(movement_vector * speed, acc * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, decc * delta)
	
	if velocity != Vector2.ZERO: 
		rotation += rotation_direction * (velocity.length() * rotation_speed) / speed  * delta #stopniowe zwiększanie prędkości obrotu		
	
	move_and_slide()
	
func get_input():
	rotation_direction = Input.get_axis("Left", "Right")
	direction = Input.get_axis("Down", "Up")
	
func change_state(new_state: int):
	#var previous_state := state | To jeśli będziemy chcieli coś robić na zmianie stanu
	state = new_state
		
	
func _process(delta: float) -> void: #wszystko inne oprócz fizyki
	
	if velocity == Vector2.ZERO: state = change_state(StateMachine.States.IDLE)
	else:
		animation.speed_scale = velocity.length() / speed
		if trail.drifting == true: change_state(StateMachine.States.DRIFTING)
		else: change_state(StateMachine.States.DRIVING)
		
	if state in [StateMachine.States.DRIVING, StateMachine.States.DRIFTING]:
		animation.play("default")
	elif state == StateMachine.States.IDLE:
		animation.stop()
		
	print(state)
