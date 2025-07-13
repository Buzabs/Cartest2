extends Node2D


var car_velocity = Vector2()





func _process(delta: float) -> void:
	self.direction = car_velocity
	
	self.initial_velocity_min = owner.velocity.length() * 0.5
	self.initial_velocity_max = owner.velocity.length() * 0.5

	
	if owner.direction != 0:
		self.emitting = true
		self.spread = 15
		car_velocity = owner.velocity * transform.inverse()
	else:
		self.emitting = false
	
	if self.direction == Vector2.ZERO:
		self.spread = 180

	
