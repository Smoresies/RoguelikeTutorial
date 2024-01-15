class_name Map
extends Node2D

# Create/Find Dungeon Generator object
@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator
@onready var field_of_view: FieldOfView = $FieldOfView
@onready var tiles: Node2D = $Tiles
@onready var entities: Node2D = $Entities

# Changable in inspector, controls our "sight"
@export var fov_radius: int = 8

# Holds all our MapData
var map_data: MapData

# Creates map_data, then calls _place_tiles()
func generate(player: Entity) -> void:
	map_data = dungeon_generator.generate_dungeon(player)
	_place_tiles()
	_place_entities()

# Lets us just call FieldOfView's update easier
func update_fov(player_position: Vector2i) -> void:
	field_of_view.update_fov(map_data, player_position, fov_radius)
	
	for entity in map_data.entities:
		entity.visible = map_data.get_tile(entity.grid_position).is_in_view

# Attaches all the tiles in map_data to be children of Map node
func _place_tiles() -> void:
	for tile in map_data.tiles:
		tiles.add_child(tile)

# Each entity in map_data, gets added to entities Node
func _place_entities() -> void:
	for entity in map_data.entities:
		entities.add_child(entity)

