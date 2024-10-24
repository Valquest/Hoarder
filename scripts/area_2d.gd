extends Area2D

# Offset in pixels from the Line2D
var offset_y: float = -100.0
var gem_timer = {}
var stay_duration = 3.0  # How long a gem needs to stay in the area
var move_distance = 100.0  # Initial move distance for Line2D
var move_factor = 1.5  # Factor by which the move distance increases

# Line2D move progress tracking
var is_moving = false
var current_move_distance = 0.0
var move_speed = 200.0  # Speed at which the Line2D moves upwards
var target_position_y = 0.0  # Target position for Line2D when moving

func _ready():
	update_position()
	self.connect("body_entered", Callable(self, "_on_body_entered"))
	self.connect("body_exited", Callable(self, "_on_body_exited"))

# Update the position of the Area2D relative to the parent Line2D
func update_position():
	if owner and owner is Line2D:
		var line_position = owner.position
		position = Vector2(line_position.x, line_position.y + offset_y)


func _process(delta):
	update_position()

	# Move the Line2D upwards if it's in the process of moving
	if is_moving:
		var line2d = get_parent()  # Explicitly get the parent node
		if line2d and line2d is Line2D:
			# Calculate the movement amount using interpolation
			line2d.position.y = lerp(line2d.position.y, target_position_y, delta * 2)  # Adjust speed factor if needed
			
			# Check if Line2D has reached the target position
			if abs(line2d.position.y - target_position_y) < 1:
				line2d.position.y = target_position_y  # Snap to target position when close enough
				is_moving = false
				
			# Ensure that Area2D updates relative to Line2D
			update_position()

	# Iterate through the tracked gems and decrease their timer
	for gem in gem_timer.keys():
		gem_timer[gem] -= delta
		
		if gem_timer[gem] <= 0:
			freeze_all_gems()
			move_line_upwards()
			break  # Exit the loop since we have frozen all gems

# When a gem enters the Area2D
func _on_body_entered(body):
	if body.is_in_group("gems"):
		gem_timer[body] = stay_duration  # Start counting down for this gem

# When a gem exits the Area2D
func _on_body_exited(body):
	if body in gem_timer:
		gem_timer.erase(body)  # Stop tracking if the gem leaves the area

# Function to freeze all currently visible and settled gems
func freeze_all_gems():
	var highest_frozen_gem = null
	for gem in get_tree().get_nodes_in_group("gems"):
		# Check if the gem is visible and has landed
		if gem.is_visible_in_tree() and gem.landed:
			if highest_frozen_gem == null:
				highest_frozen_gem = gem
				gem.freeze = true  # Freeze only gems that have landed
			elif gem.global_position.y < highest_frozen_gem.global_position.y:
				highest_frozen_gem.remove_from_group("gems")
				highest_frozen_gem = gem
				gem.freeze = true  # Freeze only gems that have landed
			else:
				gem.freeze = true  # Freeze only gems that have landed
				gem.remove_from_group("gems")
	gem_timer.clear()

# Function to move the Line2D upwards
func move_line_upwards():
	var line2d = get_parent()  # Explicitly get the parent node, which should be Line2D
	if line2d and line2d is Line2D:
		is_moving = true
		current_move_distance = move_distance  # Set the current move distance
		target_position_y = line2d.position.y - current_move_distance  # Calculate the new target position
		move_distance *= move_factor  # Increase the move distance for the next time
