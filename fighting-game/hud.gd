extends Control

# On crée des références vers les barres (glisse tes nœuds ici si les noms diffèrent)
@onready var p1_bar = $HBoxContainer/P1_Stats/P1_Ultimate
@onready var p2_bar = $HBoxContainer/P2_Stats/P2_Ultimate

# Ces variables stockeront les références vers les nœuds des joueurs
var player1: Fighter = null
var player2: Fighter = null

func _process(_delta):
	# Mise à jour du Joueur 1
	if is_instance_valid(player1):
		p1_bar.max_value = player1.max_ultimate
		p1_bar.value = player1.current_ultimate
		
		# Petit bonus visuel : la barre brille quand elle est pleine
		if player1.current_ultimate >= player1.max_ultimate:
			p1_bar.modulate = Color(2, 2, 0) # Effet Bloom/Brillance (Jaune)
		else:
			p1_bar.modulate = Color(1, 1, 1) # Normal

	# Mise à jour du Joueur 2
	if is_instance_valid(player2):
		p2_bar.max_value = player2.max_ultimate
		p2_bar.value = player2.current_ultimate
		
		if player2.current_ultimate >= player2.max_ultimate:
			p2_bar.modulate = Color(2, 2, 0)
		else:
			p2_bar.modulate = Color(1, 1, 1)
