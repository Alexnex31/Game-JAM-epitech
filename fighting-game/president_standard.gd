extends Fighter # On hérite de la base

@export var strength_multiplier: float = 1.0
@export var is_mini: bool = false

# Timers pour les effets
var buff_timer: float = 0.0
var mini_timer: float = 0.0

func _physics_process(delta):
	# Gestion des timers de buffs
	if buff_timer > 0:
		buff_timer -= delta
		if buff_timer <= 0: strength_multiplier = 1.0
		
	if mini_timer > 0:
		mini_timer -= delta
		if mini_timer <= 0: end_ultimate()

	# On ne lance pas d'attaque si on est déjà en train d'attaquer
	if not is_attacking and not is_being_grabbed:
		check_attack_inputs()

	super._physics_process(delta) # On garde la physique de base

func check_attack_inputs():
	var up = Input.is_action_pressed(get_input_string("move_up"))
	var down = Input.is_action_pressed(get_input_string("move_down"))
	var side = abs(Input.get_axis(get_input_string("move_left"), get_input_string("move_right"))) > 0.5
	
	# --- BOUTON ATTACK NORMAL ---
	if Input.is_action_just_pressed(get_input_string("attack_normal")):
		if is_on_floor():
			if up: play_move("uppercut")
			elif down: play_move("poirier")
			elif side: play_move("dash_attack")
			else: play_move("neutral")
		else: # En l'air
			if up: play_move("air_headbutt")
			elif down: play_move("air_kick")
			elif side: play_move("air_dash_attack")
			else: play_move("air_spin")

	# --- BOUTON SPECIAL ---
	if Input.is_action_just_pressed(get_input_string("attack_special")):
		if is_on_floor():
			if up: play_move("spec_up")
			elif down: play_move("spec_down")
			elif side: play_move("spec_side")
			else: play_move("spec_neutral")
		else:
			play_move("spec_air")

	# --- ULTIME ---
	if Input.is_action_just_pressed(get_input_string("attack_ultimate")):
		start_ultimate()

func play_move(anim_name: String):
	is_attacking = true
	$AnimationPlayer.play(anim_name)
	
func power_jump():
	velocity.y = -800 # Propulsion vers le haut
	current_attack_damage = 12 * strength_multiplier
	current_attack_knockback = 400

func power_dash():
	velocity.x = facing_direction * 1000 # Dash rapide vers l'avant
	# On pourrait ajouter une variable 'apply_stun' que take_damage lirait
func spec_neutral():
	strength_multiplier = 1.5
	buff_timer = 5.0 # Dure 5 secondes
	# Joue un petit effet visuel ou change la couleur du sprite
	modulate = Color.RED

func start_ultimate():
	is_mini = true
	mini_timer = 8.0 # Dure 8 secondes
	scale = Vector2(0.5, 0.5) # On divise la taille par 2
	speed *= 1.5 # On devient beaucoup plus rapide
	
func end_ultimate():
	is_mini = false
	scale = Vector2(1, 1) # Retour à la normale
	speed /= 1.5
