extends HSlider

@export 
var bus_name: String

var bus_index: int


# Called when the node enters the scene tree for the first time.
func _ready():
	value = 1
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
func _on_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
