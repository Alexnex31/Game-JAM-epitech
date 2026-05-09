extends AudioStreamPlayer

# On expose les variables pour glisser tes musiques dans l'inspecteur
@export var track_menu: AudioStream
@export var track_char_select: AudioStream
@export var track_arena_common: AudioStream
@export var track_arena_rare: AudioStream

# Fonction magique qui change la musique SANS la redémarrer si c'est déjà la bonne
func play_track(new_track: AudioStream):
	if stream == new_track and playing:
		return # La musique joue déjà, on ne fait rien !
		
	stream = new_track
	play()

# Raccourcis pratiques pour tes autres scripts
func play_menu_music():
	play_track(track_menu)

func play_char_select_music():
	play_track(track_char_select)

func play_arena_common():
	play_track(track_arena_common)

func play_arena_rare():
	play_track(track_arena_rare)

func stop_music():
	stop()
