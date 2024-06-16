extends shootingEnemy

var hit = false

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
	score = 10
	velocity = Vector2(0,0)
	speed = 100
	maxSpeed = 400
	fireRate = 1.2
	attackDamage = 10
	bounceForce = 500
	spawnVelocity = Vector2(randf_range(-500,500), randf_range(-500,500))
	waitTime = 1.0
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
		$GruntModel.animation = "on_hit"
		await get_tree().create_timer(0.1, false).timeout
		queue_free()
	
func checkHealth():
	if (health <= 0):
		attacking = false
		$GruntModel.animation = "on_hit"
		if !$GruntDeathSound.playing:
			$GruntDeathSound.play()
		await get_tree().create_timer(0.2, false).timeout
		dropHealthOrb()
		queue_free()
		
func dropHealthOrb():
	var roll = randf_range(0, 1)
	if (roll < 0.1):
		Main.spawnHealthOrb(position, 3)
	elif (roll < 0.3):
		Main.spawnHealthOrb(position, 1)
	
		
func _exit_tree():
	Global.gruntNum -= 1
	if !attacking: # enemy was killed
		Global.score += score
		Global.enemiesKilled += 1
	
	
func playHitAnimation():
	$GruntModel.animation = "on_hit"
	$Timer.start();
	
func _on_timer_timeout():
	$GruntModel.animation = "default"
	
func shootBullet():
	Main.entityShoot(Bullet, rotation, position, attackDamage, 1250)

