extends Node

var spawnRate = 5

@export var grunt_scene: PackedScene
@export var sniper_scene: PackedScene
@export var brawler_scene: PackedScene

@export var player_scene: PackedScene
@export var healthbar_scene: PackedScene

var enemyTypes = ["grunt", "sniper", "brawler"]

# Called when the node enters the scene tree for the first time.
func _ready():
	game_start()
	$SpawnTimer.wait_time = spawnRate
	Global.startTime = Time.get_unix_time_from_system()
	
func game_start():
	spawnPlayer()
	Global.onGameStart()
	waveOne()
	#$Music.play()
	
func spawnPlayer():
	var player = player_scene.instantiate()
	add_child(player)
	setHealthBar()
	
func setHealthBar():
	var healthbar = healthbar_scene.instantiate()
	add_child(healthbar)
	
	
func waveOne():
	await get_tree().create_timer(1, false).timeout
	spawnEnemy(4, "grunt")	
	
	while(true):
		if (Global.Player == null):
			return null
		if (Global.enemyNum() == 0):
			break
		await get_tree().create_timer(0.2, false).timeout
		
	spawnEnemy(3, "sniper")
	
	while(true):
		if (Global.Player == null):
			return null
		if (Global.enemyNum() == 0):
			break
		await get_tree().create_timer(0.2, false).timeout
		
	spawnEnemy(2, "brawler")
	
	while(true):
		if (Global.Player == null):
			return null
		if (Global.enemyNum() == 0):
			break
		await get_tree().create_timer(0.2, false).timeout
		
	waveTwo()
	
func waveTwo():
	await get_tree().create_timer(1, false).timeout
	
	spawnEnemy(4, "grunt")	
	spawnEnemy(1, "sniper")	
	
	while(true):
		if (Global.Player == null):
			return null
		if (Global.enemyNum() == 0):
			break
		await get_tree().create_timer(0.2, false).timeout
		
	spawnEnemy(3, "grunt")	
	spawnEnemy(2, "brawler")	
	
	while(true):
		if (Global.Player == null):
			return null
		if (Global.enemyNum() == 0):
			break
		await get_tree().create_timer(0.2, false).timeout
	
	await get_tree().create_timer(2, false).timeout
	_on_spawn_timer_timeout()
	
	# after pre-made waves are completed
	$SpawnTimer.start()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateUI(delta)
	#print("Enemy Count: " + str(Global.enemyNum()))
	#checkPause()
	
# fix this
func checkPause():
	if Input.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
	
		
func setGameOver():
	Global.onGameEnd()
	await get_tree().create_timer(1, false).timeout
	get_tree().change_scene_to_file("res://death_screen.tscn")
		
	
func updateUI(delta):
	if (Global.Player != null):
		Global.score += delta 
	updateHP()
	updateScore()
		
func updateHP():
	if (Global.Player != null):
		$HUD/HPValue.text = str(int(Global.Player.health))
	else:
		$HUD/HPValue.text = "0"
	
func updateScore():
	if (Global.Player != null):
		$HUD/XPLabel.text = "XP: " + str(int(Global.score))


func _on_player_shoot(Bullet, direction, location):
	var spawned_bullet = Bullet.instantiate()
	add_child(spawned_bullet)
	spawned_bullet.rotation = direction
	spawned_bullet.position = location
	spawned_bullet.velocity = spawned_bullet.velocity.rotated(direction)
	spawned_bullet.acceleration = -spawned_bullet.acceleration.rotated(direction)

func _on_spawn_timer_timeout():
	if (!Global.gameOver && Global.enemyNum() < 20 && Global.Player != null):
		spawnEnemy(1, enemyTypes.pick_random())
		spawnEnemy(1, enemyTypes.pick_random())
		
		
#func spawnGrunt(num):
	#for i in num:
		#var grunt = grunt_scene.instantiate()
		#var grunt_spawn_location = $EnemySpawner/EnemySpawnLocation
		#grunt_spawn_location.progress_ratio = randf()
		#grunt.position = grunt_spawn_location.position
		#add_child(grunt)
		#Global.gruntNum += 1
		#await get_tree().create_timer(0.25, false).timeout
		
		
func spawnEnemy(num, type):
	for i in num:
		var enemy
		match type:
			"grunt":
				enemy = grunt_scene.instantiate()
				Global.gruntNum += 1
			"sniper":
				enemy = sniper_scene.instantiate()
				Global.sniperNum += 1
			"brawler":
				enemy = brawler_scene.instantiate()
				Global.brawlerNum += 1
		var spawnLocation = $EnemySpawner/EnemySpawnLocation
		spawnLocation.progress_ratio = randf()
		enemy.position = spawnLocation.position
		add_child(enemy)
		await get_tree().create_timer(0.5 + randf(), false).timeout
	
	
	
func entityShoot(Bullet, direction, location, damage, velocity): 
	var spawned_bullet = Bullet.instantiate()
	call_deferred("add_child", spawned_bullet)
	spawned_bullet.rotation = direction
	spawned_bullet.position = location
	spawned_bullet.velocity = Vector2(-velocity, 0).rotated(direction)
	spawned_bullet.acceleration = -spawned_bullet.acceleration.rotated(direction)
	spawned_bullet.damage = damage
	

	
