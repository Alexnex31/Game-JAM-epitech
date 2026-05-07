class_name Fighter extends CharacterBody2D

# --- STATISTIQUES (Export permet de les modifier dans l'éditeur pour chaque perso) ---
@export var max_hp: float = 100.0
@export var speed: float = 300.0
@export var jump_velocity: float = -600.0
@export var weight: float = 1.0 # Plus c'est lourd, moins ça vole loin
@export var player_id: int = 1 # Pour différencier le Joueur 1 du Joueur 2
var is_attacking: bool = false
var current_hp: float
var knockback_velocity: Vector2 = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func get_input_string(action_name: String) -> String:
	return action_name + "_" + str(player_id)
	
	
func _ready():
	current_hp = max_hp

func _physics_process(delta):
	# 1. Appliquer la gravité
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Gestion du saut
	var jump_action = get_input_string("jump")
	if Input.is_action_just_pressed(jump_action) and is_on_floor():
		velocity.y = jump_velocity
	if is_attacking:
		# On ralentit le perso s'il était en train de courir quand il a frappé
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		move_and_slide()
		return

	# Mouvement dynamique
	var left_action = get_input_string("move_left")
	var right_action = get_input_string("move_right")
	var direction = Input.get_axis(left_action, right_action)
	
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
	var attack_action = get_input_string("attack_normal")
	if Input.is_action_just_pressed(attack_action) and is_on_floor():
		is_attacking = true
		# On joue l'animation (Attention au chemin de l'AnimationPlayer)
		$AnimationPlayer.play("attack_normal")
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

func end_attack():
	is_attacking = false
	# Optionnel : ramener le sprite à son animation d'inactivité
	# $AnimationPlayer.play("idle")

# On définit la puissance de l'attaque en cours (modifiée par l'animation)
var current_attack_damage: float = 10.0
var current_attack_knockback: float = 500.0

func _on_hitbox_area_entered(area):
	# On vérifie qu'on touche bien une Hurtbox, et pas NOTRE propre Hurtbox
	if area.name == "Hurtbox" and area.get_parent() != self:
		var ennemi = area.get_parent()
		
		# Calculer la direction du coup (de moi vers l'ennemi)
		var direction = (ennemi.global_position - global_position).normalized()
		# On ajoute un peu de hauteur pour l'effet Smash (on l'envoie en l'air)
		direction.y -= 0.5 
		
		ennemi.take_damage(current_attack_damage, current_attack_knockback, direction)
