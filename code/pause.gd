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
			#modulate.a = 1.0
			#var tween = get_tree().create_tween()
			#tween.tween_property(self, "modulate", Color(1,1,1,1), 1).set_trans(Tween.TRANS_LINEAR)
		else:
			#modulate.a = 1.0
			#var tween = get_tree().create_tween()
			#tween.tween_property(self, "modulate", Color(1,1,1,0), 0.1).set_trans(Tween.TRANS_LINEAR)
			self.visible = false
		
