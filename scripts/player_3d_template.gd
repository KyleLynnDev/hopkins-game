extends CharacterBody3D

@export_group("Movement")
## Character maximum run speed on the ground in meters per second.
@export var move_speed := 8.0
## Ground movement acceleration in meters per second squared.
@export var acceleration := 20.0
## When the player is on the ground and presses the jump button, the vertical
## velocity is set to this value.
@export var jump_impulse := 12.0
## Player model rotation speed in arbitrary units. Controls how fast the
## character skin orients to the movement or camera direction.
@export var rotation_speed := 12.0
## Minimum horizontal speed on the ground. This controls when the character skin's
## animation tree changes between the idle and running states.
@export var stopping_speed := 1.0

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var tilt_upper_limit := PI / 3.0
@export var tilt_lower_limit := -PI / 8.0

@onready var _camera_third_person = %ThirdPersonCam
@onready var _camera_first_person = %FirstPersonCam



## Each frame, we find the height of the ground below the player and store it here.
## The camera uses this to keep a fixed height while the player jumps, for example.
var ground_height := 0.0

var _gravity := -30.0
var _was_on_floor_last_frame := true
#var _camera_input_direction := Vector2.ZERO
var _third_person_input_direction := Vector2.ZERO
var _first_person_input_direction := Vector2.ZERO

var first_person_enabled := false


## The last movement or aim direction input by the player. We use this to orient
## the character model.
@onready var _last_input_direction := global_basis.z
# We store the initial position of the player to reset to it when the player falls off the map.
@onready var _start_position := global_position

@onready var _camera_pivot = %CameraPivot
@onready var _camera: Camera3D = %ThirdPersonCam
@onready var _skin: SophiaSkin = %SophiaSkin
@onready var _landing_sound: AudioStreamPlayer3D = %LandingSound
@onready var _jump_sound: AudioStreamPlayer3D = %JumpSound
@onready var _dust_particles: GPUParticles3D = %DustParticles

#Switching Camera perspective variables

var _stored_skin_rotation_y := 0.0
var _stored_body_rotation_y := 0.0

var can_toggle_camera := true
var toggle_cooldown := 0.2  # seconds


#interaction variables

var _hovered_interactable: Node = null
var _nearby_interactables: Array[Node] = []
var _raycast_target: Node = null
var _nearby_target: Node = null

@onready var _raycast = %FirstPersonRayCast3D  # or dynamic camera
@onready var _interact_prompt = Ui.interaction 


func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#print("Mouse mode:", Input.get_mouse_mode())
	pass



func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("cam_toggle") and can_toggle_camera:
		first_person_enabled = !first_person_enabled
		update_camera_mode()
		can_toggle_camera = false
		# Start cooldown timer
		await get_tree().create_timer(toggle_cooldown).timeout
		can_toggle_camera = true
		
	if Input.is_action_just_pressed("open_collection"):
		Ui.open_collection()
		
	if event.is_action_pressed("ui_cancel"):
		if Ui.collection.visible:
			Ui.collection.visible = false
			get_tree().set_input_as_handled()
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	#if event is InputEventMouseMotion:
		#print("Mouse motion:", event.relative)

func _unhandled_input(event: InputEvent) -> void:
	
	
	var player_is_using_mouse := (
		event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)

	#print(Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
	#print(player_is_using_mouse)
	if player_is_using_mouse:
		if first_person_enabled:
			_first_person_input_direction.x = -event.relative.x * mouse_sensitivity
			_first_person_input_direction.y = -event.relative.y * mouse_sensitivity
		else:
			_third_person_input_direction.x = -event.relative.x * mouse_sensitivity
			_third_person_input_direction.y = -event.relative.y * mouse_sensitivity
	# Capture right stick movement for camera control
	var right_stick_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)  # Right stick horizontal
	var right_stick_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)  # Right stick vertical

	# Apply dead zone to avoid jitter when the stick is near center
	if abs(right_stick_x) > 0.1 or abs(right_stick_y) > 0.1:
		#_camera_input_direction.x = -right_stick_x * mouse_sensitivity * 10  # Scale input
		#_camera_input_direction.y = -right_stick_y * mouse_sensitivity * 10
		if first_person_enabled:
			_first_person_input_direction.x = -right_stick_x * mouse_sensitivity * 10  # Scale input
			_first_person_input_direction.y = -right_stick_y * mouse_sensitivity * 10
		else:
			_third_person_input_direction.x = -right_stick_x * mouse_sensitivity * 10  # Scale input
			_third_person_input_direction.y = -right_stick_y * mouse_sensitivity * 10


