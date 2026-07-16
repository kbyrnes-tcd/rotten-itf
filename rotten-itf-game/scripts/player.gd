extends CharacterBody2D
# character sprites and audio
@onready var animated_sprite_2d: AnimatedSprite2D = $CharacterSprites/AnimatedSprite2D
@onready var jump_fx: AudioStreamPlayer2D = $JumpFX
# character and item sprites
@onready var character_sprites: Node2D = $CharacterSprites

# character equipment/items
@onready var lantern: Node2D = $CharacterSprites/Lantern
@onready var gun_sprite: Sprite2D = $CharacterSprites/GunSprite2D

@onready var gun: Node2D = $Gun
@onready var ray_cast_2d: RayCast2D = $Gun/RayCast2D
@onready var ray_line_2d: Line2D = $Gun/RayCast2D/RayLine2D

@onready var scene: Node2D = $".."
const ROT_VINE = preload("uid://kicj2478es6o")

# inventory system
@export var inv : Inventory

const SPEED = 150.0
const JUMP_VELOCITY = -650.0
var scale_x_transform = 1

# collecting items
func collect(item: InvItem):
	inv.insert(item)

func has(item: InvItem) -> bool:
	return inv.has(item);

# using items
func use(item: InvItem):
	inv.remove(item)

# de/activating lantern
func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		lantern.process_mode = Node.PROCESS_MODE_DISABLED if (lantern.process_mode == Node.PROCESS_MODE_INHERIT) else Node.PROCESS_MODE_INHERIT
		lantern.visible = false if (lantern.visible == true) else lantern.visible == false
	
	if Input.is_action_just_pressed("rot_extend"):
		gun.process_mode = Node.PROCESS_MODE_DISABLED if (gun.process_mode == Node.PROCESS_MODE_INHERIT) else Node.PROCESS_MODE_INHERIT
		gun.visible = false if (gun.visible == true) else gun.visible == false
		gun_sprite.visible = false if (gun_sprite.visible == true) else gun_sprite.visible == false

func add_vine(src, dest):
	print("inst @ " + str(src) + " & " + str(dest))
	var vine = ROT_VINE.instantiate()
	vine.get_child(0).points = PackedVector2Array([src, dest])
	scene.add_child(vine)

# handling movement
func _physics_process(delta: float) -> void:
	# RAYCASTING W/ ROT-GNUN
	# if the gun is activated, have it track mouse_pos
	if gun.process_mode == Node.PROCESS_MODE_INHERIT:
		var src = ray_cast_2d.global_position
		var mouse_pos = get_global_mouse_position()
		# to_local: convert global-space point into the node's own local coordinate space
		# accounting for pos, rotation, scale of all its ancestor nodes ...
		ray_cast_2d.target_position = ray_cast_2d.to_local(mouse_pos)
		
		ray_line_2d.points[1] = ray_cast_2d.target_position
#
		ray_cast_2d.force_raycast_update()
		if ray_cast_2d.is_colliding():
			var col_point = ray_cast_2d.to_local(ray_cast_2d.get_collision_point())
			ray_cast_2d.target_position = col_point
			ray_line_2d.points[1] = col_point
			if (Input.is_action_just_pressed("click") && ray_cast_2d.get_collider().name == "LineArea2D"):
				# need 2 be global point here
				var dest = ray_cast_2d.get_collision_point()
				call_deferred("add_vine", src, dest)

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
	if direction != 0:
		var facing = sign(direction)
		character_sprites.scale.x = facing * abs(character_sprites.scale.x)
		# mirror the gun node's starting pos
		gun.position.x = facing * abs(gun.position.x)
	
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#if (collision.get_collider().name != "Ground"):
			#print("Player collided with ", collision.get_collider().name)

func _on_area_2d_body_entered(body: Node2D) -> void:
	print('player detects: ' + body.name)
func _on_area_2d_body_exited(_body: Node2D) -> void:
	print("Exited!")
