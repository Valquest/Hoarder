extends Node2D

var current_gem = null
var can_spawn_gem = true
var gem_count = 0

var last_rotation_angle = 0 # Gem rotation angle for keeping all gems on the same angle on spawn

@onready var counter_label = $CanvasLayer/CanvasGroup/GemCountLabel
@onready var camera = $Camera2D

var gem_scene = preload("res://scenes/gems/amber_gem.tscn")

# Function to spawn a new gem (spawns amber gem)
func spawn_gem():
	current_gem = gem_scene.instantiate()
	
	# Get previous gems rotation angle
	current_gem.rotation_degrees = last_rotation_angle
	current_gem.target_rotation = last_rotation_angle
	
	# Initialize previous_mouse_y possition to prevent incorrect mouse movements
	current_gem.previous_mouse_y = get_viewport().get_mouse_position().y
		
	# Disable collisions initially so it doesn't interact with other objects before dropping
	current_gem.disable_collisions()
	
	# Calculate the top of the camera view, relative to the camera's smoothed position
	var camera_top = camera.get_global_position().y - get_viewport_rect().size.y /  2
	
	current_gem.position = Vector2(get_viewport().get_mouse_position().x, camera_top + 120)  # Spawn at top of screen and add an offset value
	add_child(current_gem)
	
	# Add current gem to the list of other gems
	for gem in get_tree().get_nodes_in_group("gems"):
		gem.other_gems.append(current_gem)
	
	current_gem.add_to_group("gems")

# Handle mouse input to drop the gem
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		if can_spawn_gem and current_gem:
			can_spawn_gem = false
			
			# Store rotation angle for the next gem
			last_rotation_angle = current_gem.rotation_degrees
			
			current_gem.drop_gem()
			# Create a timer that waits for 1 second before continuing
			await get_tree().create_timer(0.25).timeout
			spawn_gem()
			can_spawn_gem = true

func _process(delta):
	# If the gem has not been dropped, follow the mouse at the top of the camera's view
	if current_gem and not current_gem.is_dropping:
		var current_gem_position = current_gem.position.y
		var camera_top = camera.get_global_position().y - get_viewport_rect().size.y /  2
		# Keep the gem following the mouse horizontally and at the top of the camera's view vertically
		current_gem.position = Vector2(get_viewport().get_mouse_position().x, lerp(current_gem_position, camera_top + 100, 0.1))
		
	if gem_count > 0:
		var highest_gem = find_highest_gem()
		if highest_gem:
			# Move the camera to follow the highest gem
			var target_y = highest_gem.global_position.y  # Adjust this value as needed
			if highest_gem.global_position.y < 700:
				camera.position.y = lerp(camera.position.y, target_y - 200, 0.1)

func find_highest_gem():
	var highest_gem = null
	var highest_y = INF
	
	for gem in get_tree().get_nodes_in_group("gems"):
		if gem.landed:
			if gem.global_position.y < highest_y:
				highest_y = gem.global_position.y
				highest_gem = gem
	
	return highest_gem

# Spawn the first gem when the game starts
func _ready():
	camera.make_current()  # Set the camera as active
	spawn_gem()
	counter_label.text = str(gem_count)

func increment_gem_count():
	gem_count += 1
	update_gem_count_label()

func decrement_gem_count():
	if gem_count > 0:
		gem_count -= 1
	update_gem_count_label()

func update_gem_count_label():
	counter_label.text = str(gem_count)
