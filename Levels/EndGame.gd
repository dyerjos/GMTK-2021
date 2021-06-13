extends Panel

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_PlayAgainButton_pressed():
	GameManager.winner = null
	get_tree().reload_current_scene()
	
