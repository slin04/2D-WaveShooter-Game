extends Area2D

var velocity = Vector2(-1250,0)
var acceleration = Vector2(-25,0)
var damage = 10

var id = "enemy_bullet"
var screen_size = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_parent().get_arena_size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkOutOfBounds()


func _physics_process(delta):
	acceleration = acceleration*0.95
	velocity += acceleration
	position += velocity * delta
	
func checkOutOfBounds():
	if (position.x <= 0 || position.x >= screen_size.x || position.y <= 0 || position.y >= screen_size.y):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
