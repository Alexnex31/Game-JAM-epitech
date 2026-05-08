extends Node2D

var p1: Fighter
var p2: Fighter
var game_over: bool = false

@onready var p1_pv_label = $UI/HUD/HBoxContainer/P1_Stats/P1_PV
@onready var p1_kb_label = $UI/HUD/HBoxContainer/P1_Stats/P1_KB
@onready var p2_pv_label = $UI/HUD/HBoxContainer/P2_Stats/P2_PV
@onready var p2_kb_label = $UI/HUD/HBoxContainer/P2_Stats/P2_KB

@onready var victory_layer = $UI/HUD/VictoryLayer
@onready var victory_label = $UI/HUD/VictoryLayer/VictoryLabel

func _ready():
	# Sécurité au cas où on lance l'arène directement pour tester
	if GameManager.p1_char_scene == null or GameManager.p2_char_scene == null:
		print("Erreur : Personnages non choisis. Lance le jeu depuis le menu !")
		return

	# --- JOUEUR 1 ---
	# 1. On crée le personnage en mémoire
	p1 = GameManager.p1_char_scene.instantiate()
	
	# 2. On configure ses données avant de l'afficher
	p1.name = "Player1"
	p1.player_id = 1
	p1.global_position = $SpawnP1.global_position
	
	# 3. On l'ajoute officiellement à l'arène
	add_child(p1)
	
	# --- JOUEUR 2 ---
	p2 = GameManager.p2_char_scene.instantiate()
	p2.name = "Player2"
	p2.player_id = 2
	p2.global_position = $SpawnP2.global_position
	
	# On force le Joueur 2 à regarder vers la gauche au début du match
	p2.facing_direction = -1 
	p2.update_facing()
	
	add_child(p2)

	# --- CAMERA ---
	# On donne nos deux joueurs tous neufs à la caméra
	var camera = $DynamicCamera
	camera.add_target(p1)
	camera.add_target(p2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if game_over:
		return

	if is_instance_valid(p1):
		p1_pv_label.text = "PV: " + str(round(p1.current_hp))
		p1_kb_label.text = "KB: " + str(snapped(p1.knockback_scaling, 0.1))
		if p1.current_hp <= 0:
			show_victory(2) # P2 gagne
	
	if is_instance_valid(p2):
		p2_pv_label.text = "PV: " + str(round(p2.current_hp))
		p2_kb_label.text = "KB: " + str(snapped(p2.knockback_scaling, 0.1))
		if p2.current_hp <= 0:
			show_victory(1) # P1 gagne

func show_victory(winner_id: int):
	if game_over:
		return
	
	game_over = true
	victory_layer.visible = true
	victory_label.text = "JOUEUR " + str(winner_id) + " GAGNE !"
	
	# Optionnel: on peut figer les joueurs
	if is_instance_valid(p1): p1.set_physics_process(false)
	if is_instance_valid(p2): p2.set_physics_process(false)
	
	# Retour au menu après 3 secondes
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

func _on_blast_zone_body_entered(body):
	if game_over:
		return
		
	if body is Fighter:
		print(body.name + " est tombé dans le vide !")
		if body == p1:
			show_victory(2)
		elif body == p2:
			show_victory(1)
		
		body.queue_free()
