class_name MeleeAction
extends ActionWithDirection

func perform(game: Game, entity: Entity) -> void:
	var destination := Vector2i(entity.grid_position + offset)
	var target: Entity = game.get_map_data().get_blocking_entity_at_location(destination)
	
	# target will be null if there isn't an entity there.
	if not target:
		return
	print("You kick the %s, much to it's annoyance!" % target.get_entity_name())
