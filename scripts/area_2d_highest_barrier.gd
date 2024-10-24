extends Area2D

@onready var game_node = get_node("/root/Game")
var position_updated = false

func _on_body_exited(body):
	game_node.highest_gem = game_node.find_highest_gem()

func update_position(body):
	if game_node.highest_gem and body == game_node.highest_gem:
		self.global_position.y = game_node.highest_gem.global_position.y + 50
