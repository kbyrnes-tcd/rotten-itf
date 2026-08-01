#
#extends CharacterBody2D
## character sprites and audio
#@onready var animated_sprite_2d: AnimatedSprite2D = $CharacterSprites/AnimatedSprite2D
#@onready var jump_fx: AudioStreamPlayer2D = $JumpFX
## character and item sprites
#@onready var character_sprites: Node2D = $CharacterSprites
#
## character equipment/items
#@onready var lantern: Node2D = $CharacterSprites/Lantern
#@onready var gun_sprite: Sprite2D = $CharacterSprites/GunSprite2D
#
#@onready var gun: Node2D = $Gun
#@onready var ray_cast_2d: RayCast2D = $Gun/RayCast2D
#@onready var ray_line_2d: Line2D = $Gun/RayCast2D/RayLine2D
#
#@onready var scene: Node2D = $".."
#const ROT_VINE = preload("uid://kicj2478es6o")
#
## inventory system
#@export var inv : Inventory
#
#@export var SPEED = 150.0
#@export var JUMP_VELOCITY = -650.0
#var scale_x_transform = 1
#
##rot vine state of growth
#var active_vine = null
#var is_growing = false
##pixels per second
#const GROWTH_SPEED = 120.0
#
##gun/artifact state
#var gun_equipped := false
#
## collecting items
#func collect(item: InvItem):
	#inv.insert(item)
#
#func has(item: InvItem) -> bool:
	#return inv.has(item);
#
## using items
#func use(item: InvItem):
	#inv.remove(item)
#
##get direction from player - up,down,left,right
#func get_snapped_direction() -> Vector2:
	#var mouse_pos = get_global_mouse_position()
	#var diff = mouse_pos - global_position
	#
	##get angle to near 90 deg
	#var angle = diff.angle()
	#var snapped_angle = snappedf(angle, PI/2.0)
	#return Vector2(cos(snapped_angle), sin(snapped_angle)).round()
	#
##grow vine from player position in snapped direction
#func start_vine():
	#if is_growing:
		#print("is growing - ignore")
		#return
	#var dir = get_snapped_direction()
	#var src = global_position + dir * 40.0
	#
	##project wherever mouse cliked onto snapped direction
	#var mouse_pos = get_global_mouse_position()
	#var diff = mouse_pos - global_position
	#var projected_length = diff.dot(dir)
	#var target = global_position + dir * max(projected_length, 40.0)
	#
	##instantiate vine scene
	#var vine_instance = ROT_VINE.instantiate()
	#scene.add_child(vine_instance)
	#active_vine = vine_instance.get_child(0)
	##set initial two points - source is player position
	#active_vine.points = PackedVector2Array([
		#active_vine.to_local(src),
		#active_vine.to_local(src)
	#])
	#
	#is_growing = true
	##store direction of vine and target position
	#active_vine.set_meta("dir", dir)
	#active_vine.set_meta("src", src)
	#active_vine.set_meta("target", target)
	#print("vine started :3" + str(src) + "towards: " + str(target) + "going here" + str(dir))
	#
#func stop_vine():
	#if is_growing and active_vine:
		#active_vine.call_deferred("update_collisions")
	#is_growing = false
	#active_vine = null
	#
## de/activating lantern/gun: only one at a time
#func _process(_delta):
	#if Input.is_action_just_pressed("rot_cut"):
		#lantern.process_mode = Node.PROCESS_MODE_DISABLED if (lantern.process_mode == Node.PROCESS_MODE_INHERIT) else Node.PROCESS_MODE_INHERIT
		#lantern.visible = false if (lantern.visible == true) else lantern.visible == false
		#gun.process_mode = Node.PROCESS_MODE_DISABLED
		#gun.visible = false
		#gun_sprite.visible = false
		#
		#
	#if Input.is_action_just_pressed("rot_extend"):
		#gun.process_mode = Node.PROCESS_MODE_DISABLED if (gun.process_mode == Node.PROCESS_MODE_INHERIT) else Node.PROCESS_MODE_INHERIT
		#gun.visible = false if (gun.visible == true) else gun.visible == false
		#gun_sprite.visible = false if (gun_sprite.visible == true) else gun_sprite.visible == false
		#lantern.process_mode = Node.PROCESS_MODE_DISABLED
		#lantern.visible = false
		#start_vine()
	#if Input.is_action_just_released("rot_extend"):
		#gun.visible = false
		#gun_sprite.visible = false
		#stop_vine()
	##update preview line to show direction
	#if gun.process_mode == Node.PROCESS_MODE_INHERIT or gun.visible:
		#var dir = get_snapped_direction()
		#var preview_length = 200.0
		#ray_line_2d.points[1] = ray_cast_2d.to_local(
			#ray_cast_2d.global_position + dir * preview_length
		#)
		#
