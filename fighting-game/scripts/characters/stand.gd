extends Node2D

var master_player = null
var is_attacking: bool = false

# Paramètres de combat du Stand
var current_attack_damage: float = 12.0
var current_attack_knockback: float = 600.0

func _process(delta):
	if master_player == null or not visible:
		return
		
	# 1. Le Stand regarde toujours dans la même direction que son maître
	if master_player.facing_direction == 1:
		$Sprite2D.flip_h = false
		if has_node("Hitbox"): $Hitbox.position.x = abs($Hitbox.position.x)
	else:
		$Sprite2D.flip_h = true
		if has_node("Hitbox"): $Hitbox.position.x = -abs($Hitbox.position.x)

	# 2. Si le Stand n'attaque pas, il suit le joueur doucement (effet de flottement)
	if not is_attacking:
		# Il se place un peu au-dessus et derrière le joueur
		var target_pos = master_player.global_position + Vector2(-60 * master_player.facing_direction, -40)
		global_position = global_position.lerp(target_pos, 5 * delta)

func play_move(anim_name: String):
	# On vérifie que l'animation existe bien dans la liste !
	if $AnimationPlayer.has_animation(anim_name):
		is_attacking = true
		$AnimationPlayer.play(anim_name)
	else:
		print("ATTENTION: L'animation '", anim_name, "' manque !")

# A appeler à la fin de chaque animation du Stand via la piste Call Method !
func end_attack():
	is_attacking = false

# Connecte le signal 'area_entered' de la Hitbox du Stand ici :
func _on_hitbox_area_entered(area):
	if area.name == "Hurtbox" and area.get_parent() != master_player:
		var ennemi = area.get_parent()
		var direction = (ennemi.global_position - global_position).normalized()
		direction.y -= 0.5 
		ennemi.take_damage(current_attack_damage, current_attack_knockback, direction)
