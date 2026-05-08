extends Node

# Ces variables stockeront les scènes (PackedScene) choisies par les joueurs
var p1_char_scene: PackedScene
var p2_char_scene: PackedScene

# Nombre de manches pour gagner (2 pour BO3, 3 pour BO5)
var wins_to_victory: int = 2