#func midpoint(src: Vector2, dest: Vector2):
	#return Vector2(src.x+dest.x, src.y+dest.y)/2
	#
#func add_vine(src: Vector2, dest: Vector2):
	##print("inst @ " + str(src) + " & " + str(dest))
	#var dist_scale : int = roundf(src.distance_to(dest)/70)
	##print(dist_scale)
	#
	#var vine = ROT_VINE.instantiate()
	#var vine_points : PackedVector2Array = PackedVector2Array([src, dest])
	#
	#var counter = 0
	## while: iterates over all passes necessary to segment points w/ dist_scale
	#while counter < dist_scale:
		#var vine_points_acc : PackedVector2Array = PackedVector2Array([vine_points[0]])
		## for: iterates over all points
		#for i in range(vine_points.size()-1):
			#var source = vine_points[i]
			#var desti = vine_points[i + 1]
			#var midp = midpoint(source, desti)
			#vine_points_acc.append(midp)
			#vine_points_acc.append(desti)
		#vine_points = vine_points_acc
		#counter += 1
	#
	#vine.get_child(0).points = vine_points
	#scene.add_child(vine)
#
## handling movement
#func _physics_process(delta: float) -> void:
	## RAYCASTING W/ ROT-GNUN
	## if the gun is activated, have it track mouse_pos
	##grow active vine each frame
	#if is_growing and active_vine:
		#var pts = active_vine.points
		##check for empty array
		#if pts.size() < 2:
			#return
		#var dir: Vector2 = active_vine.get_meta("dir")
		#var target: Vector2 = active_vine.get_meta("target")
		#var tip_local = pts[pts.size() - 1]
		#var tip_global = active_vine.to_global(tip_local)
		#var next_global = tip_global + dir * GROWTH_SPEED * delta
		#
		##check to stop growth on target
		#var dist_to_target = (target - tip_global).dot(dir)
		#if dist_to_target <= 0:
			#pts[pts.size() - 1] = active_vine.to_local(target)
			#active_vine.points = pts
			#stop_vine()
			#return
		#
		##collision check
		#var space_state = get_world_2d().direct_space_state
		#var params = PhysicsPointQueryParameters2D.new()
		#params.position = next_global
		#params.collide_with_bodies = true
		#params.collide_with_areas = false
		##exclude Daphne as collision
		#params.exclude = [get_rid()]
		##exlcude vine body
		#var result = space_state.intersect_point(params, 32)
		#
		#var hit_wall = false
		#for r in result: 
			##ignore vine itself
			#if active_vine.get_parent().has_node("LineStaticBody2D"):
				#if r.collider == active_vine.get_parent().get_node("LineStaticBody2D"):
					#continue
			#hit_wall = true
			#break
		#if hit_wall:
			##stop at wall
			#stop_vine()
		#else:
			##extend the tip
			#var new_pts: PackedVector2Array = PackedVector2Array(active_vine.points)
			#var last_fixed = active_vine.to_global(new_pts[new_pts.size() - 2])
			#var dist = last_fixed.distance_to(next_global)
			#
			#if dist >= 16.0:
				#new_pts.append(active_vine.to_local(next_global))
			#else:
				#new_pts[new_pts.size() - 1] = active_vine.to_local(next_global)
			#active_vine.points = new_pts
			#active_vine.call_deferred("update_collisions")
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
		#animated_sprite_2d.animation = "jump";
		#
	## Animating run
	#if velocity.x > 1 or velocity.x < -1:
		#animated_sprite_2d.animation = "run";
	#else:
		#animated_sprite_2d.animation = "idle";
#
	## Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY;
		#jump_fx.play();
#
	## Get the input direction and handle the movement/deceleration.
	#var direction := Input.get_axis("left", "right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	## handles collision and etc.
	#move_and_slide()
	#
	## handle sprite direction
	#if direction != 0:
		#var facing = sign(direction)
		#character_sprites.scale.x = facing * abs(character_sprites.scale.x)
		## mirror the gun node's starting pos
		#gun.position.x = facing * abs(gun.position.x)
	#
	##for i in get_slide_collision_count():
		##var collision = get_slide_collision(i)
		##if (collision.get_collider().name != "Ground"):
			##print("Player collided with ", collision.get_collider().name)
#
#func _on_area_2d_body_entered(body: Node2D) -> void:
	#print('player detects: ' + body.name)
