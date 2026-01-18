extends Control

func _ready() -> void:
	$Label/Button.pressed.connect(_on_ResumeButton_pressed)

func _on_ResumeButton_pressed() -> void:
	get_tree().paused = false
	visible = false
