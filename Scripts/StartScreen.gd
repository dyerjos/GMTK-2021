extends Node2D

#var Player = preload('res://Players/PlayerShip.tscn')
#const INTENSE_MUSIC = preload('res://MusicAndSound/IntenseMusic.tscn')

#func _ready():
#	visible = true # incase I hide for testing

#func _on_SinglePlayer_pressed():
#	GameManager.total_players = 1
#	GameManager.current_player_count = 1
#	get_tree().paused = false
#	var intense_music = INTENSE_MUSIC.instance()
#	get_parent().add_child(intense_music)
#	queue_free()


#func _on_TwoPlayer_pressed():
#	GameManager.total_players = 2
#	GameManager.current_player_count = 2
#	var new_player = Player.instance()
#	new_player.position = $Player2Position.position
#	new_player.player_id = 2
#	get_parent().add_child(new_player)
#	var intense_music = INTENSE_MUSIC.instance()
#	get_parent().add_child(intense_music)
#	get_tree().paused = false
#	queue_free()
