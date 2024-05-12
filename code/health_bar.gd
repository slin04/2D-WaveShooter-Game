extends ProgressBar

var offset = Vector2(0,0)


# Called when the node enters the scene tree for the first time.
func _ready():
	offset.x = -self.size.x/2
	offset.y = -self.size.y/2 - 80
	
	healthLoadingAnimation()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Global.Player != null):
		trackPosition()
		showHealth()
	else:
		queue_free()
			
func trackPosition():
	if (Global.Player.position.y >= 100):
		position = Global.Player.position + offset
	else:
		position = Global.Player.position + offset + Vector2(0, 160)
		
func showHealth():
	var health = Global.Player.health as float
	var maxHealth = Global.Player.maxHealth as float
	value = (health / maxHealth) * 100.0
	
	
func healthLoadingAnimation():
	var originalSize = self.size.x
	self.size.x = originalSize/20
	await get_tree().create_timer(0.01).timeout
	for i in 19:
		await get_tree().create_timer(0.01).timeout
		self.size.x += originalSize/20
	await get_tree().create_timer(1).timeout
