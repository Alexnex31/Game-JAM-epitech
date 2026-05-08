extends Node2D

func _ready():
	# Sécurité au cas où on lance l'arène directement pour tester
	if GameManager.p1_char_scene == null or GameManager.p2_char_scene == null:
		print("Erreur : Personnages non choisis. Lance le jeu depuis le menu !")
		return

	# --- JOUEUR 1 ---
	# 1. On crée le personnage en mémoire
	var player1 = GameManager.p1_char_scene.instantiate()
	
	# 2. On configure ses données avant de l'afficher
	player1.name = "Player1"
	player1.player_id = 1
	player1.global_position = $SpawnP1.global_position
	
	# 3. On l'ajoute officiellement à l'arène
	add_child(player1)
	
	# --- JOUEUR 2 ---
	var player2 = GameManager.p2_char_scene.instantiate()
	player2.name = "Player2"
	player2.player_id = 2
	player2.global_position = $SpawnP2.global_position
	
	# On force le Joueur 2 à regarder vers la gauche au début du match
	player2.facing_direction = -1 
	player2.update_facing()
	
	add_child(player2)

	# --- CAMERA ---
	# On donne nos deux joueurs tous neufs à la caméra
	var camera = $DynamicCamera
	camera.add_target(player1)
	camera.add_target(player2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_blast_zone_body_entered(body):
	if body is Fighter:
		print(body.name + " est tombé dans le vide !")
		body.queue_free() # Détruit le joueur (ou gère le Game Over)
