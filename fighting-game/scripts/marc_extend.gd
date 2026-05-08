extends Fighter


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var stand_scene: PackedScene
var my_stand

func _ready():
	super._ready()
	if stand_scene:
		my_stand = stand_scene.instantiate()
		get_parent().call_deferred("add_child", my_stand) # L'ajoute dans l'arène

func _physics_process(delta):
	super._physics_process(delta)
	# Envoie les inputs d'attaque spéciale au Stand
	if Input.is_action_just_pressed("attack_special") and my_stand:
		my_stand.attack()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
