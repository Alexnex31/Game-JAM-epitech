extends Fighter

# --- ORGANISATION DES ANIMATIONS ---
@export var anim_prefix: String = "cecilya/"

var ult_timer: float = 0.0

func _physics_process(delta):
	# Gestion de la durée de l'Ultime
	if ult_timer > 0:
		ult_timer -= delta
		if ult_timer <= 0:
			end_ultimate()

	# Réinitialisation visuelle au repos
	if not is_attacking:
		if is_on_floor():
			if $AnimationPlayer.has_animation("RESET"):
				$AnimationPlayer.play("RESET")
		else:
			if $AnimationPlayer.has_animation("RESET_AIR"):
				$AnimationPlayer.play("RESET_AIR")
				
	if not is_attacking and not is_being_grabbed and knockback_velocity.length() <= 50:
		check_attack_inputs()

	super._physics_process(delta)

func check_attack_inputs():
	var up = Input.is_action_pressed(get_input_string("move_up"))
	var down = Input.is_action_pressed(get_input_string("move_down"))
	var side = abs(Input.get_axis(get_input_string("move_left"), get_input_string("move_right"))) > 0.5
	
	if Input.is_action_just_pressed(get_input_string("attack_normal")):
		if is_on_floor():
			if up: play_move("cecilya/uppercut")
			elif down: play_move("cecilya/poirier")
			elif side: play_move("cecilya/dash_attack")
			else: play_move("cecilya/neutral")
		else:
			if up: play_move("cecilya/air_headbutt")
			elif down: 
				play_move("cecilya/air_kick")
				velocity.y = 0
			elif side: play_move("cecilya/air_dash_attack")
			else: play_move("cecilya/air_spin")

	elif Input.is_action_just_pressed(get_input_string("attack_special")):
		if is_on_floor():
			if up: play_move("cecilya/spec_up")
			elif down: play_move("cecilya/spec_down")
			elif side: play_move("cecilya/spec_side")
			else: play_move("cecilya/spec_neutral")
		else:
			if up: play_move("cecilya/spec_air_headbutt")
			elif down: 
				play_move("cecilya/spec_air_kick")
				velocity.y = 0
			elif side: play_move("cecilya/spec_air_dash_attack")
			else: play_move("cecilya/spec_air")

	# --- ULTIME ---
	elif Input.is_action_just_pressed(get_input_string("attack_ultimate")):
		if current_ultimate >= max_ultimate: 
			start_ultimate()
		else:
			print("Ultime pas encore prêt ! Charge : ", current_ultimate)

func play_move(anim_name: String):

	# --- Vérification de la limite aérienne ---
	if not is_on_floor():
		if air_attacks_left <= 0:
			return 
		air_attacks_left -= 1 
	# -----------------------------------------------------

	if $AnimationPlayer.has_animation(anim_name):
		is_attacking = true
		$AnimationPlayer.play(anim_name)
	else:
		print("ATTENTION: L'animation '", anim_name, "' manque !")

# --- MECANIQUES SPECIFIQUES AU TANK ---

func spec_neutral():
	# --- LE CHAMP DE FORCE ---
	velocity.x = 0 # Elle s'arrête sur place
	current_attack_damage = 5.0 # Fait peu de dégâts
	current_attack_knockback = 500.0 # Repousse violemment

func earthquake():
	current_attack_damage = 15.0
	current_attack_knockback = 800.0

func body_splash():
	# Tombe très vite vers le bas
	velocity.y = 1000
	velocity.x = 0

func start_ultimate():
	current_ultimate = 0.0 # On vide la jauge
	ult_timer = 10.0 # L'armure dure 10 secondes
	
	# Ultime : Devient inamovible et rouge
	weight *= 3.0
	modulate = Color(1.0, 0.4, 0.4) 

func end_ultimate():
	weight /= 3.0 # Elle retrouve son poids normal
	modulate = Color(1.0, 1.0, 1.0) # Elle retrouve sa couleur
