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
@onready var worm_hud = $CanvasLayer/WormHUD
@onready var segment_container = $CanvasLayer/WormHUD/SegmentContainer


const ROT_VINE = preload("uid://kicj2478es6o")
const GROWTH_SPEED = 120.0
const GLOWWORM = preload("res://scripts/inventory_system/items/orange_worm.tres")
const GLOWWORM_MAX = 5
const USE_INTERVAL = 2.0

const WORM_ICON = preload("res://assets/images/worms/Glowworm.png")
const SEGMENT_FILLED = preload("res://assets/images/ui/Glowworm_Bar_Filled.png")
const SEGMENT_EMPTY = preload("res://assets/images/ui/Glowworm_Bar_Empty.png")

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

var glowworm_uses = GLOWWORM_MAX
var use_timer = 0.0
var worm_in_use: bool = false
var segments: Array = []

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
	build_worm_segments()
	
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
		active_vine.set_rest_shape()
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
	update_worm_segments()
	var light = lantern.get_node_or_null("PointLight2D")
	if light:
		light.texture_scale = lerp(0.3, 1.0, life_ratio)
		light.energy = lerp(0.3, 1.5, life_ratio)

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
		
#change tool state
func change_tool_state(new_state: ToolState):
	print("tool: " + str(tool_state) + "to " + str(new_state))
	#exit current state
	match tool_state:
		ToolState.LANTERN_EQUIPPED: 
			lantern.visible = false
			#worm_in_use = false
			worm_hud.visible = false
			lantern.process_mode = Node.PROCESS_MODE_DISABLED
			lantern.modulate.a = 1.0
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
			lantern.modulate.a = 1.0
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
			lantern.visible = true
			lantern.process_mode = Node.PROCESS_MODE_INHERIT
			#worm_in_use = true
			var area = lantern.get_node_or_null("LanternArea2D")
			if area:
				area.monitoring = false
				area.monitorable = false
			update_lantern_visuals()
			lantern.modulate.a = 0.3
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
			else: 
				lantern.modulate.a = 0.3
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
		change_tool_state(ToolState.LANTERN_EQUIPPED)
		#if inv.has(GLOWWORM):
			#change_tool_state(ToolState.LANTERN_EQUIPPED)
		#else:
			#print("no glowworms! WOMP WOMP")
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
		if inv.has(GLOWWORM):
			change_tool_state(ToolState.LANTERN_ON)
		else:
			print("no glowworms! WOMP WOMP")
	
func _tool_lantern_on(delta: float):
	if Input.is_action_just_released("lantern_toggle"):
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
				change_tool_state(ToolState.LANTERN_EQUIPPED)

func build_worm_segments():
	for child in segment_container.get_children():
		child.queue_free()
	segments.clear()
	#create rect per number of uses
	for i in GLOWWORM_MAX:
		var dot = TextureRect.new()
		dot.texture = SEGMENT_FILLED
		dot.custom_minimum_size = Vector2(16,5)
		dot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		segment_container.add_child(dot)
		segments.append(dot)
	update_worm_segments()
	
func update_worm_segments():
	for i in segments.size():
		if i < glowworm_uses:
			segments[i].texture = SEGMENT_FILLED
		else:
			segments[i].texture = SEGMENT_EMPTY
			

func _tool_gun_equipped():
	if Input.is_action_just_pressed("equip_rot"):
		change_tool_state(ToolState.IDLE)
		return
	if Input.is_action_just_pressed("rot_cut"):
		change_tool_state(ToolState.LANTERN_EQUIPPED)
		return
	if Input.is_action_just_pressed("rot_extend") and not is_growing:
		start_vine()
		change_tool_state(ToolState.GUN_ON)
		return
	ray_cast_2d.force_raycast_update()
	var dir = get_snapped_direction()
	var _pts = ray_line_2d.points
	_pts[1] = ray_cast_2d.to_local(
		ray_cast_2d.global_position + dir * 200.0
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
		ray_cast_2d.global_position + dir * 200.0
	)
	ray_line_2d.points = _pts

func _handle_vine_growth(delta: float):
	if not is_growing or not active_vine:
		return
	var pts = active_vine.points
	if pts.size() < 2:
		return
	#var curve = Curve.new()
	#curve.add_point(Vector2(0,1))
	#curve.add_point(Vector2(0.8,1))
	#curve.add_point(Vector2(1,0))
	
	#active_vine.width_curve = curve
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

#to avoid other wall lanterns, etc to take worm from handheld lantern
func can_take_item(item: InvItem) -> bool:
	if item == GLOWWORM and worm_in_use:
		return false
	return true

func _on_area_2d_body_entered(body: Node2D) -> void:
	print('player detects: ' + body.name)

func _on_area_2d_body_exited(_body: Node2D) -> void:
	print("Exited!")
