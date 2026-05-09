extends Sprite2D

# On expose les variables pour pouvoir glisser-déposer les images depuis l'inspecteur
@export var texture_frequente: Texture2D # L'image qui apparaîtra 9 fois sur 10
@export var texture_rare: Texture2D      # L'image qui apparaîtra 1 fois sur 10

func _ready():
	# On génère un nombre décimal aléatoire entre 0.0 et 1.0
	var hasard = randf()
	
	# Logique de probabilité :
	# Si le nombre est inférieur à 0.9 (90%), on met la texture fréquente.
	# Sinon (les 10% restants), on met la texture rare.
	if hasard < 0.9:
		texture = texture_frequente
		MusicManager.play_arena_common()
	else:
		texture = texture_rare
		print("Chanceux ! Le background rare a été chargé.")
		MusicManager.play_arena_rare()
