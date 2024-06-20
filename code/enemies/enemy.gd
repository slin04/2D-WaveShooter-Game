extends Area2D

class_name abstractEnemy

var health # enemy health
var score  # score that enemy yields
var bounceForce

var velocity 
var speed
var maxSpeed
var bounceVelocity = Vector2(0,0)
var knockback = Vector2(0,0)
var spawnVelocity

var playerPosition

var screen_size
var Main

# Called when the node enters the scene tree for the first time.
func _ready():
	setWorld()
	playerPosition = Vector2(0,0)
	velocity = Vector2(0,0)
	
func setWorld():
	Main = get_parent()
	screen_size = Main.get_arena_size()
	
func spawnAnimation():
	await get_tree().create_timer(0.01, false).timeout
	self.scale = Vector2(0.1, 0.1)
	for i in 9:
		await get_tree().create_timer(0.01, false).timeout
		self.scale += Vector2(0.1, 0.1)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkShouldDespawn()
	trackPlayer()
	processPhysics(delta)
	
	
func processPhysics(delta):
	processWallBounce()
	
	velocity += knockback
	knockback = knockback*0.5
	
	velocity += bounceVelocity
	bounceVelocity = bounceVelocity*0.9
	
	velocity += spawnVelocity
	spawnVelocity = spawnVelocity*0.95
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	
func trackPlayer():
	if (Global.Player != null):
		playerPosition = Global.Player.position
		rotation = playerPosition.angle_to_point(position)
		
func processWallBounce():
	if (position.x <= 0):
		bounceVelocity.x = bounceForce
	elif (position.x >= screen_size.x):
		bounceVelocity.x = -bounceForce
		
	if (position.y <= 0):
		bounceVelocity.y = bounceForce
	elif (position.y >= screen_size.y):
		bounceVelocity.y = -bounceForce
		
func _on_area_entered(area):
	knockback += area.velocity * 0.25
	area.queue_free()
	health -= area.damage
	playHitAnimation()
	$HitSound.play()
	checkHealth()
	
#abstract
func playHitAnimation():
	pass

# abstract
func checkShouldDespawn():
	pass
	
# abstract
func checkHealth(): 
	pass
	
func dropHealthOrb():
	pass
	
func dropPowerUp():
	var roll = randf_range(0, 1)
	if (roll < 0.05):
		Main.spawnPowerUp(position)