func _physics_process(delta: float) -> void:
	
	if Ui.is_ui_open():
		return  # Skip movement/interact
	
	#Handle camera input
	#Use correct camera
	#Calculate Movement input and align it
	#Smoothly rotate skin if in third person
	#Move the character
	#Character animations and visuals 
	
	handleCollisions(delta)
	#print(_hovered_interactable)
	
	#Handle camera input
	if first_person_enabled:
		_camera_first_person.rotation.x += _first_person_input_direction.y * delta
		_camera_first_person.rotation.x = clamp(_camera_first_person.rotation.x, tilt_lower_limit, tilt_upper_limit)
		rotation.y += _first_person_input_direction.x * delta # Rotate entire player in first-person
	else:
		_camera_pivot.rotation.x += _third_person_input_direction.y * delta
		_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, tilt_lower_limit, tilt_upper_limit)
		_camera_pivot.rotation.y += _third_person_input_direction.x * delta

	_first_person_input_direction = Vector2.ZERO
	_third_person_input_direction = Vector2.ZERO
	
	
	#Use correct camera
	var _camera = _camera_first_person if first_person_enabled else _camera_third_person

	
		# Calculate movement input and align it to the camera's direction.
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.4)
	var forward : Vector3 = _camera.global_transform.basis.z.normalized()
	var right : Vector3 = _camera.global_transform.basis.x.normalized()
	var move_direction := (right * raw_input.x + forward * raw_input.y).normalized()

	if move_direction.length() > 0.2 or first_person_enabled:
		_last_input_direction = move_direction.normalized()

	# Smoothly rotate the skin (only in third person)
	if not first_person_enabled and move_direction.length() > 0.2:
		var target_angle = atan2(move_direction.x, move_direction.z)
		_skin.rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)
	# Move the character
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	if is_equal_approx(move_direction.length_squared(), 0.0) and velocity.length_squared() < stopping_speed:
		velocity = Vector3.ZERO
	velocity.y = y_velocity + _gravity * delta

	# Character animations and visual effects.
	var ground_speed := Vector2(velocity.x, velocity.z).length()
	var is_just_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
	if is_just_jumping:
		velocity.y += jump_impulse
		_skin.jump()
		_jump_sound.play()
	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		if ground_speed > 0.0:
			_skin.move()
		else:
			_skin.idle()

	_dust_particles.emitting = is_on_floor() and ground_speed > 0.0

	if is_on_floor() and not _was_on_floor_last_frame:
		_landing_sound.play()

	_was_on_floor_last_frame = is_on_floor()
	
	
	#print("Body forward:", -global_transform.basis.z)
	#print("Skin forward:", -_skin.global_transform.basis.z)
		
	move_and_slide()
	_skin.set_facing_direction(raw_input)
	
func update_camera_mode():
	_camera_third_person.current = !first_person_enabled
	_camera_first_person.current = first_person_enabled

	# Hide player mesh in first-person
	_skin.visible = !first_person_enabled

	if not first_person_enabled:
		
		_camera_pivot.rotation.y = rotation.y
		_camera_pivot.rotation.x = _camera_first_person.rotation.x
		
		# Reset the player body's Y rotation to 0 so it doesn't affect the mesh
		var yaw = rotation.y
		rotation.y = 0.0
		# Apply the same world-facing direction to the mesh
		_skin.rotation.y = yaw

	# Reset movement direction for smooth transition
		var forward = Vector3(sin(yaw), 0, cos(yaw)).normalized()
		_last_input_direction = forward
		
		

	if first_person_enabled:
	# Get third-person look angles
		var yaw = _camera_pivot.rotation.y
		var pitch = _camera_pivot.rotation.x

	# Apply them to body and first-person camera
		rotation.y = yaw  # rotate the body
		_camera_first_person.rotation.x = pitch


	# TODO: adjust input settings, like mouse sensitivity
	
	
func handleCollisions(delta):
	# Raycast update
	_raycast.force_raycast_update()
	if _raycast.is_colliding():
		var hit = _raycast.get_collider()
		if hit and hit.has_method("interact"):
			_raycast_target = hit
		else:
			_raycast_target = null
	else:
		_raycast_target = null

	# Decide which target to use based on camera mode
	if first_person_enabled:
		_hovered_interactable = _raycast_target
	else:
		_hovered_interactable = _nearby_target
	 # prioritize raycast if available
		
	if _hovered_interactable:
		Ui.show_interact_prompt("Press E to examine " + _hovered_interactable.interact_name)
		if Input.is_action_just_pressed("Interaction"):
			_hovered_interactable.interact()
	else:
		Ui.hide_interact_prompt()
		
		#if _nearby_interactables.size() > 0:
			#_hovered_interactable = _nearby_interactables[0]
			#var closest_dist = global_position.distance_to(_hovered_interactable.global_position)
			#for obj in _nearby_interactables:
				#var d = global_position.distance_to(obj.global_position)
				#if d < closest_dist:
					#_hovered_interactable = obj
					#closest_dist = d 
		#else:
			#_hovered_interactable = null; 
	##print(_interact_prompt)
		#
		#if _hovered_interactable:
			#Ui.show_interact_prompt("Press E to examine " + _hovered_interactable.interact_name)
		#else:
			#Ui.hide_interact_prompt()
		#
		#if _hovered_interactable and Input.is_action_just_pressed("Interaction"):
			#_hovered_interactable.interact()


#func _on_interaction_detector_body_entered(body: Node3D) -> void:
	#if body.has_method("interact"):
		#_nearby_interactables.append(body)
#
#
#
#func _on_interaction_detector_body_exited(body: Node3D) -> void:
	#_nearby_interactables.erase(body)
	#
	
	



func _on_interaction_detector_body_entered(body: Node3D) -> void:
	if body.has_method("interact"):
		_nearby_target = body


func _on_interaction_detector_body_exited(body: Node3D) -> void:
	if _nearby_target == body:
		_nearby_target = null
