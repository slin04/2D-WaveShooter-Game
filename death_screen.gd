extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Score.text = "Score: " + str(int(Global.score))
	$Kills.text = "Kills: " + str(Global.enemiesKilled)
	
	var timeElapsed = Time.get_unix_time_from_system() - Global.startTime
	$Time.text = "Time: " + str(Time.get_time_string_from_unix_time(int(timeElapsed)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	$MenuSound.play()
	await get_tree().create_timer(0.2, false).timeout
	get_tree().change_scene_to_file("res://start_screen.tscn")
