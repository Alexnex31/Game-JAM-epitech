extends Button

@export var action_name: String
var is_rebinding = false

func _ready():
	set_process_unhandled_input(false)
	update_text()
	pressed.connect(_on_pressed)

func update_text():
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		text = events[0].as_text()
	else:
		text = "Aucune touche"

func _on_pressed():
	is_rebinding = true
	text = "..." # On met des points de suspension au début
	# On attend un tout petit peu pour éviter que l'appui sur le bouton soit capturé
	await get_tree().create_timer(0.1).timeout
	text = "Appuyez sur une touche..."
	set_process_unhandled_input(true)

func _unhandled_input(event):
	if is_rebinding:
		# On n'accepte que les pressions de boutons, axes poussés à fond ou touches clavier
		var is_valid_event = false
		if event is InputEventJoypadButton and event.pressed:
			is_valid_event = true
		elif event is InputEventJoypadMotion and abs(event.axis_value) > 0.5:
			is_valid_event = true
		elif event is InputEventKey and event.pressed:
			# On évite de binder la touche pause ici si on veut l'utiliser pour annuler
			if not event.is_action("pause"):
				is_valid_event = true
			
		if is_valid_event:
			# Supprimer l'ancien bind
			InputMap.action_erase_events(action_name)
			
			# Ajouter le nouveau bind
			InputMap.action_add_event(action_name, event)
			
			is_rebinding = false
			set_process_unhandled_input(false)
			update_text()
			# Empêcher l'event de se propager
			get_viewport().set_input_as_handled()
			# On redonne le focus au bouton pour continuer la navigation
			grab_focus()
		
		elif event.is_action_pressed("pause"):
			is_rebinding = false
			set_process_unhandled_input(false)
			update_text()
			get_viewport().set_input_as_handled()
			grab_focus()
