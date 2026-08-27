extends CharacterBody2D
class_name Player

# Player equipment in scene, animation and SFX data
@onready var animated_sprite_2d: AnimatedSprite2D = $CharacterSprites/AnimatedSprite2D
@onready var jump_fx: AudioStreamPlayer2D = $JumpFX
@onready var character_sprites: Node2D = $CharacterSprites
@onready var lantern: Node2D = $CharacterSprites/Lantern
@onready var gun_sprite: Sprite2D = $CharacterSprites/GunSprite2D
@onready var gun: Node2D = $Gun
@onready var ray_cast_2d: RayCast2D = $Gun/RayCast2D
@onready var ray_line_2d: Line2D = $Gun/RayCast2D/RayLine2D
@onready var scene: Node2D = $".."
@onready var worm_hud = $CanvasLayer/WormHUD
@onready var segment_container = $CanvasLayer/WormHUD/SegmentContainer

# Rot and Glowworm data
const ROT_VINE = preload("uid://kicj2478es6o")
const GROWTH_SPEED = 120.0
const GLOWWORM = preload("res://scripts/inventory_system/items/glow_worm.tres")
const LANTERN = preload("uid://gpvtv23ln3ds")
const AMULET = preload("uid://bcvemp5c8igqs")
const GLOWWORM_MAX = 5
const USE_INTERVAL = 2.0
var active_vine = null
var is_growing = false

# Glowworm HUD data
var glowworm_uses = GLOWWORM_MAX
var use_timer = 0.0
var worm_in_use: bool = false
var segments: Array = []

# Drag and drop player inv, set player speed/jump params
@export var inv: Inventory
var target_speed:= -1.0
@export var NORMAL_SPEED := 165.0
#@export var NORMAL_SPEED := 850.0
@export var STEP_SPEED := 100.0
const ACCELERATION := 800.0
@export var FULL_JUMP_VELOCITY = -650.0
@export var MID_JUMP_VELOCITY = -500.0
var STEP_JUMP_VELOCITY := -250
@export var foot_marker : Marker2D

# Enums and state variables
enum ToolState { IDLE, LANTERN_ON, LANTERN_EQUIPPED, GUN_EQUIPPED, GUN_ON }
enum MoveState { IDLE, WALKING, JUMPING, FALLING }

var tool_state = ToolState.IDLE
var move_state = MoveState.IDLE

func _ready():
	add_to_group("player")
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
	build_worm_segments()
	set_collision_mask_value(2, true)  #setting here so all instances of player are config to have steps/one-way col.s in mask layer

# Tool FSM
func _process(delta):
	match tool_state:
		ToolState.IDLE:
			_tool_idle()
		ToolState.LANTERN_EQUIPPED:
			if self.has(LANTERN): _tool_lantern_equipped()
		ToolState.LANTERN_ON:
			_tool_lantern_on(delta)
		ToolState.GUN_EQUIPPED:
			if self.has(AMULET): _tool_gun_equipped()
		ToolState.GUN_ON:
			_tool_gun_on()
			
func get_tool_state():
	return tool_state

var can_step := false
func _physics_process(delta: float):
	_handle_animation()
	_handle_vine_growth(delta)
	move_and_slide()
	can_step = can_step_up() # for changing speeds correctly
	_handle_movement(delta)
	_handle_sprite_direction()

var persephone := false
var transformed := false
var transforming := false
func _handle_animation():
	if transforming: return
	# fade and transforn INTO P
	if persephone and !transformed:
		transforming = true
		await transform_self(true)
		transformed = true
		transforming = false
		return
	# fade and transforn INTO !P AKA Daphne
	if !persephone and transformed:
		transforming = true
		await transform_self(false)
		transformed = false
		transforming = false
		return
	animated_sprite_2d.animation = get_anim_for(transformed)

func transform_self(to_persephone: bool) -> void:
	var target_anim := get_anim_for(to_persephone)
	var fade_char := create_tween()
	fade_char.tween_property(animated_sprite_2d, "modulate:a", 0.0, 1.0)
	fade_char.tween_callback(func(): animated_sprite_2d.animation = target_anim)
	fade_char.tween_property(animated_sprite_2d, "modulate:a", 1.0, 1.0)
	await fade_char.finished

