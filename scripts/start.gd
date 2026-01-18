extends Control

@onready var transition: CanvasLayer = $Transition

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("click_enter"):
		_change_scene("res://scenes/game.tscn")

func _on_start_pressed() -> void:
	_change_scene("res://scenes/game.tscn")

func _on_menu_pressed() -> void:
	_change_scene("res://scenes/tips.tscn")

func start_game() -> void:
	_change_scene("res://scenes/game.tscn")

func _change_scene(path: String) -> void:
	get_tree().paused = false
	
	if transition and transition.has_method("fade"):
		await transition.fade(1.0, 1.5).finished
		
	get_tree().change_scene_to_file(path)
