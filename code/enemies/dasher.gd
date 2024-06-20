extends shootingEnemy

var hit = false

var charging = false
var dashing = false
var dashVelocity = Vector2(0,0)

var id = "dasher"
var damage = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	$DasherModel.animation = "default"
	spawnAnimation()
	setWorld()
	setProperties()
	attacking = false
	await get_tree().create_timer(waitTime, false).timeout
	attacking = true
	reloaded = true
	$DashTimer.start()

	
func setProperties():
	health = 30
	score = 15
	velocity = Vector2(0,0)
	speed = 120
	maxSpeed = 800
	fireRate = 1.2
	attackDamage = 10
	bounceForce = 500
	spawnVelocity = Vector2(randf_range(-500,500), randf_range(-500,500))
	waitTime = 1.0
	orbitDirection = 1
	changeDirection = true
	followRange = Vector2(400,900)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkShouldDespawn()
	trackPlayer()
	processPhysics(delta)
	
func checkShouldDespawn():
	if Global.despawn:
		await get_tree().create_timer(0.5, false).timeout
		velocity = Vector2(0,0)
		$DasherModel.animation = "on_hit"
		await get_tree().create_timer(0.1, false).timeout
		queue_free()
	
func checkHealth():
	if (health <= 0):
		attacking = false
		$DasherModel.animation = "on_hit"
		if !$GruntDeathSound.playing:
			$GruntDeathSound.play()
		await get_tree().create_timer(0.2, false).timeout
		dropHealthOrb()
		dropPowerUp()
		queue_free()
		
func dropHealthOrb():
	var roll = randf_range(0, 1)
	if (roll < 0.1):
		Main.spawnHealthOrb(position, 3)
	elif (roll < 0.3):
		Main.spawnHealthOrb(position, 1)
	
		
func _exit_tree():
	Global.dasherNum -= 1
	if !attacking: # enemy was killed
		Global.score += score
		Global.enemiesKilled += 1
		
func processWallBounce():
	if (position.x <= 0):
		bounceVelocity.x = bounceForce
		dashVelocity = Vector2(0,0)
	elif (position.x >= screen_size.x):
		bounceVelocity.x = -bounceForce
		dashVelocity = Vector2(0,0)
		
	if (position.y <= 0):
		bounceVelocity.y = bounceForce
		dashVelocity = Vector2(0,0)
	elif (position.y >= screen_size.y):
		bounceVelocity.y = -bounceForce
		dashVelocity = Vector2(0,0)
		
func processPhysics(delta):
	if (Global.Player != null && !charging):
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
	
	velocity += dashVelocity
	dashVelocity = dashVelocity*0.95
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	

	
func playHitAnimation():
	$DasherModel.animation = "on_hit"
	$Timer.start();
	
func _on_timer_timeout():
	$DasherModel.animation = "default"
	
func _on_dash_timer_timeout():
	charge()
	
func charge():
	charging = true
	velocity = velocity/4
	$DasherModel.animation = "charging"
	$ChargeSound.play()
	await get_tree().create_timer(0.3, false).timeout
	charging = false
	dash()
	
func dash():
	dashing = true
	$DasherModel.animation = "dashing"
	
	dashVelocity = -Vector2(6000,0).rotated(rotation)
	$DashSound.play()
	await get_tree().create_timer(0.5, false).timeout
	
	dashing = false
	$DasherModel.animation = "default"
	
	$DashTimer.start()
	
func _on_area_entered(area):
	match area.id:
		"player_bullet":
			handleBullet(area)
		"player":
			pass
	
func handleBullet(area):
	knockback += area.velocity * 0.25
	area.queue_free()
	health -= area.damage
	playHitAnimation()
	checkHealth()
	
func getDamage():
	if dashing:
		return damage
	else:
		return damage/4
	
	
func trackPlayer():
	if (Global.Player != null && !charging):
		playerPosition = Global.Player.position
	if (!dashing):
		rotation = playerPosition.angle_to_point(position)
