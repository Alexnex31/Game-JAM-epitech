extends Fighter

# Le Speedster a une mécanique d'Overclock (Ultime)
var is_overclocked: bool = false
var overclock_timer: float = 0.0

func _physics_process(delta):
	if overclock_timer > 0:
		overclock_timer -= delta
		if overclock_timer <= 0:
			end_ultimate()

	# On utilise la même condition que le perso 2 pour autoriser l'attaque
	if not is_attacking and not is_being_grabbed and knockback_velocity.length() <= 50:
		check_attack_inputs()

	super._physics_process(delta)

func check_attack_inputs():
	var up = Input.is_action_pressed(get_input_string("move_up"))
	var down = Input.is_action_pressed(get_input_string("move_down"))
	var side = abs(Input.get_axis(get_input_string("move_left"), get_input_string("move_right"))) > 0.5
	
	if Input.is_action_just_pressed(get_input_string("attack_normal")):
		if is_on_floor():
			if up: play_move("uppercut")
			elif down: play_move("poirier")
			elif side: play_move("dash_attack")
			else: play_move("neutral")
		else:
			if up: play_move("air_headbutt")
			elif down: 
				play_move("air_kick")
				velocity.y = 0
			elif side: play_move("air_dash_attack")
			else: play_move("air_spin")

	elif Input.is_action_just_pressed(get_input_string("attack_special")):
		if is_on_floor():
			if up: play_move("spec_up")
			elif down: play_move("spec_down")
			elif side: play_move("spec_side")
			else: play_move("spec_neutral")
		else:
			if up: play_move("spec_air_headbutt")
			elif down: 
				play_move("spec_air_kick")
				velocity.y = 0
			elif side: play_move("spec_air_dash_attack")
			else: play_move("spec_air")

	# --- ULTIME ---
	elif Input.is_action_just_pressed(get_input_string("attack_ultimate")):
		if current_ultimate >= max_ultimate: # On vérifie si la jauge est pleine
			start_ultimate()
		else:
			print("Ultime pas encore prêt ! Charge : ", current_ultimate)

func play_move(anim_name: String):
	# --- NOUVEAU : Vérification de la limite aérienne ---
	if not is_on_floor():
		if air_attacks_left <= 0:
			return # On bloque l'attaque, la limite est atteinte !
		air_attacks_left -= 1 # On consomme une attaque en l'air
	# -----------------------------------------------------

	# On vérifie que l'animation existe bien dans la liste !
	if $AnimationPlayer.has_animation(anim_name):
		is_attacking = true
		$AnimationPlayer.play(anim_name)
	else:
		print("ATTENTION: L'animation '", anim_name, "' manque !")

# --- MECANIQUES SPECIFIQUES AU SPEEDSTER ---

func piercing_dash():
	# Un dash très violent
	apply_dash_boost(1500)
	
func dive_kick():
	# Le force à retomber très vite en diagonale
	velocity.x = 600 * facing_direction
	velocity.y = 800

func start_ultimate():
	is_overclocked = true
	overclock_timer = 10.0 # Dure 10 secondes
	speed *= 1.8 # Devient incontrôlable mais létal
	jump_velocity -= 200 # Saute plus haut
	
	# Effet visuel
	modulate = Color(0.5, 0.8, 1.0) # Teinte bleutée électrique
	
func end_ultimate():
	is_overclocked = false
	speed /= 1.8
	jump_velocity += 200
	modulate = Color(1, 1, 1)
