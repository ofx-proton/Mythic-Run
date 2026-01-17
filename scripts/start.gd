extends Control

@onready var transition: CanvasLayer = $Transition
func _on_button_pressed():
	await transition.fade(1.0, 1.5).finished
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	
func _on_menu_pressed():
	await transition.fade(1.0, 1.5).finished
	get_tree().change_scene_to_file("res://scenes/tips.tscn")
	
	

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("click_enter"):
		await transition.fade(1.0, 1.5).finished
		get_tree().change_scene_to_file("res://scenes/game.tscn")
		


	

func start_game() -> void:
	await transition.fade(1.0, 1.5).finished
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	
	

 # Replace with function body.
