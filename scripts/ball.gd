extends Area2D

# EXPORT
@export var fall_speed := 750.0
@export var rain_angle: float = 30.0

# PRIVATE
var rain_velocity := Vector2.ZERO

func _ready():
	# Only connect signal if needed
	body_entered.connect(_on_body_entered)
	
	# Pre-calculate velocity if not set externally
	if rain_velocity == Vector2.ZERO:
		var angle_rad = deg_to_rad(rain_angle)
		rain_velocity = Vector2(
			fall_speed * sin(angle_rad),
			fall_speed * cos(angle_rad)
		)

func _physics_process(delta):
	# Simple position update - no extra calculations
	position += rain_velocity * delta

func set_rain_velocity(vel: Vector2):
	rain_velocity = vel

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("die"):
			body.die()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