#func _on_area_2d_body_exited(_body: Node2D) -> void:
	#print("Exited!")

	

extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $CharacterSprites/AnimatedSprite2D
@onready var jump_fx: AudioStreamPlayer2D = $JumpFX
@onready var character_sprites: Node2D = $CharacterSprites
@onready var lantern: Node2D = $CharacterSprites/Lantern
@onready var gun_sprite: Sprite2D = $CharacterSprites/GunSprite2D
@onready var gun: Node2D = $Gun
@onready var ray_cast_2d: RayCast2D = $Gun/RayCast2D
@onready var ray_line_2d: Line2D = $Gun/RayCast2D/RayLine2D
@onready var scene: Node2D = $".."

const ROT_VINE = preload("uid://kicj2478es6o")
const GROWTH_SPEED = 120.0
const GLOWWORM = preload("res://scripts/inventory_system/items/orange_worm.tres")
const GLOWWORM_MAX = 5
const USE_INTERVAL = 2.0

@export var inv: Inventory
@export var SPEED = 150.0
@export var JUMP_VELOCITY = -650.0

# Enums and state variables
enum ToolState { IDLE, LANTERN_ON, LANTERN_EQUIPPED, GUN_EQUIPPED, GUN_ON }
#enum MoveState { IDLE, RUNNING, JUMPING, FALLING }

var tool_state = ToolState.IDLE
#var move_state = MoveState.IDLE

var active_vine = null
var is_growing = false

var glowworm_uses = 0
var use_timer = 0.0

func collect(item: InvItem):
	inv.insert(item)

func has(item: InvItem) -> bool:
	return inv.has(item)

func use(item: InvItem):
	inv.remove(item)
	
func _ready():
	#gun starts hidden and disabled
	gun.visible = false
	gun_sprite.visible = false
	gun.process_mode = Node.PROCESS_MODE_DISABLED
	#lantern starts hidden and disabled  
	lantern.visible = false
	lantern.process_mode = Node.PROCESS_MODE_DISABLED
	#light starts off
	var light = lantern.get_node_or_null("PointLight2D")
	if light:
		light.enabled = false
	
func get_snapped_direction() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	var diff = mouse_pos - global_position
	var angle = diff.angle()
	var snapped_angle = snappedf(angle, PI / 2.0)
	return Vector2(cos(snapped_angle), sin(snapped_angle)).round()

func start_vine():
	if is_growing:
		return
	var dir = get_snapped_direction()
	var src = global_position + dir * 40.0
	var mouse_pos = get_global_mouse_position()
	var diff = mouse_pos - global_position
	var projected_length = diff.dot(dir)
	var target = global_position + dir * max(projected_length, 40.0)
	var vine_instance = ROT_VINE.instantiate()
	scene.add_child(vine_instance)
	active_vine = vine_instance.get_child(0)
	print(active_vine.position)
	print(active_vine.global_position)
	active_vine.points = PackedVector2Array([
		active_vine.to_local(src),
		active_vine.to_local(src)
	])
	is_growing = true
	active_vine.set_meta("dir", dir)
	active_vine.set_meta("src", src)
	active_vine.set_meta("target", target)
	print("vine started from " + str(src) + " toward " + str(target))
	print("dir: " + str(dir) + " mouse: " + str(get_global_mouse_position()) + " player: " + str(global_position))

func stop_vine():
	if is_growing and active_vine:
		active_vine.call_deferred("update_collisions")
	is_growing = false
	active_vine = null

func midpoint(src: Vector2, dest: Vector2) -> Vector2:
	return Vector2(src.x + dest.x, src.y + dest.y) / 2

func add_vine(src: Vector2, dest: Vector2):
	var dist_scale: int = roundf(src.distance_to(dest) / 70)
	var vine = ROT_VINE.instantiate()
	var vine_points: PackedVector2Array = PackedVector2Array([src, dest])
	var counter = 0
	while counter < dist_scale:
		var vine_points_acc: PackedVector2Array = PackedVector2Array([vine_points[0]])
		for i in range(vine_points.size() - 1):
			var source = vine_points[i]
			var desti = vine_points[i + 1]
			vine_points_acc.append(midpoint(source, desti))
			vine_points_acc.append(desti)
		vine_points = vine_points_acc
		counter += 1
	vine.get_child(0).points = vine_points
	scene.add_child(vine)

