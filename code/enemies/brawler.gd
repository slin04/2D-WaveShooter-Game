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
	health = 60
	score = 15
	velocity = Vector2(0,0)
	speed = 50
	maxSpeed = 400
	fireRate = 2.0
	attackDamage = 15
	followRange = Vector2(200, 400)
	bounceForce = 200
	spawnVelocity = Vector2(randf_range(-100,100), randf_range(-100,100))
	waitTime = 0.5
	bulletVelocity = 1200
	orbitDirection = 1
	changeDirection = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkShouldDespawn()
	trackPlayer()
	processShooting()
	processPhysics(delta)
	
	
func checkShouldDespawn():
	if Global.despawn:
		await get_tree().create_timer(0.5, false).timeout
		velocity = Vector2(0,0)
		$BrawlerModel.animation = "on_hit"
		await get_tree().create_timer(0.1, false).timeout
		queue_free()

func checkHealth():
	if (health <= 0):
		attacking = false
		velocity = Vector2(0,0)
		$BrawlerModel.animation = "on_hit"
		if !$GruntDeathSound.playing:
			$GruntDeathSound.play()
		await get_tree().create_timer(0.2, false).timeout
		dropHealthOrb()
		dropPowerUp()
		queue_free()
		
func dropHealthOrb():
	var roll = randf_range(0, 1)
	if (roll < 0.15):
		Main.spawnHealthOrb(position, 4)
	elif (roll < 0.4):
		Main.spawnHealthOrb(position, 2)
		
func _exit_tree():
	Global.brawlerNum -= 1
	if !attacking: # enemy was killed
		Global.score += score
		Global.enemiesKilled += 1

	
func playHitAnimation():
	$BrawlerModel.animation = "on_hit"
	$Timer.start();
	
func _on_timer_timeout():
	$BrawlerModel.animation = "default"
	
	
	
func shootBullet():
	Main.entityShoot(Bullet, rotation, position, attackDamage, bulletVelocity)
	Main.entityShoot(Bullet, rotation + PI/12.0, position, attackDamage, bulletVelocity)
	Main.entityShoot(Bullet, rotation - PI/12.0, position, attackDamage, bulletVelocity)


