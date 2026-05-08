extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	
	if new_pause_state:
		$CenterContainer/VBoxContainer/Reprendre.grab_focus()

func _on_reprendre_pressed():
	toggle_pause()

func _on_parametres_pressed():
	# Note: On pourrait vouloir sauvegarder l'état actuel ou juste changer de scène
	# Pour l'instant on change de scène, mais le retour reviendra au menu principal
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/scenes/SettingsMenu.tscn")

func _on_quitter_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")
