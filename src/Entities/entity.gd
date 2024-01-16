class_name Entity
extends Sprite2D

enum AIType {NONE, HOSTILE}

var fighter_component: FighterComponent
var ai_component: BaseAIComponent

var _definition: EntityDefinition
var map_data: MapData

func _init(map_data: MapData, start_position: Vector2i, entity_definition: EntityDefinition) -> void:
	centered = false
	grid_position = start_position
	self.map_data = map_data
	set_entity_type(entity_definition)
	
var grid_position: Vector2i:
	set(value):
		grid_position = value
		position = Grid.grid_to_world(grid_position)
	
func move(move_offset: Vector2i) -> void:
	map_data.unregister_blocking_entity(self)
	grid_position += move_offset
	map_data.register_blocking_entity(self)	

# Store defined type of entity
func set_entity_type(entity_definition: EntityDefinition) -> void:
	_definition = entity_definition
	texture = entity_definition.texture
	modulate = entity_definition.color
	
	match entity_definition.ai_type:
		AIType.HOSTILE:
			ai_component = HostileEnemyAIComponent.new()
			add_child(ai_component)
	
	if entity_definition.fighter_definition:
		fighter_component = FighterComponent.new(entity_definition.fighter_definition)
		add_child(fighter_component)

# Getter for movement blocking
func is_blocking_movement() -> bool:
	return _definition.is_blocking_movement

# Getter for entity name
func get_entity_name() -> String:
	return _definition.name

func is_alive() -> bool:
	return ai_component != null
