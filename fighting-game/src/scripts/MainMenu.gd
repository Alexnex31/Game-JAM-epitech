extends Control

func _ready():
	$CenterContainer/VBoxContainer/Jouer.grab_focus()

func _on_jouer_pressed():
	# Lance la scène de l'arène
	get_tree().change_scene_to_file("res://CharacterSelect.tscn")

func _on_parametres_pressed():
	# Lance la scène des paramètres
	get_tree().change_scene_to_file("res://src/scenes/SettingsMenu.tscn")

func _on_credit_pressed():
	# Pour l'instant, on affiche juste un message ou on pourrait ouvrir un lien/pop-up
	print("Crédits: Développé par l'équipe Game Jam")
	# Optionnel: on peut ajouter un Label visible ou une autre scène

func _on_quitter_pressed():
	# Quitte le jeu
	get_tree().quit()
