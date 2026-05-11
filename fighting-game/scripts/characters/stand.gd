class_name Stand extends CharacterBody2D

var master_player: Fighter = null
var is_attacking: bool = false

# Paramètres de combat du Stand
var current_attack_damage: float = 8.0
var current_attack_knockback: float = 600.0

# --- STATISTIQUES ---
@export var max_hp: float = 200.0
@export var speed: float = 300.0
@export var jump_velocity: float = -600.0
@export var weight: float = 0.8
@export var gravity_multiplier: float = 1.0

# Multiplicateur global pour régler la puissance de tous les coups du jeu d'un coup
@export var knockback_scaling: float = 0.3

# --- JAUGE D'ULTIME ---
@export var max_ultimate: float = 100.0
@export var current_hp: float

# Timer de Hitstun (pour bloquer la manette après un coup)
var knockback_velocity: Vector2 = Vector2.ZERO 
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_grabbing: bool = false
var is_being_grabbed: bool = false
var grabbed_opponent: Fighter = null

var double_jump_left: int = 1
var facing_direction: int = 1

# --- Limite d'attaques en l'air ---
var max_air_attacks: int = 2
var air_attacks_left: int = 2

var invuln_timer: float = 0.0 

# On remplace _process par _physics_process pour que la gravité fonctionne bien
func _physics_process(delta):
	if master_player == null or not visible:
		return

	if invuln_timer > 0:
		invuln_timer -= delta

	# 1. On synchronise la direction propre du Stand avec celle du maître
	facing_direction = master_player.facing_direction

	# 2. LE FIX MIROIR : On utilise l'échelle et non la position pour contrer l'AnimationPlayer
	if facing_direction == 1:
		$Sprite2D.flip_h = true
		if has_node("Hitbox"): 
			$Hitbox.scale.x = 1
	else:
		$Sprite2D.flip_h = false
		if has_node("Hitbox"): 
			$Hitbox.scale.x = -1

	# 3. Logique de Mouvement (Le Fix physique)
	if not is_attacking:
		# Le Stand flotte derrière le joueur
		var target_pos = master_player.global_position + Vector2(-60 * facing_direction, -40)
		global_position = global_position.lerp(target_pos, 5 * delta)
		velocity = Vector2.ZERO
	else:
		# Pendant une attaque, on applique la gravité et ON BOUGE VRAIMENT
		velocity.y += (gravity * gravity_multiplier) * delta
		move_and_slide()

func command_attack(anim_name: String):
	if not visible:
		return
	
	if $AnimationPlayer.has_animation(anim_name):
		is_attacking = true
		$AnimationPlayer.play(anim_name)
	else:
		print("ATTENTION: L'animation '", anim_name, "' manque sur le Stand !")

# A appeler à la fin de chaque animation du Stand via la piste Call Method !
func end_attack():
	is_attacking = false

# --- FONCTIONS PHYSIQUES DES ATTAQUES ---

func power_jump():
	velocity.y = -800
	velocity.x = 0
	current_attack_knockback = 400
	
func apply_dash_boost(force: float):
	velocity.x = force * facing_direction
	velocity.y = 0

func power_dash():
	apply_dash_boost(1000)

func spec_neutral():
	return

# --- DEGATS ---

func _on_hitbox_area_entered(area):
	if area.name == "Hurtbox" and area.get_parent() != master_player and area.get_parent() != self:
		var ennemi = area.get_parent()
		
		# --- LA NOUVELLE SÉCURITÉ EST ICI ---
		# On vérifie que la cible possède bien une fonction pour prendre des coups
		if ennemi.has_method("take_damage"):                                                                                                                                                                                                                                                                                                                                            
			if "invuln_timer" in ennemi and ennemi.invuln_timer <= 0:
				var direction = (ennemi.global_position - global_position).normalized()
				direction.y -= 0.5 
				
				# Le Stand remplit la jauge d'Ultime de son maître !
				if "current_ultimate" in master_player:
					master_player.current_ultimate = clamp(master_player.current_ultimate + current_attack_damage * 0.75, 0.0, master_player.max_ultimate)
				
				ennemi.take_damage(current_attack_damage, current_attack_knockback, direction)
			
			# --- A AJOUTER A LA FIN DE stand.gd ---

func take_damage(damage: float, base_knockback: float, knockback_direction: Vector2):
	if invuln_timer > 0:
		return
	invuln_timer = 0.2

	current_hp -= damage

	# Le Stand subit un knockback (recul) physique
	var safe_weight = max(weight, 0.1)
	var final_knockback = (base_knockback * knockback_scaling) / safe_weight

	var safe_direction = knockback_direction
	if safe_direction.length() == 0:
		safe_direction = Vector2(-facing_direction, -1)

	velocity = safe_direction.normalized() * final_knockback
	is_attacking = false

	# Si le Stand tombe à 0 PV, il se brise !
	if current_hp <= 0:
		current_hp = 0
		hide()
		# On prévient le maître que le Stand est mort
		if master_player:
			master_player.is_stand_active = false
			master_player.current_ultimate = 0 # Marc perd toute sa jauge !
