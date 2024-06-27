extends Node

var Player

var gruntNum 
var sniperNum
var brawlerNum
var dasherNum
var minionNum

var score
var enemiesKilled
var startTime

var masterVolume
var musicVolume
var sfxVolume

var gameOver
var despawn

# Called when the node enters the scene tree for the first time.
func _ready():
	masterVolume = 0.5
	musicVolume = 1
	sfxVolume = 1
	pass
	
func onGameStart():
	gameOver = false
	despawn = false
	gruntNum = 0
	sniperNum = 0
	brawlerNum = 0
	dasherNum = 0
	minionNum = 0
	score = 0
	enemiesKilled = 0
	
func onGameEnd():
	Global.despawn = true	

	
func enemyNum():
	return gruntNum + sniperNum + brawlerNum + dasherNum + minionNum


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func get_volume_value(name):
	match name:
		"Master":
			return masterVolume
		"Music":
			return musicVolume
		"SFX":
			return sfxVolume
			
func set_volume_value(name, value):
	match name:
		"Master":
			masterVolume = value
		"Music":
			musicVolume = value
		"SFX":
			sfxVolume = value
