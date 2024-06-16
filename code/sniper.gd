extends shootingEnemy

var bulletVelocity

# Called when the node enters the scene tree for the first time.
func _ready():
	spawnAnimation()
	setWorld()
	setProperties()
	attacking = false
	await get_tree().create_timer(waitTime, false).timeout
	attacking = true
	reloaded = true
	
func setProperties():
	health = 40
	score = 20
	velocity = Vector2(0,0)
	speed = 50
	maxSpeed = 600
	fireRate = 1.4
	attackDamage = 20
	followRange = Vector2(800, 1000)
	bounceForce = 300
	spawnVelocity = Vector2(randf_range(-500,500), randf_range(-500,500))
	waitTime = 1.0
	bulletVelocity = 1700 
	orbitDirection = 1
	changeDirection = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkShouldDespawn()
	trackPlayer()
	processShooting()
	processPhysics(delta)
	
	
func trackPlayer():
	if (Global.Player != null):
		playerPosition = Global.Player.position
		var aimingPosition = playerPosition + Global.Player.velocity*(playerPosition.distance_to(position)/bulletVelocity)
		rotation = aimingPosition.angle_to_point(position)
		

	
func checkShouldDespawn():
	if Global.despawn:
		await get_tree().create_timer(0.5, false).timeout
		velocity = Vector2(0,0)
		$SniperModel.animation = "on_hit"
		await get_tree().create_timer(0.1, false).timeout
		queue_free()

func checkHealth():
	if (health <= 0):
		attacking = false
		velocity = Vector2(0,0)
		$SniperModel.animation = "on_hit"
		if !$GruntDeathSound.playing:
			$GruntDeathSound.play()
		await get_tree().create_timer(0.2, false).timeout
		dropHealthOrb()
		queue_free()
		
func dropHealthOrb():
	var roll = randf_range(0, 1)
	if (roll < 0.2):
		Main.spawnHealthOrb(position, 3)
	elif (roll < 0.6):
		Main.spawnHealthOrb(position, 2)
		
func _exit_tree():
	Global.sniperNum -= 1
	if !attacking: # enemy was killed
		Global.score += score
		Global.enemiesKilled += 1
	
func playHitAnimation():
	$SniperModel.animation = "on_hit"
	$Timer.start();
	
func _on_timer_timeout():
	$SniperModel.animation = "default"
	
func shootBullet():
	Main.entityShoot(Bullet, rotation, position, attackDamage, bulletVelocity)


