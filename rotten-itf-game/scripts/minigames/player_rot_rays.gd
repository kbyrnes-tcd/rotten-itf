extends RayCast2D
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta: float) -> void:
	#if !is_colliding():
		#move(self)
	#else:
		#update_vine()
#
#func move(ray: RayCast2D):
	#match ray.name:
		#"up":
			#ray.target_position.y -= 50.0
		#"down":
			#ray.target_position.y += 50.0
		#"left":
			#ray.target_position.x -= 50.0
		#"right":
			#ray.target_position.x += 50.0
	#ray.force_raycast_update()
#
#func update_vine():
	#var col_point = self.to_local(self.get_collision_point())
	#self.target_position = col_point
