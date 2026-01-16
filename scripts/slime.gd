extends CharacterBody2D

@export var speed := 120.0
@export var direction := -1

func _physics_process(delta):
	velocity.x = speed * direction
	move_and_slide()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.die()
