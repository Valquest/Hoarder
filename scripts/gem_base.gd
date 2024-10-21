extends RigidBody2D

# Gravity physics variables
var is_dropping = false
var landed = false
var is_on_screen = true

@onready var game_node = get_node("/root/Game")
@onready var counter_label = game_node.get_node("CanvasLayer/CanvasGroup/GemCountLabel")
@onready var platform_node = get_node("/root/Game/AnimatableBody2D")
@onready var notifier = $VisibleOnScreenNotifier2D

# A list of other gems
var other_gems = []

# Store rotation related variables
var previous_mouse_y = 0  # Store the previous mouse Y position

var target_rotation = 0  # Target rotation in degrees
var rotation_velocity = 0  # Velocity at which the gem rotates
var max_rotation_force = 30  # Maximum speed to rotate based on mouse speed
var damping = 0.93  # Damping factor for easing out/inertia

func _process(delta):
	if not is_dropping:
		# Follow the mouse on the X axis
		global_position.x = get_viewport().get_mouse_position().x
		
		# Get the current mouse Y position
		var current_mouse_y = get_viewport().get_mouse_position().y
		
		# Calculate the difference in mouse Y position
		var mouse_movement = current_mouse_y - previous_mouse_y
		
		# Calculate the rotation force based on mouse speed
		if abs(mouse_movement) > 0:
			# Determine the rotation force based on mouse speed
			var speed_factor = min(abs(mouse_movement) * 4, max_rotation_force)  # Adjust the multiplier (0.5) to control sensitivity
			if mouse_movement > 0:
				rotation_velocity += speed_factor  # Clockwise
			elif mouse_movement < 0:
				rotation_velocity -= speed_factor  # Counterclockwise
			
		# Apply damping to slow down the rotation gradually (ease out effect)
		rotation_velocity *= damping
		
		# Update the target rotation using the current velocity
		target_rotation += rotation_velocity * delta
		
		# Set the actual rotation with a smooth transition using lerp_angle
		rotation_degrees = target_rotation

		# Update previous_mouse_y for the next frame
		previous_mouse_y = current_mouse_y
		
	# Increment gem counter
	if is_dropping and not landed:
		if abs(linear_velocity.y) < 1.0 and global_position.y > 150:  # Adjust Y position threshold if necessary
			mark_as_landed()
			
	# Decrement gem counter
	if is_dropping and global_position.y > 1050 and is_on_screen:
		is_on_screen = false
		if landed:
			game_node.decrement_gem_count()  # Call to decrement count			
		# Remove the gem from the other gems array for detection
		for gem in other_gems:
			if is_instance_valid(gem):
				gem.other_gems.erase(self)
		queue_free()  # Remove the gem from the scene

# Handle mouse input
func _input(event):
	if event is InputEventMouseButton:
		# Check for mouse wheel up or down events
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			# Increase rotation velocity for clockwise rotation
			rotation_velocity += max_rotation_force / 2  # Adjust this value as needed
		elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			# Decrease rotation velocity for counterclockwise rotation
			rotation_velocity -= max_rotation_force / 2  # Adjust this value as needed

# Mark the gem as landed
func mark_as_landed():
	if not landed:
		landed = true
		# Increment the gem counter
		game_node.increment_gem_count()

# Disable collisions initially by setting collision layers and masks to 0
func disable_collisions():
	collision_layer = 0
	collision_mask = 0

# Enable collisions by restoring the appropriate collision layers and masks
func enable_collisions():
	collision_layer = 1  # Adjust this to match your game's setup
	collision_mask = 1  # Adjust this to match your game's setup
	
# Drop the gem
func drop_gem():
	if not is_dropping:
		is_dropping = true
		# Enable collisions when the gem is dropped
		enable_collisions()
		
		# Reset any accumulated velocity before dropping
		linear_velocity = Vector2(0, 350)		
		
		gravity_scale = 0.4  # Let gravity pull the gem down
