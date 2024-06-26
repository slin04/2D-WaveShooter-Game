extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkPause()
			
			
func checkPause():
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		if !self.visible:
			self.visible = true
			modulate.a = 0.1
			for i in 9:
				await get_tree().create_timer(0.01, true).timeout
				modulate.a += 0.1
		else:
			modulate.a = 1.0
			for i in 10:
				await get_tree().create_timer(0.01, true).timeout
				modulate.a -= 0.1
			self.visible = false
		
