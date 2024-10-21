extends Line2D

var time_passed: float = 0.0  # Track time to control the width changes

# Called when the node enters the scene tree for the first time.
func _ready():
	if not width_curve:
		width_curve = Curve.new()
		width_curve.add_point(Vector2(0, 0.8))
		width_curve.add_point(Vector2(1, 0.8))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_passed += delta  # Increment the time passed

	# Generate chaotic motion using noise and sine/cosine waves
	var noise_value = randf() * 2.0 - 1.0  # Random value between -1 and 1
	var sine_wave = sin(time_passed * 3.0) * 0.5  # Modify frequency and amplitude as needed

	# Calculate the new width
	var chaotic_value = noise_value + sine_wave

	# Normalize chaotic_value to fit within 0 to 1 range
	var normalized_value = (chaotic_value + 1.0) / 2.0
	
	# Scale to the desired range between 0.2 and 0.8
	var new_width = 0.2 + (normalized_value * (0.8 - 0.2))
	
	# Modify the existing point in the width curve
	if width_curve.get_point_count() > 0:
		width_curve.set_point_value(0, new_width)  # Update the width value of the first point
	else:
		width_curve.add_point(Vector2(0, new_width))  # Add the point if not already present

	# Update the Line2D to apply changes
	self.width_curve = width_curve
