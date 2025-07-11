extends Node2D


var car_velocity = Vector2()

	



func _process(delta: float) -> void:
	
	$CPUParticles2D.direction = car_velocity
	
	if owner.direction != 0:
		$CPUParticles2D.emitting = true
		$CPUParticles2D.spread = 15
		car_velocity = owner.velocity.normalized() * transform.inverse()
	else:
		$CPUParticles2D.emitting = false
	
	if $CPUParticles2D.direction == Vector2.ZERO:
		$CPUParticles2D.spread = 180

	
