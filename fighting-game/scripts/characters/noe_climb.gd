extends Fighter

# Le Speedster a une mécanique d'Overclock (Ultime)
var is_overclocked: bool = false
var overclock_timer: float = 0.0

func _physics_process(delta):
	# Gestion de la durée de l'Ultime
	if overclock_timer > 0:
		overclock_timer -= delta
		if overclock_timer <= 0:
			end_ultimate()

	# Réinitialisation visuelle au repos (empruntée au Président)
	if not is_attacking:
		if is_on_floor():
			if $AnimationPlayer.has_animation("RESET"):
				$AnimationPlayer.play("RESET")
		else:
			if $AnimationPlayer.has_animation("RESET_AIR"):
				$AnimationPlayer.play("RESET_AIR")

	# On utilise la même condition que le perso 2 pour autoriser l'attaque
	if not is_attacking and not is_being_grabbed and knockback_velocity.length() <= 50:
		check_attack_inputs()

	super._physics_process(delta)

func check_attack_inputs():
	var up = Input.is_action_pressed(get_input_string("move_up"))
	var down = Input.is_action_pressed(get_input_string("move_down"))
	var side = abs(Input.get_axis(get_input_string("move_left"), get_input_string("move_right"))) > 0.5
	
	# --- NORMAL ---
	if Input.is_action_just_pressed(get_input_string("attack_normal")):
		if is_on_floor():
			if up: play_move("noe/uppercut")
			elif down: play_move("noe/poirier")
			elif side: play_move("noe/dash_attack")
			else: play_move("noe/neutral")
		else:
			if up: play_move("noe/air_headbutt")
			elif down: 
				play_move("noe/air_kick")
				velocity.y = 0
			elif side: play_move("noe/air_dash_attack")
			else: play_move("noe/air_spin")

	# --- SPECIAL ---
	elif Input.is_action_just_pressed(get_input_string("attack_special")):
		if is_on_floor():
			if up: play_move("noe/spec_up")
			elif down: play_move("noe/spec_down")
			elif side: play_move("noe/spec_side")
			else: play_move("noe/spec_neutral")
		else:
			if up: play_move("noe/spec_air_headbutt")
			elif down: 
				play_move("noe/spec_air_kick")
				velocity.y = 0
			elif side: play_move("noe/spec_air_dash_attack")
			else: play_move("noe/spec_air")

	# --- ULTIME (Overclock) ---
	elif Input.is_action_just_pressed(get_input_string("attack_ultimate")):
		if current_ultimate >= max_ultimate: 
			start_ultimate()
		else:
			print("Ultime pas encore prêt ! Charge : ", current_ultimate)

func play_move(anim_name: String):
	# --- Vérification de la limite aérienne ---
	if not is_on_floor():
		if air_attacks_left <= 0:
			return # On bloque l'attaque, la limite est atteinte !
		air_attacks_left -= 1 # On consomme une attaque en l'air
	# ------------------------------------------

	# On vérifie que l'animation existe bien dans la liste
	if $AnimationPlayer.has_animation(anim_name):
		is_attacking = true
		$AnimationPlayer.play(anim_name)
	else:
		print("ATTENTION: L'animation '", anim_name, "' manque !")

# --- MECANIQUES SPECIFIQUES AU SPEEDSTER ---

func power_jump():
	velocity.y = -950 # Saute beaucoup plus haut/vite que le perso Standard
	current_attack_damage = 8.0 # Fait un peu moins mal (c'est un speedster)
	current_attack_knockback = 300.0

func power_dash():
	apply_dash_boost(1300) # Dash très agressif

func spec_neutral():
	# Au lieu d'un simple buff de force, il fait un dash instantané sur place
	modulate = Color(1.0, 1.0, 0.0) # Jaune éclair
	velocity.x = 1800 * facing_direction
	velocity.y = 0
	current_attack_damage = 8.0
	current_attack_knockback = 150.0

func start_ultimate():
	current_ultimate = 0.0 # On vide la jauge
	is_overclocked = true
	overclock_timer = 10.0 # Dure 10 secondes
	speed *= 1.8 # Devient très rapide
	jump_velocity -= 250 # Amplitude de saut augmentée
	
	# Effet visuel
	modulate = Color(0.5, 0.8, 1.0) # Teinte bleutée électrique
	
func end_ultimate():
	is_overclocked = false
	speed /= 1.8
	jump_velocity += 250
	modulate = Color(1, 1, 1)
