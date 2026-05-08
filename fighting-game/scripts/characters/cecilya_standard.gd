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
	
	# --- NORMAL (Coups lourds et lents) ---
	if Input.is_action_just_pressed(get_input_string("attack_normal")):
		if is_on_floor():
			if up: play_move("heavy_uppercut")
			elif down: play_move("ground_stomp")
			elif side: play_move("lariat") # Grand coup de bras
			else: play_move("heavy_jab")
		else:
			if up: play_move("air_clap")
			elif down: play_move("body_splash") # Tombe de tout son poids
			elif side: play_move("air_hammer")
			else: play_move("air_belly")

	# --- SPECIAL (Contrôle du terrain) ---
	elif Input.is_action_just_pressed(get_input_string("attack_special")):
		if is_on_floor():
			if up: play_move("anti_air_grab") # Chope en l'air
			elif down: play_move("earthquake") # Tremblement de terre
			elif side: play_move("shoulder_bash") # Coup d'épaule massif
			else: play_move("flex_armor") # Buff de défense temporaire
		else:
			play_move("meteor_smash")

	# --- ULTIME (Mode Rage) ---
	elif Input.is_action_just_pressed(get_input_string("attack_ultimate")):
		start_ultimate()

func play_move(anim_name: String):
	is_attacking = true
	$AnimationPlayer.play(anim_name)

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
