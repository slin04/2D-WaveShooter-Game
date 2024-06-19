extends abstractEnemy

var id = "minion"
var damage = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	setWorld()
	setProperties()
	playerPosition = Vector2(0,0)
	velocity = Vector2(0,0)

func setWorld():
	Main = get_parent()
	screen_size = Main.get_arena_size()
	
func setProperties():
	health = 20
	score = 5
	velocity = Vector2(0,0)
	speed = 300
	maxSpeed = 800
	bounceForce = 500
	spawnVelocity = Vector2(randf_range(-500,500), randf_range(-500,500))
	#waitTime = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkShouldDespawn()
	trackPlayer()
	processPhysics(delta)
	
func processPhysics(delta):
	if (Global.Player != null):
		followPlayer()
		
	processWallBounce()
	
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
	
func followPlayer():
	var acceleration = Vector2(0,0)
	acceleration = Vector2(-speed,0).rotated(rotation)
	velocity += acceleration

func playHitAnimation():
	$MinionModel.animation = "on_hit"
	$Timer.start();
	
func _on_timer_timeout():
	$MinionModel.animation = "default"

func checkShouldDespawn():
	if Global.despawn:
		await get_tree().create_timer(0.5, false).timeout
		velocity = Vector2(0,0)
		$MinionModel.animation = "on_hit"
		await get_tree().create_timer(0.1, false).timeout
		queue_free()
	
func checkHealth(): 
	if (health <= 0):
		#attacking = false
		velocity = Vector2(0,0)
		$MinionModel.animation = "on_hit"
		if !$GruntDeathSound.playing:
			$GruntDeathSound.play()
		await get_tree().create_timer(0.2, false).timeout
		dropHealthOrb()
		queue_free()
	
func dropHealthOrb():
	var roll = randf_range(0, 1)
	if (roll < 0.2):
		Main.spawnHealthOrb(position, 2)
	elif (roll < 0.4):
		Main.spawnHealthOrb(position, 1)
		
func _on_area_entered(area):
	match area.id:
		"player_bullet":
			handleBullet(area)
		"player":
			queue_free()
			
func handleBullet(area):
	knockback += area.velocity * 0.3
	area.queue_free()
	health -= area.damage
	playHitAnimation()
	checkHealth()
		
func getDamage():
	return damage
