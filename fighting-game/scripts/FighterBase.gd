class_name Fighter extends CharacterBody2D

# --- STATISTIQUES (Export permet de les modifier dans l'éditeur pour chaque perso) ---
@export var max_hp: float = 100.0
@export var speed: float = 300.0
@export var jump_velocity: float = -600.0
@export var weight: float = 1.0 # Plus c'est lourd, moins ça vole loin
@export var player_id: int = 1 # Pour différencier le Joueur 1 du Joueur 2

var current_hp: float
var knockback_velocity: Vector2 = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	current_hp = max_hp

func _physics_process(delta):
	# 1. Appliquer la gravité
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Gestion du saut
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# 3. Gestion du mouvement (Gauche / Droite)
	var direction = Input.get_axis("move_left", "move_right")
	
	# On ne bouge que si on n'est pas en train de subir un énorme knockback
	if knockback_velocity.length() < 100: 
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	# 4. Appliquer le Knockback et le réduire progressivement (Friction)
	if knockback_velocity != Vector2.ZERO:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 5 * delta)
		# On additionne la physique de base et le vol du coup reçu
		velocity.x += knockback_velocity.x
		velocity.y += knockback_velocity.y 

	# 5. Déplacer le personnage
	move_and_slide()

# --- SYSTEME DE COMBAT ---

func take_damage(damage: float, base_knockback: float, knockback_direction: Vector2):
	current_hp -= damage
	if current_hp <= 0:
		current_hp = 0
		# Gérer la mort par HP ici

	# Calcul du Knockback façon Smash (plus les PV sont bas, plus le multiplicateur est grand)
	# Exemple : Si max_hp = 100 et current_hp = 20, on a perdu 80% de vie.
	var missing_health_ratio = (max_hp - current_hp) / max_hp 
	var knockback_multiplier = 1.0 + (missing_health_ratio * 2.0) # Jusqu'à x3 de knockback à 0 HP
	
	var final_knockback = (base_knockback * knockback_multiplier) / weight
	knockback_velocity = knockback_direction.normalized() * final_knockback
