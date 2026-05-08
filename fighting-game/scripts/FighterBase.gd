class_name Fighter extends CharacterBody2D

# --- STATISTIQUES ---
@export var max_hp: float = 100.0
@export var speed: float = 300.0
@export var jump_velocity: float = -600.0
@export var weight: float = 1.0
@export var player_id: int = 1
@export var gravity_multiplier: float = 1.0

var is_attacking: bool = false
var current_hp: float
var knockback_velocity: Vector2 = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_grabbing: bool = false
var is_being_grabbed: bool = false
var grabbed_opponent: Fighter = null

var double_jump_left: int = 1
var facing_direction: int = 1 

var current_attack_damage: float = 10.0
var current_attack_knockback: float = 500.0

func get_facing_direction() -> int:
	return facing_direction

func get_input_string(action_name: String) -> String:
	return action_name + "_" + str(player_id)
	
func _ready():
	current_hp = max_hp

func _physics_process(delta):
	# 1. Si on est attrapé, on annule toute notre physique (on subit)
	if is_being_grabbed:
		return

	# 2. Gravité et sauts (Toujours actifs)
	if not is_on_floor():
		velocity.y += (gravity * gravity_multiplier) * delta
	else:
		double_jump_left = 1

	# 3. Gestion du Knockback (La friction en l'air)
	if knockback_velocity != Vector2.ZERO:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 5 * delta)

	# 4. Machine à état : Attaque VS Mouvement
	if is_attacking:
		# Friction pendant une attaque (pour lisser la fin d'un dash)
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, (speed * 3) * delta)
	else:
		# On ne contrôle le perso que s'il ne subit pas un gros recul
		if knockback_velocity.length() < 100: 
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

	# 5. Déplacement final combiné au Knockback
	# (Astuce : on additionne le knockback juste pour le move_and_slide, puis on l'enlève)
	var base_velocity = velocity
	velocity += knockback_velocity 
	move_and_slide()
	velocity = base_velocity 

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
	current_hp -= damage
	if current_hp <= 0: current_hp = 0

	var missing_health_ratio = (max_hp - current_hp) / max_hp 
	var knockback_multiplier = 1.0 + (missing_health_ratio * 2.0)
	var final_knockback = (base_knockback * knockback_multiplier) / weight
	knockback_velocity = knockback_direction.normalized() * final_knockback

func end_attack():
	is_attacking = false

func _on_hitbox_area_entered(area):
	if area.name == "Hurtbox" and area.get_parent() != self:
		var ennemi = area.get_parent()
		var direction = (ennemi.global_position - global_position).normalized()
		direction.y -= 0.5 
		ennemi.take_damage(current_attack_damage, current_attack_knockback, direction)

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
		grabbed_opponent.take_damage(15.0, 700.0, throw_dir)
		grabbed_opponent = null
		is_grabbing = false
		is_attacking = false

func apply_dash_boost(force: float):
	velocity.x = force * facing_direction
	velocity.y = 0 # Coupe la chute pour donner un effet plus "sec" au dash
