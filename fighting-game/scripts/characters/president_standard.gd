extends Fighter 

@export var strength_multiplier: float = 1.0
@export var is_mini: bool = false

var buff_timer: float = 0.0
var mini_timer: float = 0.0

func _physics_process(delta):
	if buff_timer > 0:
		buff_timer -= delta
		if buff_timer <= 0: 
			strength_multiplier = 1.0
			modulate = Color(1, 1, 1)
			
	if mini_timer > 0:
		mini_timer -= delta
		if mini_timer <= 0: 
			end_ultimate()

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
			elif down: play_move("air_kick")
			elif side: play_move("air_dash_attack")
			else: play_move("air_spin")

	elif Input.is_action_just_pressed(get_input_string("attack_special")):
		if is_on_floor():
			if up: play_move("spec_up")
			elif down: play_move("spec_down")
			elif side: play_move("spec_side")
			else: play_move("spec_neutral")
		else:
			play_move("spec_air")

	elif Input.is_action_just_pressed(get_input_string("attack_ultimate")):
		start_ultimate()

func play_move(anim_name: String):
	# On vérifie que l'animation existe bien dans la liste !
	if $AnimationPlayer.has_animation(anim_name):
		is_attacking = true
		$AnimationPlayer.play(anim_name)
	else:
		print("ATTENTION: L'animation '", anim_name, "' manque !")
	
func power_jump():
	velocity.y = -800
	current_attack_damage = 12 * strength_multiplier
	current_attack_knockback = 400

func power_dash():
	apply_dash_boost(1000)

func spec_neutral():
	strength_multiplier = 1.5
	buff_timer = 5.0
	modulate = Color.RED

func start_ultimate():
	is_mini = true
	mini_timer = 8.0 
	scale = Vector2(0.5, 0.5) 
	speed *= 1.5 
	
func end_ultimate():
	is_mini = false
	scale = Vector2(1, 1) 
	speed /= 1.5
