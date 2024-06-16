extends Node2D

@export var player_scene: PackedScene
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	spawnPlayer()
	fadeIn()
	
func fadeIn():
	var tween = get_tree().create_tween().set_parallel(true)
	$Background.set_color(Color(0,0,0))
	tween.tween_property($Background, "color", Color(0.1,0.15,0.2), 1).set_trans(Tween.TRANS_LINEAR)

	
func spawnPlayer():
	player = player_scene.instantiate()
	add_child(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _start_game():
	$StartSound.play()
	player.despawnAnimation()
	await get_tree().create_timer(1, false).timeout
	get_tree().change_scene_to_file("res://code/main.tscn")
	

func _on_quit_pressed():
	$QuitSound.play()
	player.despawnAnimation()
	await get_tree().create_timer(1, false).timeout
	get_tree().quit()
	
func entityShoot(Bullet, direction, location, damage, velocity): 
	var spawned_bullet = Bullet.instantiate()
	call_deferred("add_child", spawned_bullet)
	spawned_bullet.rotation = direction
	spawned_bullet.position = location
	spawned_bullet.velocity = Vector2(-velocity, 0).rotated(direction)
	spawned_bullet.acceleration = -spawned_bullet.acceleration.rotated(direction)
	spawned_bullet.damage = damage


func _on_start_hit(area):
	area.queue_free()
	
	var tween = get_tree().create_tween()
	tween.tween_property($StartButton/StartLabel, "modulate", Color(0.8,0.9,1), 1).set_trans(Tween.TRANS_QUART)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property($Background, "color", Color(1,1,1), 1).set_trans(Tween.TRANS_QUART)
	
	_start_game()


func _on_quit_hit(area):
	area.queue_free()
	
	var tween = get_tree().create_tween()
	tween.tween_property($QuitButton/QuitLabel, "modulate", Color(0.8,0.9,1), 1).set_trans(Tween.TRANS_QUART)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property($Background, "color", Color(1,1,1), 1).set_trans(Tween.TRANS_QUART)
	
	_on_quit_pressed()
