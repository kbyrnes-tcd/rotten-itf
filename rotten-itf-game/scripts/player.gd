extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_fx: AudioStreamPlayer2D = $JumpFX

const SPEED = 300.0
const JUMP_VELOCITY = -850.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite_2d.animation = "jump";
		
	# Animating run
	if velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "run";
	else:
		animated_sprite_2d.animation = "idle";

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY;
		jump_fx.play();

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# handles collision and etc.
	move_and_slide()
	
	# handle sprite direction
	if direction == 1.0: # right
		animated_sprite_2d.flip_h = false;
	elif direction == -1.0: # left
		animated_sprite_2d.flip_h = true;

	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#if (collision.get_collider().name != "Ground"):
			#print("Player collided with ", collision.get_collider().name)

#func _on_area_2d_body_entered(body: Node2D) -> void:
	#print("Entered!")
	#print(body)

#func _on_area_2d_body_exited(body: Node2D) -> void:
	#print("Exited!")
