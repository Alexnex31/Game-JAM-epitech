extends Camera2D

# J'ai augmenté les vitesses car on utilise 'delta' maintenant
@export var move_speed: float = 5.0 
@export var zoom_speed: float = 5.0
# Dans Godot, un zoom < 1 éloigne (dézoome), un zoom > 1 rapproche.
@export var min_zoom: float = 1.5 # Limite max de dézoom (très éloigné)
@export var max_zoom: float = 3 # Limite max de zoom (très proche)
@export var margin: Vector2 = Vector2(400, 200)

var targets: Array[Node2D] = []

@onready var screen_size = get_viewport_rect().size

func add_target(t: Node2D):
	if not t in targets:
		targets.append(t)

func remove_target(t: Node2D):
	if t in targets:
		targets.erase(t) # CORRECTION : 'erase' au lieu de 'remove' dans Godot 4

func _process(delta):
	if targets.is_empty():
		return
		
	# 1. Calcul de la position moyenne (le point entre tous les joueurs)
	var p = Vector2.ZERO
	for target in targets:
		p += target.position
	p /= targets.size()
	
	# Déplacement fluide
	position = position.lerp(p, move_speed * delta)

	# 2. Calcul du rectangle qui englobe tous les joueurs
	var r = Rect2(position, Vector2.ZERO)
	for target in targets:
		r = r.expand(target.position)
		
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
	
	# 3. Calcul du zoom (CORRECTION de la division)
	var z: float
	if r.size.x > r.size.y * screen_size.aspect():
		z = screen_size.x / r.size.x 
	else:
		z = screen_size.y / r.size.y
		
	z = clamp(z, min_zoom, max_zoom)
	
	# Zoom fluide
	zoom = zoom.lerp(Vector2.ONE * z, zoom_speed * delta)
