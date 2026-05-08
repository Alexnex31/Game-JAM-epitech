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

var is_grabbing: bool = false
var is_being_grabbed: bool = false
var grabbed_opponent: Fighter = null # Référence vers celui qu'on a attrapé

var double_jump_left: int = 1

# 1 = regarde à droite, -1 = regarde à gauche
var facing_direction: int = 1 

# La fameuse fonction manquante
func get_facing_direction() -> int:
	return facing_direction

func get_input_string(action_name: String) -> String:
	return action_name + "_" + str(player_id)
	
	
func _ready():
	current_hp = max_hp

func _physics_process(delta):
	# 1. Appliquer la gravité
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		double_jump_left = 1

	# 2. Gestion du saut
	var jump_action = get_input_string("jump")
	if Input.is_action_just_pressed(jump_action) and is_on_floor():
		velocity.y = jump_velocity
	if Input.is_action_just_pressed(jump_action) and not(is_on_floor()) and double_jump_left > 0:
		velocity.y = jump_velocity
		double_jump_left -= 1
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
			facing_direction = sign(direction) # sign() renvoie 1 ou -1
			update_facing()
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
	if is_being_grabbed:
		# Si on est tenu, on ne fait rien, on suit la position de l'attaquant
		return

	# Lancement du Grab
	var grab_action = get_input_string("grab")
	if Input.is_action_just_pressed(grab_action) and is_on_floor() and not is_attacking:
		start_grab()
		
		
func update_facing():
	# 1. On tourne l'image (le Sprite)
	if facing_direction == 1:
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true
		
	# 2. On déplace les Hitboxes du bon côté
	# On utilise abs() pour forcer la valeur en positif, puis on multiplie par 1 ou -1
	if has_node("Hitbox"):
		$Hitbox.position.x = abs($Hitbox.position.x) * facing_direction
		
	if has_node("GrabArea"):
		$GrabArea.position.x = abs($GrabArea.position.x) * facing_direction

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

func start_grab():
	is_attacking = true # On considère le grab comme une action d'attaque
	is_grabbing = true
	$AnimationPlayer.play("grab_attempt") # Lance l'animation de saisie

# Connecte le signal area_entered de ton GrabArea à cette fonction
func _on_grab_area_area_entered(area):
	if is_grabbing and area.name == "Hurtbox":
		var target = area.get_parent()
		if target != self and target is Fighter:
			catch_opponent(target)

func catch_opponent(target):
	grabbed_opponent = target
	target.be_grabbed(self) # On dit à l'adversaire qu'il est attrapé
	$AnimationPlayer.play("grab_success") # Animation où on tient l'ennemi

func be_grabbed(attacker):
	is_being_grabbed = true
	velocity = Vector2.ZERO
	# On peut aussi le repositionner légèrement devant l'attaquant
	global_position = attacker.global_position + Vector2(40 * attacker.get_facing_direction(), 0)

func release_grab():
	is_being_grabbed = false
	is_grabbing = false
	grabbed_opponent = null
	
func execute_throw():
	if grabbed_opponent:
		# On définit une direction de projection (ex: vers le haut et l'avant)
		var throw_dir = Vector2(get_facing_direction(), -1).normalized()
		
		# On applique les dégâts et le knockback (utilise la logique Smash de FighterBase)
		grabbed_opponent.is_being_grabbed = false
		grabbed_opponent.take_damage(15.0, 700.0, throw_dir)
		
		grabbed_opponent = null
		is_grabbing = false
		is_attacking = false
