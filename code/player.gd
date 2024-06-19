extends Area2D

signal shoot(bullet, direction, location)

var Bullet = preload("res://code/player_bullet.tscn")

var Main 

# stuff that can be tweaked
const bounceForce = 1500
var maxSpeed = 600 # upper limit to player's speed
var speed = 350 # player acceleration in pixels per second
var maxHealth = 100
var health = 100
var iframeTime = 0.2
var fireRate = 0.2
var attackDamage = 10

# stuff that makes the program work
var screen_size # Size of the game window.
var velocity = Vector2(0,0)
var recoilVelocity = Vector2(0,0)
var bounceVelocity = Vector2(0,0)
var knockbackVelocity = Vector2(0,0)
var dashVelocity = Vector2(0,0)
var reloaded = true
var alive = true
var invincible = false

var can_regen = true
var regenStartingAmount = 3
var regenAmount = regenStartingAmount
var regenIncrementAmount = 0.8

var id = "player"


# Called when the node enters the scene tree for the first time.
func _ready():
	spawnAnimation()
	$PlayerModel.animation = "default"
	Main = get_parent()
	screen_size = Main.get_arena_size()
	position = screen_size/2
	$PlayerCamera.set_limit(SIDE_LEFT,0 - 300)
	$PlayerCamera.set_limit(SIDE_TOP, 0 - 300)
	$PlayerCamera.set_limit(SIDE_RIGHT, screen_size.x + 300)
	$PlayerCamera.set_limit(SIDE_BOTTOM, screen_size.y + 300)
	Global.Player = self
	health = maxHealth
	velocity += Vector2(randf_range(-500,500), randf_range(-500,500))
	
func spawnAnimation():
	self.scale = Vector2(0.1, 0.1)
	await get_tree().create_timer(0.01, false).timeout
	for i in 9:
		await get_tree().create_timer(0.01, false).timeout
		self.scale += Vector2(0.1, 0.1)

	
func _exit_tree():
	Global.gameOver = true
	Main.setGameOver()
	Main.setDeathCamera(position)
	Global.Player = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	processHealth(delta)
	if alive:
		processMovement(delta)
		processShooting(delta)
		rotation = get_global_mouse_position().angle_to_point(position)
		processWallBounce()
		#processAbility()
	else:
		handleDeath()
	
func processHealth(delta):
	if (health < maxHealth && can_regen):
		health += regenAmount * delta
		regenAmount += regenIncrementAmount * delta

	if (health > maxHealth):
		health = maxHealth
		
func processAbility():
	if Input.is_action_just_pressed("rightClick"):
		var mousePosition = get_global_mouse_position()
		position = mousePosition
		#var angle = get_global_mouse_position().angle_to_point(position)
		#dashVelocity = Vector2(-13000,0).rotated(angle)
		handleInvincibleFrame(0.1)
		
		
func handleDeath():
	alive = false
	health = 0
	invincible = true
	$PlayerModel.animation = "on_hit"
	if !$DeathSound.playing:
		$DeathSound.play()
	await get_tree().create_timer(0.5, false).timeout
	queue_free()
	
func processMovement(delta):
	
	var friction = -velocity * 0.05
	var acceleration = processMovementInput()
	velocity = velocity + acceleration + friction
	
	if velocity.length() > maxSpeed:
		velocity = velocity.normalized() * maxSpeed
	
	velocity += recoilVelocity
	recoilVelocity = recoilVelocity*0.8
	
	velocity += bounceVelocity
	bounceVelocity = bounceVelocity*0.8
	
	velocity += knockbackVelocity
	knockbackVelocity = knockbackVelocity * 0.7
	
	velocity += dashVelocity
	dashVelocity = dashVelocity * 0.8
		
	position += velocity * delta
	
	position = position.clamp(Vector2.ZERO, screen_size)
	
func processMovementInput():
	var acceleration = Vector2(0,0)
	
	if Input.is_action_pressed("right"):
		acceleration.x += 1
	if Input.is_action_pressed("left"):
		acceleration.x -= 1
	if Input.is_action_pressed("up"):
		acceleration.y -= 1
	if Input.is_action_pressed("down"):
		acceleration.y += 1
	
	if acceleration.length() > 0:
		acceleration = acceleration.normalized() * speed
		
	return acceleration

	
func processShooting(delta):
	if Input.is_action_pressed("shoot"):
		if reloaded:
			shootBullet()
			processRecoil(delta)
			reloaded = false
			await get_tree().create_timer(fireRate, false).timeout
			reloaded = true
			
func shootBullet():
	Main.entityShoot(Bullet, rotation, position, attackDamage, 3000)
	$GunSound.play()		
			
func processRecoil(delta):
	recoilVelocity = Vector2(200,00).rotated(rotation)
		
func processWallBounce():
	if (position.x <= 0):
		bounceVelocity.x = bounceForce
	elif (position.x >= screen_size.x):
		bounceVelocity.x = -bounceForce
		
	if (position.y <= 0):
		bounceVelocity.y = bounceForce
	elif (position.y >= screen_size.y):
		bounceVelocity.y = -bounceForce

func _on_object_collision(area):
	match area.id:
		"enemy_bullet":
			handleBullet(area)
		"health_orb":
			handleHealthOrb(area)
		"dasher":
			handleDasher(area)
		"minion":
			handleMinion(area)
			

		
func handleBullet(area):
	if !invincible:
		knockbackVelocity += area.velocity/5.0 
		area.queue_free()
		$HitSound.play()
		health -= area.damage
		can_regen = false
		$HealthRegenTimer.start()
		if (health <= 0):
			handleDeath()
		handleInvincibleFrame(iframeTime)
		
func handleHealthOrb(area):
	area.queue_free()
	health += area.amount
	$OrbCollectSound.play()
	
func handleDasher(area):
	if !invincible:
		knockbackVelocity += area.velocity/5.0 
		$HitSound.play()
		health -= area.getDamage()
		can_regen = false
		$HealthRegenTimer.start()
		if (health <= 0):
			handleDeath()
		handleInvincibleFrame(iframeTime)
		
func handleMinion(area):
	if !invincible:
		knockbackVelocity += area.velocity/5.0 
		$HitSound.play()
		health -= area.getDamage()
		can_regen = false
		$HealthRegenTimer.start()
		if (health <= 0):
			handleDeath()
		handleInvincibleFrame(iframeTime)
		
func handleInvincibleFrame(time):
	invincible = true
	$iFrameTimer.wait_time = time
	$PlayerModel.animation = "on_hit"
	$iFrameTimer.start()


func _on_health_regen_timer_timeout():
	can_regen = true
	regenAmount = regenStartingAmount


func _on_i_frame_timer_timeout():
	invincible = false
	$PlayerModel.animation = "default"
