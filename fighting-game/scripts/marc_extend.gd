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
	var special_action = get_input_string("attack_special")
	if Input.is_action_just_pressed(special_action) and my_stand:
		my_stand.attack()
