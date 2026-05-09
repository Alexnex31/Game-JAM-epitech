extends Node2D

var p1: Fighter
var p2: Fighter
var game_over: bool = false
var round_active: bool = true

var p1_wins: int = 0
var p2_wins: int = 0
const WINS_TO_VICTORY: int = 2

@onready var p1_hp_bar = $UI/HUD/HBoxContainer/P1_Stats/P1_HPBar
@onready var p1_kb_bar = $UI/HUD/HBoxContainer/P1_Stats/P1_KBBar
@onready var p1_ult_bar = $UI/HUD/HBoxContainer/P1_Stats/P1_Ultimate
@onready var p2_hp_bar = $UI/HUD/HBoxContainer/P2_Stats/P2_HPBar
@onready var p2_kb_bar = $UI/HUD/HBoxContainer/P2_Stats/P2_KBBar
@onready var p2_ult_bar = $UI/HUD/HBoxContainer/P2_Stats/P2_Ultimate
@onready var p1_score_label = $UI/HUD/HBoxContainer/P1_Score
@onready var p2_score_label = $UI/HUD/HBoxContainer/P2_Score

@onready var victory_layer = $UI/HUD/VictoryLayer
@onready var victory_label = $UI/HUD/VictoryLayer/VictoryLabel

func _ready():
	if GameManager.p1_char_scene == null or GameManager.p2_char_scene == null:
		print("Erreur : Personnages non choisis. Lance le jeu depuis le menu !")
		return

	# On instancie les joueurs
	p1 = GameManager.p1_char_scene.instantiate()
	p1.name = "Player1"
	p1.player_id = 1
	add_child(p1)
	
	p2 = GameManager.p2_char_scene.instantiate()
	p2.name = "Player2"
	p2.player_id = 2
	add_child(p2)

	# On configure la caméra
	var camera = $DynamicCamera
	camera.add_target(p1)
	camera.add_target(p2)
	
	# Initialiser les barres
	p1_hp_bar.max_value = p1.max_hp
	p2_hp_bar.max_value = p2.max_hp
	p1_kb_bar.max_value = 1.0
	p2_kb_bar.max_value = 1.0
	p1_ult_bar.max_value = p1.max_ultimate
	p2_ult_bar.max_value = p2.max_ultimate
	
	reset_positions()
	update_score_ui()

func reset_positions():
	round_active = true
	
	p1.global_position = $SpawnP1.global_position
	p1.velocity = Vector2.ZERO
	p1.current_hp = p1.max_hp
	p1.current_ultimate = 0
	p1.knockback_velocity = Vector2.ZERO
	p1.facing_direction = 1
	p1.update_facing()
	p1.set_physics_process(true)
	
	p2.global_position = $SpawnP2.global_position
	p2.velocity = Vector2.ZERO
	p2.current_hp = p2.max_hp
	p2.current_ultimate = 0
	p2.knockback_velocity = Vector2.ZERO
	p2.facing_direction = -1
	p2.update_facing()
	p2.set_physics_process(true)

func update_score_ui():
	p1_score_label.text = str(p1_wins)
	p2_score_label.text = str(p2_wins)

func _process(_delta: float) -> void:
	if game_over or not round_active:
		return

	if is_instance_valid(p1):
		p1_hp_bar.value = p1.current_hp
		p1_kb_bar.value = p1.get_kb_ratio()
		p1_ult_bar.value = p1.current_ultimate
		if p1.current_ultimate >= p1.max_ultimate:
			p1_ult_bar.modulate = Color(2, 2, 0) # Brillance
		else:
			p1_ult_bar.modulate = Color(1, 1, 1)
			
		if p1.current_hp <= 0:
			handle_round_end(2)
	
	if is_instance_valid(p2):
		p2_hp_bar.value = p2.current_hp
		p2_kb_bar.value = p2.get_kb_ratio()
		p2_ult_bar.value = p2.current_ultimate
		if p2.current_ultimate >= p2.max_ultimate:
			p2_ult_bar.modulate = Color(2, 2, 0) # Brillance
		else:
			p2_ult_bar.modulate = Color(1, 1, 1)
			
		if p2.current_hp <= 0:
			handle_round_end(1)

func handle_round_end(winner_id: int):
	if not round_active: return
	round_active = false
	
	if winner_id == 1:
		p1_wins += 1
	else:
		p2_wins += 1
	
	update_score_ui()
	
	# On fige temporairement
	p1.set_physics_process(false)
	p2.set_physics_process(false)
	
	if p1_wins >= GameManager.wins_to_victory or p2_wins >= GameManager.wins_to_victory:
		show_final_victory(winner_id)
	else:
		# Petite pause avant la prochaine manche
		await get_tree().create_timer(1.5).timeout
		reset_positions()

func show_final_victory(winner_id: int):
	game_over = true
	victory_layer.visible = true
	victory_label.text = "VICTOIRE FINALE\nJOUEUR " + str(winner_id) + " !"
	
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

func _on_blast_zone_body_entered(body):
	if game_over or not round_active:
		return
		
	if body is Fighter:
		if body == p1:
			handle_round_end(2)
		elif body == p2:
			handle_round_end(1)
