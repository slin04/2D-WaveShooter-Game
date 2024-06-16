extends abstractEnemy

class_name shootingEnemy

var Bullet = preload("res://code/enemy_bullet.tscn")

var fireRate
var attackDamage 
var followRange = Vector2(250,500)

var reloaded
var attacking 

var waitTime

var orbitDirection = 1
var changeDirection = true


# Called when the node enters the scene tree for the first time.
func _ready():
	playerPosition = Vector2(0,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkShouldDespawn()
	trackPlayer()
	processShooting()
	processPhysics(delta)

func processShooting():
	if (attacking && reloaded && Global.Player != null):
		shootBullet()
		$GunSound.play()
		reloaded = false
		await get_tree().create_timer(fireRate, false).timeout
		reloaded = true
		

func shootBullet():
	Main.entityShoot(Bullet, rotation, position, attackDamage)
	
func processPhysics(delta):
	if (Global.Player != null):
		followPlayer((delta))
		
	processWallBounce()
	processDirection()
	
	if (velocity.length() >= maxSpeed):
		velocity = velocity.normalized()*maxSpeed
	
	velocity += knockback
	knockback = knockback*0.75
	
	velocity += bounceVelocity
	bounceVelocity = bounceVelocity*0.9
	
	velocity += spawnVelocity
	spawnVelocity = spawnVelocity*0.95
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
		
func processDirection():
	if changeDirection:
		orbitDirection = -orbitDirection
		changeDirection = false
		await get_tree().create_timer(randf_range(1.5,3.5), false).timeout
		changeDirection = true

	

func followPlayer(delta):
	var distance = position.distance_to(playerPosition)
	var acceleration = Vector2(0,0)
	if (distance >= followRange.y):
		acceleration = Vector2(-speed,0).rotated(rotation)
	elif (distance <= followRange.x):
		acceleration = -Vector2(-speed,0).rotated(rotation)
	else:
		velocity = velocity*0.9
		acceleration = Vector2(0,speed/2.0).rotated(rotation) * orbitDirection
		
	velocity += acceleration
	
