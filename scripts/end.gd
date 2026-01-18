extends Control

@onready var transition: CanvasLayer = $Transition

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("click_enter"):
		_change_scene()

func _on_retry_pressed() -> void:
	_change_scene()

func _change_scene() -> void:
	if transition and transition.has_method("fade"):
		await transition.fade(1.0, 1.5).finished
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")
