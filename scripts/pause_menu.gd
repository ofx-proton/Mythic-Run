extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Label/Button.pressed.connect(_on_ResumeButton_pressed)

func _on_ResumeButton_pressed() -> void:
	get_tree().paused = false
	hide()