func get_anim_for(is_persephone: bool) -> String:
	if is_persephone: return "p_walk" if move_state == MoveState.WALKING else "p_idle"
	else:
		if move_state == MoveState.IDLE:
			return "idle" if tool_state == ToolState.IDLE else "idle_equipped"
		else:
			return "walk" if tool_state == ToolState.IDLE else "walk_equipped"

func _on_transform_to_p_body_entered(body: Node2D) -> void:
	# when player enters transform to Persephone area in underworld scene
	if body.name == "Player" and !persephone:
		persephone = true
		GameGlobals.player.inv.clear()

func _on_transform_to_d_body_entered(body: Node2D) -> void:
	# when player enters transform to Daphne area in scene_06_copy scene
	if body.name == "Player" and persephone:
		persephone = false

var step_target_y := 0.0
func can_step_up() -> bool:
	step_target_y = 0.0
	var collider; var shape_index; var owner_id; var shape_node;
	$StepJumpRayCastL.force_raycast_update()
	$StepJumpRayCastR.force_raycast_update()
	for foot in [$StepJumpRayCastL, $StepJumpRayCastR]:
		#var lorr = foot.name.substr(foot.name.length() - 1, 1)
		if foot.is_colliding():
			collider = foot.get_collider()
			shape_index = foot.get_collider_shape()
			owner_id = collider.shape_find_owner(shape_index)
			shape_node = collider.shape_owner_get_owner(owner_id)
			if (shape_node is CollisionShape2D or shape_node is CollisionPolygon2D) and shape_node.one_way_collision:
				#print("%s foot is colliding with %s" %[lorr, shape_node.name])
				if step_target_y < foot_marker.global_position.y:
					step_target_y = foot.get_collision_point().y
					return true
	return false

func can_i_jump() -> Dictionary:
	var jump_data := {
		"can_jump": is_on_floor(), 
		"jump_velocity": FULL_JUMP_VELOCITY if !$FullJumpRayCast.is_colliding() else MID_JUMP_VELOCITY if !$MidJumpRayCast.is_colliding() else 0.0
			}

	$FullJumpRayCast.force_raycast_update()
	$MidJumpRayCast.force_raycast_update()
	# need to check that raycast isnt rejecting the one-way collider platforms
	if jump_data["jump_velocity"] == 0.0:
		if $FullJumpRayCast.is_colliding() and $FullJumpRayCast.get_collider().is_shape_owner_one_way_collision_enabled(0):
			jump_data["jump_velocity"] = FULL_JUMP_VELOCITY
		elif $MidJumpRayCast.is_colliding() and $MidJumpRayCast.get_collider().is_shape_owner_one_way_collision_enabled(0):
			jump_data["jump_velocity"] = MID_JUMP_VELOCITY
	return jump_data

var is_dropping := false
var was_walking := false

