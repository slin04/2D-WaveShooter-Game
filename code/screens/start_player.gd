extends Area2D

signal shoot(bullet, direction, location)

var Bullet = preload("res://code/projectiles/player_bullet.tscn")

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
var regenStartingAmount = 5
var regenAmount = regenStartingAmount
var regenIncrementAmount = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	spawnAnimation()
	screen_size = get_viewport_rect().size
	position = Vector2(get_viewport_rect().size.x/4, 3*get_viewport_rect().size.y/2)
	$PlayerModel.animation = "default"
	Main = get_parent()
	health = maxHealth
	velocity += Vector2(randf_range(-500,500), randf_range(-500,500))
	
func spawnAnimation():
	$PlayerModel.set_scale(Vector2(0,0))
	var tween = get_tree().create_tween()
	tween.tween_property($PlayerModel, "scale", Vector2(0.6,0.6), 1).set_trans(Tween.TRANS_QUART)
		
func despawnAnimation():
	var tween = get_tree().create_tween()
	tween.tween_property($PlayerModel, "scale", Vector2(0,0), 1).set_trans(Tween.TRANS_QUART)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if alive:
		processMovement(delta)
		processShooting(delta)
		rotation = get_global_mouse_position().angle_to_point(position)
		processWallBounce()

	
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
	dashVelocity = dashVelocity * 0.85
		
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
		
func handleInvincibleFrame():
	invincible = true
	$PlayerModel.animation = "on_hit"
	$PlayerModel.play()
	await get_tree().create_timer(iframeTime, false).timeout
	$PlayerModel.animation = "default"
	$PlayerModel.stop()
	invincible = false	


func _on_health_regen_timer_timeout():
	can_regen = true
	regenAmount = regenStartingAmount
