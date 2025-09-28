extends Panel

var win_texture = preload("res://Textures/win_texture.tres")
var lose_texture = preload("res://Textures/lose_texture.tres")

func _ready() -> void:
	if GlobalVariables.bracket[0] == "Player":
		print("Setting win texture")
		set("theme_override_styles/panel", win_texture)
	else: 
		set("theme_override_styles/panel", lose_texture)
		print("Setting lose texture")
