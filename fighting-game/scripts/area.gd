extends Node2D

var p1: Fighter
var p2: Fighter

@onready var p1_pv_label = $UI/HUD/HBoxContainer/P1_Stats/P1_PV
@onready var p1_kb_label = $UI/HUD/HBoxContainer/P1_Stats/P1_KB
@onready var p2_pv_label = $UI/HUD/HBoxContainer/P2_Stats/P2_PV
@onready var p2_kb_label = $UI/HUD/HBoxContainer/P2_Stats/P2_KB

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
	if is_instance_valid(p1):
		p1_pv_label.text = "PV: " + str(round(p1.current_hp))
		p1_kb_label.text = "KB: " + str(snapped(p1.knockback_scaling, 0.1))
	
	if is_instance_valid(p2):
		p2_pv_label.text = "PV: " + str(round(p2.current_hp))
		p2_kb_label.text = "KB: " + str(snapped(p2.knockback_scaling, 0.1))

func _on_blast_zone_body_entered(body):
	if body is Fighter:
		print(body.name + " est tombé dans le vide !")
		body.queue_free() # Détruit le joueur (ou gère le Game Over)
