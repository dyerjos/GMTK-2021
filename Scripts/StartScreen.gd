extends Node2D

const INTENSE_MUSIC = preload('res://MusicAndSound/IntenseMusic.tscn')

func _ready():
	visible = true # incase I hide for testing
	GameManager.winner = null

func _on_TwoPlayer_pressed():
	get_tree().paused = false
	var intense_music = INTENSE_MUSIC.instance()
	get_parent().add_child(intense_music)
	queue_free()