#lantern visuals
func update_lantern_visuals():
	var life_ratio = float(glowworm_uses)/float(GLOWWORM_MAX)
	lantern.modulate.a = lerp(0., 1.0, life_ratio)
	var light = lantern.get_node_or_null("PointLight2D")
	if light:
		light.texture_scale = lerp(0.3, 1.0, life_ratio)
		light.energy = lerp(0.3, 1.5, life_ratio)

func activate_light():
	var light = lantern.get_node_or_null("PointLight2D")
	if light:
		light.enabled = true

func deactivate_light():
	var light = lantern.get_node_or_null("PointLight2D")
	if light:
		light.enabled = false
		
#change tool state
func change_tool_state(new_state: ToolState):
	print("tool: " + str(tool_state) + "to " + str(new_state))
	#exit current state
	match tool_state:
		ToolState.LANTERN_EQUIPPED: 
			lantern.visible = false
			lantern.process_mode = Node.PROCESS_MODE_DISABLED
			lantern.modulate.a = 1.0
		ToolState.LANTERN_ON:
			deactivate_light()
			lantern.visible = false
			lantern.process_mode = Node.PROCESS_MODE_DISABLED
			lantern.modulate.a = 1.0
		ToolState.GUN_EQUIPPED:
			gun.visible = false
			gun_sprite.visible = false
			gun.process_mode = Node.PROCESS_MODE_DISABLED
		ToolState.GUN_ON:
			gun.visible = false
			gun_sprite.visible = false
			gun.process_mode = Node.PROCESS_MODE_DISABLED
			if is_growing:
				stop_vine()
	tool_state = new_state
	#enter new state
	match new_state:
		ToolState.IDLE:
			pass
		ToolState.LANTERN_EQUIPPED:
			lantern.visible = true
			lantern.process_mode = Node.PROCESS_MODE_INHERIT
			if glowworm_uses <= 0:
				glowworm_uses = GLOWWORM_MAX
				use_timer = 0.0
			update_lantern_visuals()
		ToolState.LANTERN_ON:
			lantern.visible = true
			lantern.process_mode = Node.PROCESS_MODE_INHERIT
			activate_light()
		ToolState.GUN_EQUIPPED:
			gun.visible = true
			gun_sprite.visible = true
			gun.process_mode = Node.PROCESS_MODE_INHERIT
		ToolState.GUN_ON:
			pass


#tool input
func _process(delta):
	match tool_state:
		ToolState.IDLE:
			_tool_idle()
		ToolState.LANTERN_EQUIPPED:
			_tool_lantern_equipped()
		ToolState.LANTERN_ON:
			_tool_lantern_on(delta)
		ToolState.GUN_EQUIPPED:
			_tool_gun_equipped()
		ToolState.GUN_ON:
			_tool_gun_on()

func _tool_idle():
	if Input.is_action_just_pressed("rot_cut"):
		if inv.has(GLOWWORM):
			change_tool_state(ToolState.LANTERN_EQUIPPED)
		else:
			print("no glowworms! WOMP WOMP")
	if Input.is_action_just_pressed("equip_rot"):
		change_tool_state(ToolState.GUN_EQUIPPED)

func _tool_lantern_equipped(): 
	if Input.is_action_just_pressed("rot_cut"):
		change_tool_state(ToolState.IDLE)
		return
	if Input.is_action_just_pressed("equip_rot"):
		change_tool_state(ToolState.GUN_EQUIPPED)
		return
	if Input.is_action_pressed("lantern_toggle"):
		change_tool_state(ToolState.LANTERN_ON)
	
func _tool_lantern_on(delta: float):
	if Input.is_action_pressed("lantern_toggle"):
		change_tool_state(ToolState.LANTERN_EQUIPPED)
		return
	if Input.is_action_just_pressed("rot_cut"):
		change_tool_state(ToolState.IDLE)
		return
	
	#decay of the glowworms with every use -- amount of times one glowworm is used
	use_timer += delta
	if use_timer >= USE_INTERVAL:
		use_timer = 0.0
		glowworm_uses -= 1
		update_lantern_visuals()
		print("glowworms uses left: " + str(glowworm_uses))
		if glowworm_uses <= 0:
			inv.remove(GLOWWORM)
			print("glowworm used")
			if inv.has(GLOWWORM):
				glowworm_uses = GLOWWORM_MAX
				use_timer = 0.0
				print("next glowworm loaded")
			else:
				print("out of glowworms")
				change_tool_state(ToolState.IDLE)

