extends Node

enum GameState {
	MENU,
	CHARACTER_SELECT,
	BATTLE,
	GAME_OVER
}

var current_state = GameState.MENU

func _ready():
	print("Game Started")
	$MultiTargetCam.add_target($President_FighterBase)
	$MultiTargetCam.add_target($President_FighterBase2)
	
	# Set camera limits
	#var r = get_used_rect()
	#$MultiTargetCam.limit_left = r.position.x
	#$MultiTargetCam.limit_right = r.end.x
	change_state(GameState.MENU)

func change_state(new_state: GameState):
	current_state = new_state
	match current_state:
		GameState.MENU:
			_setup_menu()
		GameState.CHARACTER_SELECT:
			_setup_character_select()
		GameState.BATTLE:
			_setup_battle()
		GameState.GAME_OVER:
			_setup_game_over()

func _setup_menu():
	print("Entering Menu")
	# Load Menu Scene here

func _setup_character_select():
	print("Entering Character Select")
	# Load Character Selection Scene here

func _setup_battle():
	print("Entering Battle")
	# Load Battle Scene here

func _setup_game_over():
	print("Entering Game Over")
	# Load Game Over Scene here

func _process(_delta):
	# Global logic that runs every frame
	pass
