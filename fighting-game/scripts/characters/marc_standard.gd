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
	if not is_attacking and not is_being_grabbed and knockback_velocity.length() <= 50:
		check_attack_inputs()
	super._physics_process(delta)

func check_attack_inputs():
	var up = Input.is_action_pressed(get_input_string("move_up"))
	var down = Input.is_action_pressed(get_input_string("move_down"))
	var side = abs(Input.get_axis(get_input_string("move_left"), get_input_string("move_right"))) > 0.5
	
	# --- NORMAL (Le Joueur attaque - coups faibles) ---
	if Input.is_action_just_pressed(get_input_string("attack_normal")):
		if is_on_floor():
			if up: play_move("player_up")
			elif down: play_move("player_down")
			elif side: play_move("player_side")
			else: play_move("player_neutral")
		else:
			play_move("player_air")

	# --- SPECIAL (Le Stand attaque !) ---
	elif Input.is_action_just_pressed(get_input_string("attack_special")) and is_stand_active:
		# On ne bloque pas forcément le joueur, on dit au Stand d'attaquer !
		if is_on_floor():
			if up: my_stand.play_move("stand_up")
			elif down: my_stand.play_move("stand_down")
			elif side: my_stand.play_move("stand_side")
			else: my_stand.play_move("stand_neutral")
		else:
			my_stand.play_move("stand_air")

	# --- ULTIME (Invoquer / Rappeler le Stand) ---
	elif Input.is_action_just_pressed(get_input_string("attack_ultimate")):
		toggle_stand()

func toggle_stand():
	is_stand_active = !is_stand_active
	if is_stand_active:
		my_stand.show()
		# On place le stand juste derrière le joueur lors de l'invocation
		my_stand.global_position = global_position + Vector2(-50 * facing_direction, -20)
		my_stand.play_move("summon")
	else:
		my_stand.hide()

func play_move(anim_name: String):
	is_attacking = true
	$AnimationPlayer.play(anim_name)
