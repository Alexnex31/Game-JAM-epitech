extends Fighter


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


var is_climbing = false

func _physics_process(delta):
	# Si le perso touche un mur (fonction Godot intégrée) et appuie sur haut/bas
	var up_action = get_input_string("move_up")
	var down_action = get_input_string("move_down")
	
	if is_on_wall() and (Input.is_action_pressed(up_action) or Input.is_action_pressed(down_action)):
		is_climbing = true
		velocity.y = Input.get_axis(up_action, down_action) * (speed * 0.5)
		velocity.x = 0
		move_and_slide()
	else:
		is_climbing = false
		super._physics_process(delta) # Appelle le code de FighterBase
