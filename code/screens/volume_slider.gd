extends HSlider

@export 
var bus_name: String

var bus_index: int


# Called when the node enters the scene tree for the first time.
func _ready():
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	value = Global.get_volume_value(bus_name)
	
func _on_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	Global.set_volume_value(bus_name, value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
