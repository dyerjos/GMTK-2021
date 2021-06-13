extends Node2D

var winner = null

var EndGame = load('res://Levels/EndGame.tscn')

func _ready():
	get_tree().paused = true

func _process(delta: float):
	if winner:
		get_tree().paused = true
		var end_game = EndGame.instance()
		get_tree().get_root().add_child(end_game)
