extends Control

@onready var resolution_option = $CenterContainer/VBoxContainer/Resolution/OptionButton
@onready var volume_slider = $CenterContainer/VBoxContainer/Volume/HSlider

func _ready():
	# Initialiser les résolutions
	resolution_option.add_item("1280x720", 0)
	resolution_option.add_item("1920x1080", 1)
	resolution_option.add_item("Fullscreen", 2)
	
	# Charger les valeurs actuelles
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	
# Donner le focus pour la manette
	resolution_option.grab_focus()

func _on_resolution_option_item_selected(index):
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(1280, 720))
			center_window()
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(1920, 1080))
			center_window()
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func center_window():
	var screen_id = DisplayServer.window_get_current_screen()
	var screen_rect = DisplayServer.screen_get_usable_rect(screen_id)
	var window_size = DisplayServer.window_get_size()
	DisplayServer.window_set_position(screen_rect.position + (screen_rect.size - window_size) / 2)

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_rebind_controller_pressed():
	get_tree().change_scene_to_file("res://src/scenes/RebindMenu.tscn")

func _on_retour_pressed():
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")
