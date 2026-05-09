extends Node2D

var master_player: Fighter = null
var is_attacking: bool = false

# Paramètres de combat du Stand
var current_attack_damage: float = 12.0
var current_attack_knockback: float = 600.0

# --- STATISTIQUES ---
@export var max_hp: float = 200.0
@export var speed: float = 300.0
@export var jump_velocity: float = -600.0
@export var weight: float = 1.0
@export var gravity_multiplier: float = 1.0

# Multiplicateur global pour régler la puissance de tous les coups du jeu d'un coup
@export var knockback_scaling: float = 0.3

# --- JAUGE D'ULTIME ---
@export var max_ultimate: float = 100.0

@export var current_hp: float

# Timer de Hitstun (pour bloquer la manette après un coup)
var velocity: Vector2 = Vector2.ZERO 
var knockback_velocity: Vector2 = Vector2.ZERO 
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_grabbing: bool = false
var is_being_grabbed: bool = false
var grabbed_opponent: Fighter = null

var double_jump_left: int = 1
var facing_direction: int = 1

# --- NOUVEAU : Limite d'attaques en l'air ---
var max_air_attacks: int = 2
var air_attacks_left: int = 2

var invuln_timer: float = 0.0 

func _process(delta):
	if master_player == null or not visible:
		return
	
	if invuln_timer > 0:
		invuln_timer -= delta
	# 1. Le Stand regarde la même direction que son maître
	# ET on applique le FIX MIROIR pour la Hitbox !
	if master_player.facing_direction == 1:
		$Sprite2D.flip_h = true # Ou true selon ton sprite
		if has_node("Hitbox"): 
			$Hitbox.scale.x = 1
	else:
		$Sprite2D.flip_h = false
		if has_node("Hitbox"): 
			$Hitbox.scale.x = -1

	# 2. Si le Stand n'attaque pas, il suit le joueur doucement (effet de flottement)
	if not is_attacking:
		if $AnimationPlayer.has_animation("stand/RESET_AIR"):
			$AnimationPlayer.play("stand/RESET_AIR")
		# Il se place un peu au-dessus et derrière le joueur
		var target_pos = master_player.global_position + Vector2(-60 * master_player.facing_direction, -40)
		global_position = global_position.lerp(target_pos, 5 * delta)

func take_damage(damage: float, base_knockback: float, knockback_direction: Vector2):
	# --- SÉCURITÉ ANTI MULTI-HIT ---
	if invuln_timer > 0:
		return 
	invuln_timer = 0.2 
	current_hp -= damage
	if damage > master_player.current_ultimate:
		master_player.current_ultimate = damage
	master_player.current_ultimate -= damage
	if current_hp <= 0: current_hp = 0
	# 1. Calcul du ratio de vie perdue (0.0 à 1.0)
	var safe_max_hp = max(max_hp, 1.0) 
	var missing_health_ratio = (safe_max_hp - current_hp) / safe_max_hp 

	# 2. LE SECRET DU KNOCKBACK : La courbe exponentielle
	# Formule : 1.0 + (ratio * ratio * multiplicateur_de_puissance)
	var power_factor = 2.0 # Augmente ce chiffre pour que les persos volent encore plus loin à bas PV
	var knockback_multiplier = 1.0 + (missing_health_ratio * missing_health_ratio * power_factor)
	
	# 3. Calcul final avec le poids et le scaling global
	var safe_weight = max(weight, 0.1) 
	var final_knockback = (base_knockback * knockback_multiplier * knockback_scaling) / safe_weight
	
	# 4. Sécurité de direction
	var safe_direction = knockback_direction
	if safe_direction.length() == 0:
		safe_direction = Vector2(-facing_direction, -1)

	# 5. Application de l'impulsion
	velocity = safe_direction.normalized() * final_knockback
	knockback_velocity = velocity 
	
	# Interruption des actions
	is_attacking = false 
# Fonction appelée par Marc quand il appuie sur le bouton Spécial
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

func _on_hitbox_area_entered(area):
	if area.name == "Hurtbox" and area.get_parent() != master_player and area.get_parent() != self:
		var ennemi = area.get_parent()
		
		if ennemi.invuln_timer <= 0:
			var direction = (ennemi.global_position - global_position).normalized()
			direction.y -= 0.5 
			
			# Le Stand remplit la jauge d'Ultime de son maître !
			master_player.current_ultimate = clamp(master_player.current_ultimate + current_attack_damage * 0.75, 0.0, master_player.max_ultimate)
			
			ennemi.take_damage(current_attack_damage, current_attack_knockback, direction)
