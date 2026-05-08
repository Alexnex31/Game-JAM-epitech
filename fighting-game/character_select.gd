extends Control

# Glisse tes scènes .tscn de personnages ici depuis l'inspecteur !
@export var char1_tank: PackedScene 
@export var char2_standard: PackedScene
@export var char3_speed: PackedScene 
@export var char4_stand: PackedScene

var current_step: int = 1 # 1 = J1 choisit, 2 = J2 choisit

# Connecte le signal 'pressed' de ton bouton Tank ici
func _on_button_tank_pressed():
	assign_character(char1_tank)

# Connecte le signal 'pressed' de ton bouton Standard ici
func _on_button_standard_pressed():
	assign_character(char2_standard)
	
func _on_button_speed_pressed():
	assign_character(char3_speed)

# Connecte le signal 'pressed' de ton bouton Stand ici
func _on_button_stand_pressed():
	assign_character(char4_stand)

func assign_character(chosen_scene: PackedScene):
	if current_step == 1:
		GameManager.p1_char_scene = chosen_scene
		current_step = 2
		print("Joueur 1 a choisi ! Au tour du Joueur 2.")
		# Astuce : Tu peux changer un texte à l'écran ici pour le dire aux joueurs
	elif current_step == 2:
		GameManager.p2_char_scene = chosen_scene
		print("Joueur 2 a choisi ! Lancement du combat...")
		# On charge l'arène
		get_tree().change_scene_to_file("res://brouillon_arena.tscn")
