extends Node

@onready var music: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	music.stream = preload("res://assets/bg_music.mp3")
	music.loop = true
	music.play()
