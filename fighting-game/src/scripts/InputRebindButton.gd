extends Button

@export var action_name: String
var is_rebinding = false

func _ready():
	set_process_unhandled_input(false)
	update_text()

func update_text():
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		text = events[0].as_text()
	else:
		text = "Aucune touche"

func _on_pressed():
	is_rebinding = true
	text = "Appuyez sur une touche..."
	set_process_unhandled_input(true)

func _unhandled_input(event):
	if is_rebinding:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			# Supprimer l'ancien bind
			var old_events = InputMap.action_get_events(action_name)
			for e in old_events:
				InputMap.action_erase_event(action_name, e)
			
			# Ajouter le nouveau bind
			InputMap.action_add_event(action_name, event)
			
			is_rebinding = false
			set_process_unhandled_input(false)
			update_text()
			# Empêcher l'event de se propager
			get_viewport().set_input_as_handled()
		
		elif event.is_action_pressed("ui_cancel"): # Permet d'annuler avec Echap ou B
			is_rebinding = false
			set_process_unhandled_input(false)
			update_text()
			get_viewport().set_input_as_handled()