func _tool_gun_equipped():
	if Input.is_action_just_pressed("equip_rot"):
		change_tool_state(ToolState.IDLE)
		return
	if Input.is_action_just_pressed("rot_cut"):
		if inv.has(GLOWWORM):
			change_tool_state(ToolState.LANTERN_EQUIPPED)
		else:
			print("no glowworms! WOMP WOMP")
		return
	if Input.is_action_just_pressed("rot_extend") and not is_growing:
		start_vine()
		change_tool_state(ToolState.GUN_ON)
		return
	ray_cast_2d.force_raycast_update()
	var dir = get_snapped_direction()
	ray_line_2d.points[1] = ray_cast_2d.to_local(
		ray_cast_2d.global_position + dir * 200.0
	)

func _tool_gun_on():
	if not is_growing:
		change_tool_state(ToolState.GUN_EQUIPPED)
		return
	if Input.is_action_just_pressed("equip_rot"):
		stop_vine()
		change_tool_state(ToolState.IDLE)
		return
	var dir = get_snapped_direction()
	ray_line_2d.points[1] = ray_cast_2d.to_local(
		ray_cast_2d.global_position + dir * 200.0
	)
#func _process(_delta):
	##W toggles lantern
	#if Input.is_action_just_pressed("rot_cut"):
		#if tool_state == ToolState.LANTERN_ON:
			#change_tool_state(ToolState.IDLE)
		#else:
			#change_tool_state(ToolState.LANTERN_ON)
#
	##Q toggles gun
	#if Input.is_action_just_pressed("equip_rot"):
		#if tool_state == ToolState.GUN_ON:
			#change_tool_state(ToolState.IDLE)
		#else:
			#change_tool_state(ToolState.GUN_ON)
#
	##fires rot only when gun is on
	#if Input.is_action_just_pressed("rot_extend") and tool_state == ToolState.GUN_ON and not is_growing:
		#start_vine()
#
	##release stops rot shooting
	#if Input.is_action_just_released("rot_extend"):
		#if is_growing:
			#stop_vine()
#
	#if tool_state == ToolState.GUN_ON:
		#var dir = get_snapped_direction()
		#ray_cast_2d.force_raycast_update()
		#ray_line_2d.points[1] = ray_cast_2d.to_local(
			#ray_cast_2d.global_position + dir * 200.0
		#)

func _handle_vine_growth(delta: float):
	if not is_growing or not active_vine:
		return
	var pts = active_vine.points
	if pts.size() < 2:
		return
	var dir: Vector2 = active_vine.get_meta("dir")
	var target: Vector2 = active_vine.get_meta("target")
	var tip_local = pts[pts.size() - 1]
	var tip_global = active_vine.to_global(tip_local)
	var next_global = tip_global + dir * GROWTH_SPEED * delta
	var dist_to_target = (target - tip_global).dot(dir)
	if dist_to_target <= 0:
		pts[pts.size() - 1] = active_vine.to_local(target)
		active_vine.points = pts
		stop_vine()
		return
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = next_global
	params.collide_with_bodies = true
	params.collide_with_areas = false
	params.exclude = [get_rid()]
	var result = space_state.intersect_point(params, 32)
	var hit_wall = false
	for r in result:
		print(r.collider)
		if active_vine.get_parent().has_node("LineStaticBody2D"):
			if r.collider == active_vine.get_parent().get_node("LineStaticBody2D"):
				continue
		hit_wall = true
		break
	print(result)
	if hit_wall:
		stop_vine()
	else:
		var new_pts: PackedVector2Array = PackedVector2Array(active_vine.points)
		var last_fixed = active_vine.to_global(new_pts[new_pts.size() - 2])
		var dist = last_fixed.distance_to(next_global)
		if dist >= 16.0:
			new_pts.append(active_vine.to_local(next_global))
		else:
			new_pts[new_pts.size() - 1] = active_vine.to_local(next_global)
		active_vine.points = new_pts
		active_vine.call_deferred("update_collisions")
	print("Growing")
	print("tip:", tip_global)
	print("next:", next_global)
	print("target:", target)
	print("dist:", dist_to_target)

func _handle_movement(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite_2d.animation = "jump"
	if velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "run"
	else:
		animated_sprite_2d.animation = "idle"
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_fx.play()
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _handle_sprite_direction():
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		var facing = sign(direction)
		character_sprites.scale.x = facing * abs(character_sprites.scale.x)
		gun.position.x = facing * abs(gun.position.x)

func _physics_process(delta: float):
	_handle_vine_growth(delta)
	_handle_movement(delta)
	move_and_slide()
	_handle_sprite_direction()

func _on_area_2d_body_entered(body: Node2D) -> void:
	print('player detects: ' + body.name)

func _on_area_2d_body_exited(_body: Node2D) -> void:
	print("Exited!")
