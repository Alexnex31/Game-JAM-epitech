extends Control

func _ready():
	$VBoxContainer/ScrollContainer/ActionsList/MoveLeft1/Button.grab_focus()

func _on_retour_pressed():
	get_tree().change_scene_to_file("res://src/scenes/SettingsMenu.tscn")
