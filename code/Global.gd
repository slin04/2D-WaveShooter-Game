extends Node

var Player
var gruntNum 
var sniperNum
var brawlerNum

var score
var enemiesKilled
var startTime

var gameOver
var despawn

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func onGameStart():
	gameOver = false
	despawn = false
	gruntNum = 0
	sniperNum = 0
	brawlerNum = 0
	score = 0
	enemiesKilled = 0
	
func onGameEnd():
	Global.despawn = true	

	
func enemyNum():
	return gruntNum + sniperNum + brawlerNum


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
