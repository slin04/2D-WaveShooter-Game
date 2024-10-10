extends Node

var spawnRate = 5
var screen_size

@export var grunt_scene: PackedScene
@export var sniper_scene: PackedScene
@export var brawler_scene: PackedScene
@export var dasher_scene: PackedScene
@export var minion_scene: PackedScene


@export var player_scene: PackedScene
@export var healthbar_scene: PackedScene

@export var orb_scene: PackedScene
@export var powerup_scene: PackedScene

var enemyTypes = ["grunt", "sniper", "brawler", "dasher"]

# Called when the node enters the scene tree for the first time.
func _ready():
	game_start()
	$SpawnTimer.wait_time = spawnRate
	Global.startTime = Time.get_unix_time_from_system()
	
func get_arena_size():
	return $Arena.get_size()
	
func fadeIn():
	var tween = get_tree().create_tween().set_parallel(true)
	$Arena.set_color(Color(1,1,1))
	tween.tween_property($Arena, "color", Color(0.1,0.15,0.2), 2).set_trans(Tween.TRANS_LINEAR)
	
	
func game_start():
	fadeIn()
	spawnPlayer()
	Global.onGameStart()
	#waveOne()
	$SpawnTimer.start()
	$Music.play()
	
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
		
	Global.Player.fireRate *= 1/1.3
		
	waveTwo()
	
func waveTwo():
	await get_tree().create_timer(1, false).timeout
	
	spawnEnemy(4, "dasher")
	
	while(true):
		if (Global.Player == null):
			return null
		if (Global.enemyNum() == 0):
			break
		await get_tree().create_timer(0.2, false).timeout
		
	spawnEnemy(3, "grunt")	
	spawnEnemy(2, "brawler")	
	spawnEnemy(1, "dasher")
	
	while(true):
		if (Global.Player == null):
			return null
		if (Global.enemyNum() == 0):
			break
		await get_tree().create_timer(0.2, false).timeout
	
	await get_tree().create_timer(2, false).timeout
	_on_spawn_timer_timeout()
	
	Global.Player.fireRate *= 1/1.2
	
	Global.Player.speed *= 1.2
	Global.Player.maxSpeed *= 1.2
	
	# after pre-made waves are completed
	$SpawnTimer.start()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateUI(delta)
	#print("Enemy Count: " + str(Global.enemyNum()))
	#checkPause()
	
func checkPause():
	if Input.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
	
		
func setGameOver():
	Global.onGameEnd()
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($Music, "pitch_scale", 0.5, 3).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Music, "volume_db", -40, 3).set_trans(Tween.TRANS_QUAD)
	await get_tree().create_timer(3, false).timeout
	get_tree().change_scene_to_file("res://code/screens/death_screen.tscn")
	
func setDeathCamera(player_position):
	$DeathCamera.position = player_position
	$DeathCamera.set_enabled(true)
		
	
func updateUI(delta):
	if (Global.Player != null):
		Global.score += delta 
	updateScore()
		
	
func updateScore():
	if (Global.Player != null):
		$CanvasLayer/HUD/XPLabel.text = "XP: " + str(int(Global.score))
		

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
	$SpawnTimer.set_wait_time($SpawnTimer.get_wait_time() * 0.98)
	if (Global.Player != null):
		Global.Player.fireRate *= 1/1.02
		Global.Player.speed *= 1.01
		Global.Player.maxSpeed *= 1.01

		
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
	var spawnLocation = Vector2(randi() % int(get_arena_size().x + 1),randi() % int(get_arena_size().y + 1))
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
			"dasher":
				enemy = dasher_scene.instantiate()
				Global.dasherNum += 1
		enemy.position = spawnLocation + Vector2(randi() % 100, randi() % 100)
		enemy.position.clamp(Vector2.ZERO, get_arena_size())
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
	
func spawnHealthOrb(position, num):
	for i in num:
		var orb
		orb = orb_scene.instantiate()
		orb.position = position
		add_child(orb)
		
func spawnPowerUp(position):
	#var powerup
	#powerup = powerup_scene.instantiate()
	#powerup.position = position
	#add_child(powerup)
	pass
	
func _on_music_finished():
	$Music.play()


