extends Control

func _ready():
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("click_enter") :
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	
func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	
