class_name HostileEnemyAIComponent
extends BaseAIComponent

var path: Array = []

func perform() -> void:
	# Find Player and get their location
	var target: Entity = get_map_data().player
	var target_grid_position: Vector2i = target.grid_position
	
	# Determine distance from Player
	var offset: Vector2i = target_grid_position - entity.grid_position
	var distance: float = max(abs(offset.x), abs(offset.y))
	
	# If we're in view to player...
	if get_map_data().get_tile(entity.grid_position).is_in_view:
		# And in distance to attack, ATTACK!!!
		# Extra check to make sure distance is only orthogonally <= 1
		if distance <= 1 and abs(offset.x) != abs(offset.y):
			return MeleeAction.new(entity, offset.x, offset.y).perform()
		
		# Otherwise try to find point to the player
		path = get_point_path_to(target_grid_position)
		path.pop_front()
	
	# If we have directions to the player
	if not path.is_empty():
		# Check to see if we are blocked
		var destination := Vector2i(path[0])
		if get_map_data().get_blocking_entity_at_location(destination):
			return WaitAction.new(entity).perform()
		path.pop_front()
		
		# If not blocked then move and return 
		var move_offset: Vector2i = destination - entity.grid_position
		return MovementAction.new(entity, move_offset.x, move_offset.y).perform()
	
	# If we have no path, then we just wait
	return WaitAction.new(entity).perform()