func _handle_movement(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta
		#animated_sprite_2d.animation = "jump" # keeping jump anim call here as it is a single sprite render
		move_state = MoveState.FALLING
	else:
		move_state = MoveState.IDLE
		
	if velocity.x > 1 or velocity.x < -1:
		move_state = MoveState.WALKING
		if not was_walking:
			AudioManager.play_walk_fx()
		was_walking = true
	else:
		if was_walking:
			AudioManager.stop_walk_fx()
		was_walking = false
		move_state = MoveState.IDLE
	
	var jump_state := can_i_jump()
	#if jump_state["jump_velocity"] == 0.0: return
	
	# STEP UP TAKES PRIORITY
	if can_step and Input.is_action_just_pressed("jump"):
		velocity.y = STEP_JUMP_VELOCITY
		move_state = MoveState.JUMPING
		AudioManager.play_os("jump")
	elif can_step and Input.is_action_pressed("jump") and on_step:
		velocity.y = STEP_JUMP_VELOCITY
		move_state = MoveState.JUMPING
		AudioManager.play_os("jump")
	
	if Input.is_action_just_pressed("jump") and jump_state["can_jump"]:
		velocity.y = jump_state["jump_velocity"]
		move_state = MoveState.JUMPING
		AudioManager.play_os("jump")
		
	# STEPPING DOWN
	if on_step and Input.is_action_just_pressed("down") and not is_dropping:
		is_dropping = true
		set_collision_mask_value(2, false)
		await get_tree().create_timer(0.2).timeout
		set_collision_mask_value(2, true)
		is_dropping = false

	# OG MOVEMENT
	#if direction:
		#velocity.x = direction * NORMAL_SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, NORMAL_SPEED)
		
	# SPEED CONTROLLED STEPPINGGG
	var direction := Input.get_axis("left", "right")
	# literal smooth stepping, lerp speed down
	if on_step:
		var remaining: float = abs(step_target_y - foot_marker.global_position.y)
		var step_heigh := 10.0
		var t: float = clamp(remaining / step_heigh, 0.0, 1.0)  # 1 = just started, 0 = arrived
		var stepping_speed: float = lerp(NORMAL_SPEED, STEP_SPEED, t)
		target_speed = stepping_speed
		velocity.x = move_toward(velocity.x, direction * stepping_speed, ACCELERATION * delta)
	else:
		target_speed = NORMAL_SPEED
		velocity.x = move_toward(velocity.x, direction * NORMAL_SPEED, ACCELERATION * delta)

func _handle_sprite_direction():
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		var facing = sign(direction)
		character_sprites.scale.x = facing * abs(character_sprites.scale.x)
		gun.position.x = facing * abs(gun.position.x)

# INVENTORY FUNCTIONS
func collect(item: InvItem):
	inv.insert(item)

func has(item: InvItem) -> bool:
	return inv.has(item)

func use(item: InvItem):
	inv.remove(item)

# to avoid other wall lanterns, etc to take worm from handheld lantern
func can_take_item(item: InvItem) -> bool:
	if item == GLOWWORM and worm_in_use:
		return false
	return true
	
# ROT GROWTH AND MOUSE-INTERACTION
func get_snapped_direction() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	if mouse_pos.x >= global_position.x:
		return Vector2.RIGHT
	else:
		return Vector2.LEFT
	#var diff = mouse_pos - global_position
	#var angle = diff.angle()
	#var snapped_angle = snappedf(angle, PI / 2.0)
	#return Vector2(cos(snapped_angle), sin(snapped_angle)).round()

func start_vine():
	if is_growing:
		return
	if not GameGlobals.first_rot_shot:
		GameGlobals.first_rot_shot = true
		var lio = get_tree().get_first_node_in_group("lio_manager")
		if lio:
			lio.show_sequence([
				"Oh, Goddess… the rot is growing…",
				"The High Priestess said I must use this rot, but… why?",
				"This rotten substance… I too shall honor my deal with you, High Priestess. ",
				"This power to grow the rot, I must be careful with it. I don’t know what effects it’ll have on this place.",
				"Or on me."
			])
	var dir = get_snapped_direction()
	var src = gun_sprite.global_position + dir * 10.0

	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = src
	params.collide_with_bodies = true
	params.collide_with_areas = false
	var result = space_state.intersect_point(params, 32)
	for r in result:
		if r.collider == self: return # BLOCKEDD do not grow towards player

	var mouse_pos = get_global_mouse_position()
	var diff = mouse_pos - gun_sprite.global_position
	var projected_length = diff.dot(dir)
	var target = gun_sprite.global_position + dir * max(projected_length, 40.0)
	var vine_instance = ROT_VINE.instantiate()
	vine_instance.name = "Vine_%d" % Time.get_ticks_usec()
	scene.add_child(vine_instance)
	
	#print("since i am adding rot to this scene i should add this to the persist node")
	var p_data : PersistentData = GameGlobals.get_current_tree_p_data()
	if p_data:
		p_data.add_spawned_obj(vine_instance, ROT_VINE)
	#print(p_data.object_names)

	active_vine = vine_instance.get_child(0)
	active_vine.points = PackedVector2Array([
		active_vine.to_local(src),
		active_vine.to_local(src)
	])
	is_growing = true
	active_vine.set_meta("dir", dir)
	active_vine.set_meta("src", src)
	active_vine.set_meta("target", target)

func stop_vine():
	if is_growing and active_vine:
		active_vine.set_rest_shape()
		active_vine.call_deferred("update_collisions")
	is_growing = false
	active_vine = null
	AudioManager.stop_fx()

func midpoint(src: Vector2, dest: Vector2) -> Vector2:
	return Vector2(src.x + dest.x, src.y + dest.y) / 2

#func add_vine(src: Vector2, dest: Vector2):
	#var dist_scale = roundf(src.distance_to(dest) / 70)
	#var vine = ROT_VINE.instantiate()
	#var vine_points: PackedVector2Array = PackedVector2Array([src, dest])
	#var counter = 0
	#while counter < dist_scale:
		#var vine_points_acc: PackedVector2Array = PackedVector2Array([vine_points[0]])
		#for i in range(vine_points.size() - 1):
			#var source = vine_points[i]
			#var desti = vine_points[i + 1]
			#vine_points_acc.append(midpoint(source, desti))
			#vine_points_acc.append(desti)
		#vine_points = vine_points_acc
		#counter += 1
	#vine.get_child(0).points = vine_points
	#scene.add_child(vine)

# CHANGING TOOL STATE, visuals
func change_tool_state(new_state: ToolState):
	#print("tool: " + str(tool_state) + "to " + str(new_state))
	#exit current state
	match tool_state:
		ToolState.LANTERN_EQUIPPED: 
			lantern.visible = false
			#worm_in_use = false
			worm_hud.visible = false
			lantern.process_mode = Node.PROCESS_MODE_DISABLED
			#lantern.modulate.a = 1.0
			var area = lantern.get_node_or_null("LanternArea2D")
			if area:
				area.monitoring = false
				area.monitorable = false
		ToolState.LANTERN_ON:
			deactivate_light()
			worm_in_use = false
			worm_hud.visible = false
			lantern.visible = false
			lantern.process_mode = Node.PROCESS_MODE_DISABLED
			#lantern.modulate.a = 1.0
			var area = lantern.get_node_or_null("LanternArea2D")
			if area:
				area.monitoring = false
				area.monitorable = false
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
			if self.has(LANTERN):
				lantern.visible = true
				lantern.process_mode = Node.PROCESS_MODE_INHERIT
				#worm_in_use = true
				var area = lantern.get_node_or_null("LanternArea2D")
				if area:
					area.monitoring = false
					area.monitorable = false
				update_lantern_visuals()
			#lantern.modulate.a = 0.3
		ToolState.LANTERN_ON:
			lantern.visible = true
			lantern.process_mode = Node.PROCESS_MODE_INHERIT
			worm_in_use = true
			worm_hud.visible = true
			update_worm_segments()
			if inv.has(GLOWWORM) and glowworm_uses <= 0:
				glowworm_uses = GLOWWORM_MAX
				use_timer = 0.0
			if inv.has(GLOWWORM):
				activate_light()
			#else: 
				#lantern.modulate.a = 0.3
		ToolState.GUN_EQUIPPED:
			if self.has(AMULET):
				gun.visible = true
				gun_sprite.visible = true
				gun.process_mode = Node.PROCESS_MODE_INHERIT
		ToolState.GUN_ON:
			pass

# TOOL FSM functions
func _tool_idle():
	if Input.is_action_just_pressed("rot_cut") and self.has(LANTERN):
		AudioManager.play_os("equip")
		change_tool_state(ToolState.LANTERN_EQUIPPED)
	if Input.is_action_just_pressed("equip_rot") and self.has(AMULET):
		AudioManager.play_os("equip")
		change_tool_state(ToolState.GUN_EQUIPPED)

func _tool_lantern_equipped(): 
	if !self.has(LANTERN):
		change_tool_state(ToolState.IDLE)
		return
	if Input.is_action_just_pressed("rot_cut"):
		change_tool_state(ToolState.IDLE)
		return
	if Input.is_action_just_pressed("equip_rot") and self.has(AMULET):
		change_tool_state(ToolState.GUN_EQUIPPED)
		return
	if Input.is_action_pressed("lantern_toggle"):
		if inv.has(GLOWWORM):
			change_tool_state(ToolState.LANTERN_ON)
		#else:
			#print("no glowworms! WOMP WOMP")
	
func _tool_lantern_on(delta: float):
	if Input.is_action_just_released("lantern_toggle"):
		change_tool_state(ToolState.LANTERN_EQUIPPED)
		AudioManager.stop_fx()
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
		#print("glowworms uses left: " + str(glowworm_uses))
		if glowworm_uses <= 0:
			inv.remove(GLOWWORM)
			AudioManager.stop_fx()
			#print("glowworm used")
			if inv.has(GLOWWORM):
				glowworm_uses = GLOWWORM_MAX
				use_timer = 0.0
				#print("next glowworm loaded")
			else:
				#print("out of glowworms")
				change_tool_state(ToolState.LANTERN_EQUIPPED)

func _tool_gun_equipped():
	if !self.has(AMULET):
		change_tool_state(ToolState.IDLE)
		return
	if Input.is_action_just_pressed("equip_rot"):
		change_tool_state(ToolState.IDLE)
		return
	if Input.is_action_just_pressed("rot_cut") and self.has(LANTERN):
		change_tool_state(ToolState.LANTERN_EQUIPPED)
		return
	if Input.is_action_just_pressed("rot_extend") and not is_growing:
		AudioManager.play_fx("grow")
		start_vine()
		change_tool_state(ToolState.GUN_ON)
		return
	ray_cast_2d.force_raycast_update()
	var dir = get_snapped_direction()
	var _pts = ray_line_2d.points
	_pts[1] = ray_cast_2d.to_local(
		ray_cast_2d.global_position + dir * 100.0
	)
	ray_line_2d.points = _pts

func _tool_gun_on():
	if not is_growing:
		change_tool_state(ToolState.GUN_EQUIPPED)
		return
	if Input.is_action_just_pressed("equip_rot"):
		stop_vine()
		change_tool_state(ToolState.IDLE)
		return
	var dir = get_snapped_direction()
	var _pts = ray_line_2d.points
	_pts[1] = ray_cast_2d.to_local(
		ray_cast_2d.global_position + dir * 100.0
	)
	ray_line_2d.points = _pts

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
	
	var result = space_state.intersect_point(params, 32)
	var hit_wall = false
	for r in result:
		# ignore hitting the vine itself extending
		if active_vine.get_parent().has_node("LineStaticBody2D"):
			if r.collider == active_vine.get_parent().get_node("LineStaticBody2D"):
				continue
		# prevent growing the vine inwards the player's collider
		if r.collider == self:
			#print("hit player!!")
			hit_wall = true
			break
		hit_wall = true
		break
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
	#print("Growing")
	#print("tip:", tip_global)
	#print("next:", next_global)
	#print("target:", target)
	#print("dist:", dist_to_target)

# LANTERN VISUALS
func update_lantern_visuals():
	var life_ratio = float(glowworm_uses)/float(GLOWWORM_MAX)
	#lantern.modulate.a = lerp(0., 1.0, life_ratio)
	update_worm_segments()
	var light = lantern.get_node_or_null("PointLight2D")
	if light:
		light.texture_scale = lerp(0.3, 1.0, life_ratio)
		light.energy = lerp(0.3, 0.9, life_ratio)

func activate_light():
	worm_in_use = true
	var light = lantern.get_node_or_null("PointLight2D")
	if light:
		light.enabled = true
	var area = lantern.get_node_or_null("LanternArea2D")
	if area:
		area.monitoring = true
		area.monitorable = true

func deactivate_light():
	var light = lantern.get_node_or_null("PointLight2D")
	if light:
		light.enabled = false
	var area = lantern.get_node_or_null("LanternArea2D")
	if area:
		area.monitoring = false
		area.monitorable = false

# WORM VISUALS
func build_worm_segments():
	for child in segment_container.get_children():
		child.queue_free()
	segments.clear()
	#create rect per number of uses
	for i in GLOWWORM_MAX:
		var rect = ColorRect.new()
		rect.custom_minimum_size = Vector2(6,6)
		segment_container.add_child(rect)
		segments.append(rect)
	update_worm_segments()
	
func update_worm_segments():
	for i in segments.size():
		if i < glowworm_uses:
			segments[i].color = Color("#a1f6fa")
		else:
			segments[i].color = Color("#292929")

# FOR DETECTING WHETHER PLAYER IS ACTIVELY ON A STEP--FOR GOING DOWN
var on_step := false
func _feet_area_shape_entered(_area_rid: RID, body: Node2D, body_shape_index: int, _local_shape_index: int) -> void:
	if !body is PhysicsBody2D: return
	if !is_instance_valid(body): return
	if body.get_shape_owners().is_empty(): return
	var owner_id = body.shape_find_owner(body_shape_index)
	if owner_id == -1: return
	var shape_node = body.shape_owner_get_owner(owner_id)
	if shape_node and shape_node.one_way_collision:
		on_step = true

func _feet_area_shape_exited(_area_rid: RID, body: Node2D, body_shape_index: int, _local_shape_index: int) -> void:
	if !body is PhysicsBody2D: return
	if !is_instance_valid(body): return
	if body.get_shape_owners().is_empty(): return
	var owner_id = body.shape_find_owner(body_shape_index)
	if owner_id == -1: return
	var shape_node = body.shape_owner_get_owner(owner_id)
	if shape_node and shape_node.one_way_collision:
		on_step = false
