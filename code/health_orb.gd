extends Node2D

var id = "health_orb"
var amount = 6

var velocity = Vector2(0,0)
var bounceVelocity = Vector2(0,0)
var bounceForce = 300

var followRange = 300
var speed = 75

var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = 5
	$Timer.start()
	screen_size = get_viewport_rect().size
	velocity += Vector2(randf_range(-1,1), randf_range(-1,1)) * 1000
	$OrbModel.animation = "fresh"
	$SpawnSound.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	processPhysics(delta)
	
func processPhysics(delta):
	
	processWallBounce()
	followPlayer()
	velocity += bounceVelocity
	bounceVelocity = bounceVelocity*0.8
	
	position += velocity * delta
	velocity = velocity * 0.95
	
	position = position.clamp(Vector2.ZERO, screen_size)
	
		
func followPlayer():
	if (Global.Player != null):
		var playerPosition = Global.Player.position
		var distance = position.distance_to(playerPosition)
		if (distance <= followRange):
			var acceleration = Vector2(0,0)
			rotation = playerPosition.angle_to_point(position)
			acceleration = -Vector2(speed,0).rotated(rotation)
			velocity += acceleration
	
func processWallBounce():
	if (position.x <= 0):
		bounceVelocity.x = bounceForce
	elif (position.x >= screen_size.x):
		bounceVelocity.x = -bounceForce
		
	if (position.y <= 0):
		bounceVelocity.y = bounceForce
	elif (position.y >= screen_size.y):
		bounceVelocity.y = -bounceForce
		

func _on_timer_timeout():
	$OrbModel.animation = "expired"
	$DespawnSound.play()
	await get_tree().create_timer(0.25, false).timeout
	queue_free()
