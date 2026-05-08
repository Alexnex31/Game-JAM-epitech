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
	
	# --- NORMAL ATTACKS (Rapides) ---
	if Input.is_action_just_pressed(get_input_string("attack_normal")):
		if is_on_floor():
			if up: play_move("rapid_up")
			elif down: play_move("slide_kick")
			elif side: play_move("quick_dash_strike")
			else: play_move("jab_combo")
		else:
			if up: play_move("air_drill_up")
			elif down: play_move("dive_kick") # Plongeon rapide vers le sol
			elif side: play_move("air_side_kick")
			else: play_move("air_flurry")

	# --- SPECIAL ATTACKS (Mouvements extrêmes) ---
	elif Input.is_action_just_pressed(get_input_string("attack_special")):
		if is_on_floor():
			if up: play_move("teleport_up")
			elif down: play_move("counter_stance") # Une garde/esquive
			elif side: play_move("piercing_dash") # Traverse l'ennemi
			else: play_move("multi_slap")
		else:
			play_move("air_teleport")

	# --- ULTIME ---
	elif Input.is_action_just_pressed(get_input_string("attack_ultimate")):
		if current_ultimate >= max_ultimate: # On vérifie si la jauge est pleine
			start_ultimate()
		else:
			print("Ultime pas encore prêt ! Charge : ", current_ultimate)

func play_move(anim_name: String):
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
