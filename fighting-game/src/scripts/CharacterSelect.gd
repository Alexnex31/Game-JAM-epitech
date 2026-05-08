extends Control

@onready var char_grid = $CenterContainer/VBoxContainer/GridContainer
@onready var p1_preview = $HBoxContainer/P1_Area/Preview
@onready var p2_preview = $HBoxContainer/P2_Area/Preview
@onready var p1_status = $HBoxContainer/P1_Area/Status
@onready var p2_status = $HBoxContainer/P2_Area/Status

@export var char1_tank: PackedScene 
@export var char2_standard: PackedScene
@export var char3_speed: PackedScene 
@export var char4_stand: PackedScene

var characters = [
	{"name": "CeciYA", "scene": "res://fighting-game/CecilYA.tscn", "icon": "res://fighting-game/icon.svg"},
	{"name": "President", "scene": "res://fighting-game/President.tscn", "icon": "res://fighting-game/icon.svg"},
	{"name": "Noe", "scene": "res://fighting-game/NOE.tscn", "icon": "res://fighting-game/icon.svg"},
	{"name": "Marc", "scene": "res://fighting-game/Marc.tscn", "icon": "res://fighting-game/icon.svg"}
]

var p1_index = 0
var p2_index = 0
var p1_ready = false
var p2_ready = false

var p1_last_move = 0.0
var p2_last_move = 0.0
const MOVE_DELAY = 150 # millisecondes

func _ready():
	setup_grid()
	update_selection_ui()

func setup_grid():
	# On vide la grille existante
	for child in char_grid.get_children():
		child.queue_free()
	
	# On crée une case pour chaque personnage
	for char_info in characters:
		var slot = Control.new()
		slot.custom_minimum_size = Vector2(100, 100)
		
		var bg = ColorRect.new()
		bg.name = "ColorRect"
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.color = Color(0.2, 0.2, 0.2)
		slot.add_child(bg)
		
		var label = Label.new()
		label.text = char_info["name"]
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot.add_child(label)
		
		char_grid.add_child(slot)

func _input(event):
	var current_time = Time.get_ticks_msec()
	
	# Gestion Joueur 1
	if event.is_action_pressed("attack_ultimate_1"): # Bouton B
		if p1_ready:
			p1_ready = false
			update_selection_ui()
		else:
			get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")
			return

	if not p1_ready:
		if current_time - p1_last_move > MOVE_DELAY:
			if Input.is_action_pressed("move_left_1"):
				p1_index = posmod(p1_index - 1, characters.size())
				p1_last_move = current_time
				update_selection_ui()
			elif Input.is_action_pressed("move_right_1"):
				p1_index = posmod(p1_index + 1, characters.size())
				p1_last_move = current_time
				update_selection_ui()
		
		if event.is_action_pressed("jump_1"):
			p1_ready = true
			update_selection_ui()

	# Gestion Joueur 2
	if event.is_action_pressed("attack_ultimate_2"): # Bouton B
		if p2_ready:
			p2_ready = false
			update_selection_ui()

	if not p2_ready:
		if current_time - p2_last_move > MOVE_DELAY:
			if Input.is_action_pressed("move_left_2"):
				p2_index = posmod(p2_index - 1, characters.size())
				p2_last_move = current_time
				update_selection_ui()
			elif Input.is_action_pressed("move_right_2"):
				p2_index = posmod(p2_index + 1, characters.size())
				p2_last_move = current_time
				update_selection_ui()
		
		if event.is_action_pressed("jump_2"):
			p2_ready = true
			update_selection_ui()

	# Lancement si les deux sont prêts
	if p1_ready and p2_ready:
		start_game()

func update_selection_ui():
	# On met à jour les bordures/couleurs des cases dans la grille
	for i in range(char_grid.get_child_count()):
		var slot = char_grid.get_child(i)
		var bg = slot.get_node("ColorRect")
		
		bg.color = Color(0.2, 0.2, 0.2) # Default
		if p1_index == i and p2_index == i:
			bg.color = Color(0.6, 0.2, 0.6) # Violet si les deux sont dessus
		elif p1_index == i:
			bg.color = Color(0.2, 0.2, 1.0) # Bleu P1
		elif p2_index == i:
			bg.color = Color(1.0, 0.2, 0.2) # Rouge P2
			
	p1_preview.text = characters[p1_index]["name"]
	p2_preview.text = characters[p2_index]["name"]
	
	p1_status.text = "PRET !" if p1_ready else "Choisis..."
	p1_status.modulate = Color.GREEN if p1_ready else Color.WHITE
	
	p2_status.text = "PRET !" if p2_ready else "Choisis..."
	p2_status.modulate = Color.GREEN if p2_ready else Color.WHITE

func get_character_scene(id):
	if id == 0:
		return char1_tank
	if id == 1:
		return char2_standard
	if id == 2:
		return char3_speed
	return char4_stand

func start_game():
	# Ici on devrait stocker les choix dans un Singleton ou passer par des arguments
	# Pour l'instant on lance juste l'arène
	GameManager.p1_char_scene = get_character_scene(p1_index)
	GameManager.p2_char_scene = get_character_scene(p2_index)
	print("Lancement du combat: ", characters[p1_index]["name"], " VS ", characters[p2_index]["name"])
	get_tree().change_scene_to_file("res://src/scenes/brouillon_arena.tscn")
