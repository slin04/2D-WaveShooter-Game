extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _start_game():
	$StartSound.play()
	await get_tree().create_timer(0.2, false).timeout
	get_tree().change_scene_to_file("res://code/main.tscn")


func _on_quit_pressed():
	$QuitSound.play()
	await get_tree().create_timer(0.2, false).timeout
	get_tree().quit()
