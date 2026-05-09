extends Fighter

@export var stand_scene: PackedScene # Tu glisseras la scène du Stand ici dans l'inspecteur

var my_stand: Node2D = null
var is_stand_active: bool = false

func _ready():
	super._ready()
	# On instancie le Stand au début, mais on le cache
	if stand_scene:
		my_stand = stand_scene.instantiate()
		# On l'ajoute à l'Arène (le parent), pas au joueur, pour qu'il soit indépendant
		get_parent().call_deferred("add_child", my_stand) 
		# On lui donne la référence de son maître
		my_stand.master_player = self
		my_stand.hide()

func _physics_process(delta):
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
	
	# --- ATTAQUES NORMALES (Marc attaque lui-même) ---
	if Input.is_action_just_pressed(get_input_string("attack_normal")):
		if is_on_floor():
			if up: play_move("marc/uppercut")
			elif down: play_move("marc/poirier")
			elif side: play_move("marc/dash_attack")
			else: play_move("marc/neutral")
		else:
			if up: play_move("marc/air_headbutt")
			elif down: 
				play_move("marc/air_kick")
				velocity.y = 0
			elif side: play_move("marc/air_dash_attack")
			else: play_move("marc/air_spin")

	# --- ATTAQUES SPÉCIALES (Le Stand attaque !) ---
	elif Input.is_action_just_pressed(get_input_string("attack_special")):
		# On vérifie que le Stand est là, et qu'il n'est pas DÉJÀ en train d'attaquer
		if is_stand_active and my_stand != null and not my_stand.is_attacking:
			if is_on_floor():
				if up: my_stand.command_attack("stand/spec_up")
				elif down: my_stand.command_attack("stand/spec_down")
				elif side: my_stand.command_attack("stand/spec_side")
				else: my_stand.command_attack("stand/spec_neutral")
			else:
				if up: my_stand.command_attack("stand/spec_air_headbutt")
				elif down: my_stand.command_attack("stand/spec_air_kick")
				elif side: my_stand.command_attack("stand/spec_air_dash_attack")
				else: my_stand.command_attack("stand/spec_air")

	# --- ULTIME (Invoquer / Rappeler le Stand) ---
	elif Input.is_action_just_pressed(get_input_string("attack_ultimate")):
		toggle_stand()

func toggle_stand():
	is_stand_active = !is_stand_active
	if is_stand_active and current_ultimate >= 10:
		my_stand.current_hp = current_ultimate
		my_stand.show()
		# On place le stand juste derrière le joueur lors de l'invocation
		my_stand.global_position = global_position + Vector2(-50 * facing_direction, -20)
		my_stand.command_attack("stand/summon") # Animation d'apparition du Stand
	else:
		my_stand.hide()

func play_move(anim_name: String):
	
	# --- Vérification de la limite aérienne ---
	if not is_on_floor():
		if air_attacks_left <= 0:
			return 
		air_attacks_left -= 1 

	# On vérifie que l'animation existe bien !
	if $AnimationPlayer.has_animation(anim_name):
		is_attacking = true
		$AnimationPlayer.play(anim_name)
	else:
		print("ATTENTION: L'animation '", anim_name, "' manque sur Marc !")
