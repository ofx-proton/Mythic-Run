extends Area2D

var velocity: Vector2

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += velocity * delta

func set_rain_velocity(v: Vector2) -> void:
	velocity = v

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die()
	queue_free()

func _process(delta):
	if global_position.y > 2000:
		queue_free()
