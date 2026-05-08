class_name Fighter extends CharacterBody2D

# --- STATISTIQUES ---
@export var max_hp: float = 100.0
@export var speed: float = 300.0
@export var jump_velocity: float = -600.0
@export var weight: float = 1.0
@export var player_id: int = 1
@export var gravity_multiplier: float = 1.0

# Multiplicateur global pour régler la puissance de tous les coups du jeu d'un coup
@export var knockback_scaling: float = 0.4

# --- JAUGE D'ULTIME ---
@export var max_ultimate: float = 100.0
var current_ultimate: float = 0.0

var is_attacking: bool = false
var current_hp: float

# Timer de Hitstun (pour bloquer la manette après un coup)
var knockback_velocity: Vector2 = Vector2.ZERO 
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_grabbing: bool = false
var is_being_grabbed: bool = false
var grabbed_opponent: Fighter = null

var double_jump_left: int = 1
var facing_direction: int = 1

var current_attack_damage: float = 10.0
var current_attack_knockback: float = 100.0

# --- NOUVEAU : Timer d'invincibilité (anti multi-hit) ---
var invuln_timer: float = 0.0 

func get_facing_direction() -> int:
	return facing_direction

func get_input_string(action_name: String) -> String:
	return action_name + "_" + str(player_id)
	
func _ready():
	current_hp = max_hp

func _physics_process(delta):
	# Diminution du chrono d'invincibilité
	if invuln_timer > 0:
		invuln_timer -= delta

	if is_being_grabbed:
		return

	# 1. Gravité toujours active
	if not is_on_floor():
		velocity.y += (gravity * gravity_multiplier) * delta
	else:
		double_jump_left = 1

	# 2. Diminution du verrouillage de la manette (Hitstun)
	if knockback_velocity.length() > 50:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 5 * delta)
		# FREIN D'URGENCE : On ralentit violemment le perso sur l'axe X
		velocity.x = move_toward(velocity.x, 0, 2500 * delta)

	# 3. Contrôles (Seulement si on n'est pas en train de voler à cause d'un coup)
	if knockback_velocity.length() <= 50: 
		if is_attacking:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, (speed * 3) * delta)
		else:
			# --- MOUVEMENT ---
			var left = get_input_string("move_left")
			var right = get_input_string("move_right")
			var direction = Input.get_axis(left, right)
			
			if direction:
				velocity.x = direction * speed
				facing_direction = sign(direction)
				update_facing()
			else:
				velocity.x = move_toward(velocity.x, 0, speed)

			# --- SAUT ---
			var jump = get_input_string("jump")
			if Input.is_action_just_pressed(jump):
				if is_on_floor():
					velocity.y = jump_velocity
				elif double_jump_left > 0:
					velocity.y = jump_velocity
					double_jump_left -= 1
			
			# --- GRAB ---
			var grab_action = get_input_string("grab")
			if Input.is_action_just_pressed(grab_action) and is_on_floor():
				start_grab()

	# 4. On se déplace simplement avec la vélocité native de Godot
	move_and_slide()

func update_facing():
	if facing_direction == 1:
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true
		
	if has_node("Hitbox"):
		$Hitbox.position.x = abs($Hitbox.position.x) * facing_direction
		
	if has_node("GrabArea"):
		$GrabArea.position.x = abs($GrabArea.position.x) * facing_direction

# --- SYSTEME DE COMBAT ---

func take_damage(damage: float, base_knockback: float, knockback_direction: Vector2):
	# --- SÉCURITÉ ANTI MULTI-HIT ---
	if invuln_timer > 0:
		return 
	invuln_timer = 0.2 
	# -------------------------------

	current_hp -= damage
	if current_hp <= 0: current_hp = 0

	# 1. Calcul du ratio de vie perdue (0.0 à 1.0)
	var safe_max_hp = max(max_hp, 1.0) 
	var missing_health_ratio = (safe_max_hp - current_hp) / safe_max_hp 

	# 2. LE SECRET DU KNOCKBACK : La courbe exponentielle
	# On élève le ratio au carré pour que le knockback n'augmente pas trop vite au début
	# mais devienne massif à la fin.
	# Formule : 1.0 + (ratio * ratio * multiplicateur_de_puissance)
	var power_factor = 5.0 # Augmente ce chiffre pour que les persos volent encore plus loin à bas PV
	var knockback_multiplier = 1.0 + (missing_health_ratio * missing_health_ratio * power_factor)
	
	# 3. Calcul final avec le poids et le scaling global
	var safe_weight = max(weight, 0.1) 
	var final_knockback = (base_knockback * knockback_multiplier * knockback_scaling) / safe_weight
	
	# 4. Sécurité de direction
	var safe_direction = knockback_direction
	if safe_direction.length() == 0:
		safe_direction = Vector2(-facing_direction, -1)

	# On gagne de l'ultime quand on prend des coups (ex: 50% des dégâts reçus)
	current_ultimate = clamp(current_ultimate + (damage * 0.5), 0.0, max_ultimate)
	# 5. Application de l'impulsion
	velocity = safe_direction.normalized() * final_knockback
	knockback_velocity = velocity 
	
	# Interruption des actions
	is_attacking = false 
	is_grabbing = false

func get_kb_ratio() -> float:
	var safe_max_hp = max(max_hp, 1.0)
	return (safe_max_hp - current_hp) / safe_max_hp

func _on_hitbox_area_entered(area):
	if not is_attacking:
		return 
		
	if area.name == "Hurtbox" and area.get_parent() != self:
		var ennemi = area.get_parent()
		
		if ennemi.invuln_timer <= 0:
			# SÉCURITÉ 4 : Éviter le Vector2.ZERO si les joueurs sont au même pixel
			var direction = ennemi.global_position - global_position
			if direction.length() < 0.1:
				# S'ils sont superposés, on le pousse devant nous
				direction = Vector2(facing_direction, 0)
				
			direction = direction.normalized()
			# Angle vers le haut façon Smash
			direction.y -= 0.6 
			
			# On gagne de l'ultime quand on tape (ex: 100% des dégâts infligés)
			current_ultimate = clamp(current_ultimate + current_attack_damage, 0.0, max_ultimate)
			ennemi.take_damage(current_attack_damage, current_attack_knockback, direction)

func end_attack():
	is_attacking = false

func start_grab():
	is_attacking = true
	is_grabbing = true
	$AnimationPlayer.play("grab_attempt")

func _on_grab_area_area_entered(area):
	if is_grabbing and area.name == "Hurtbox":
		var target = area.get_parent()
		if target != self and target is Fighter:
			catch_opponent(target)

func catch_opponent(target):
	grabbed_opponent = target
	target.be_grabbed(self)
	$AnimationPlayer.play("grab_success")

func be_grabbed(attacker):
	is_being_grabbed = true
	velocity = Vector2.ZERO
	global_position = attacker.global_position + Vector2(40 * attacker.get_facing_direction(), 0)

func release_grab():
	is_being_grabbed = false
	is_grabbing = false
	grabbed_opponent = null
	
func execute_throw():
	if grabbed_opponent:
		var throw_dir = Vector2(get_facing_direction(), -1).normalized()
		grabbed_opponent.is_being_grabbed = false
		grabbed_opponent.take_damage(15.0, 600.0, throw_dir)
		grabbed_opponent = null
		is_grabbing = false
		is_attacking = false

func apply_dash_boost(force: float):
	velocity.x = force * facing_direction
	velocity.y = 0


func _on_animation_player_animation_finished(anim_name):
	end_attack()
	release_grab() # Au cas où une chope plante
