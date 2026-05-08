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
	if is_rebinding: return # Sécurité
	
	is_rebinding = true
	# On désactive le focus pour que le bouton ne réagisse plus aux "clicks" UI
	# mais on le garde visuellement pour savoir où on est
	focus_mode = FOCUS_NONE 
	
	text = "..."
	await get_tree().create_timer(0.2).timeout
	text = "Appuyez sur une touche..."
	set_process_unhandled_input(true)

func _unhandled_input(event):
	if is_rebinding:
		# On ignore les events "echo" (quand on reste appuyé)
		if event is InputEventJoypadButton and event.is_echo(): return

		var is_valid_event = false
		if event is InputEventJoypadButton and event.pressed:
			is_valid_event = true
		elif event is InputEventJoypadMotion and abs(event.axis_value) > 0.6:
			is_valid_event = true
			
		if is_valid_event:
			InputMap.action_erase_events(action_name)
			InputMap.action_add_event(action_name, event)
			
			finish_rebinding()
			get_viewport().set_input_as_handled()
		
		elif event.is_action_pressed("pause"):
			finish_rebinding()
			get_viewport().set_input_as_handled()

func finish_rebinding():
	is_rebinding = false
	set_process_unhandled_input(false)
	update_text()
	# On réactive le focus et on le reprend
	focus_mode = FOCUS_ALL
	grab_focus()
