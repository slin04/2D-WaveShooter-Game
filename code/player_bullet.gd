extends Area2D

var velocity = Vector2(0,0)
var acceleration = Vector2(-100,0)
var damage = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	acceleration = acceleration*0.95
	velocity += acceleration
	position += velocity * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
	
func testFunction(text):
	print(text)
