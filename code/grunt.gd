extends shootingEnemy


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
		queue_free()
		
func _exit_tree():
	Global.gruntNum -= 1
	if !attacking: # enemy was killed
		Global.score += score
		Global.enemiesKilled += 1
	
func playHitAnimation():
	$HitSound.play()
	$GruntModel.animation = "on_hit"
	await get_tree().create_timer(0.2).timeout
	$GruntModel.animation = "default"
	
func shootBullet():
	Main.entityShoot(Bullet, rotation, position, attackDamage, 1250)
	
