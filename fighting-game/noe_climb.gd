extends Fighter


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


var is_climbing = false

func _physics_process(delta):
	# Si le perso touche un mur (fonction Godot intégrée) et appuie sur haut/bas
	if is_on_wall() and (Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down")):
		is_climbing = true
		velocity.y = Input.get_axis("move_up", "move_down") * (speed * 0.5)
		velocity.x = 0
	else:
		is_climbing = false
		super._physics_process(delta) # Appelle le code de FighterBase
# 2. Gestion du saut
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# 3. Gestion du mouvement (Gauche / Droite)
	var direction = Input.get_axis("move_left", "move_right")
	
	# On ne bouge que si on n'est pas en train de subir un énorme knockback
	if knockback_velocity.length() < 100: 
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	# 4. Appliquer le Knockback et le réduire progressivement (Friction)
	if knockback_velocity != Vector2.ZERO:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 5 * delta)
		# On additionne la physique de base et le vol du coup reçu
		velocity.x += knockback_velocity.x
		velocity.y += knockback_velocity.y 

	# 5. Déplacer le personnage
	move_and_slide()
