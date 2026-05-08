extends Fighter

# Le tank peut avoir une mécanique de "Super Armure" ou des attaques chargées.
# Ici, on va lui faire une mécanique de "Garde" renforcée et d'attaques de zone.

func _physics_process(delta):
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

# --- MECANIQUES SPECIFIQUES AU TANK ---

func earthquake():
	# Par exemple, une attaque qui tape tout le sol autour de lui
	current_attack_damage = 15.0
	current_attack_knockback = 800.0
	# Dans l'AnimationPlayer, tu activeras une Hitbox très large au niveau du sol !

func body_splash():
	# Tombe très vite vers le bas
	velocity.y = 1000
	velocity.x = 0

func start_ultimate():
	# Ultime : Devient inamovible (poids x3) et tape plus fort pendant 10s
	weight *= 3.0
	modulate = Color(1.0, 0.5, 0.0) # Orange/Rouge
	# Tu pourras ajouter un Timer comme pour le perso 2 pour annuler l'effet !
