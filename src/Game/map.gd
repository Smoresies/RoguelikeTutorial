class_name Map
extends Node2D

# Create/Find Dungeon Generator object
@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator

# Holds all our MapData
var map_data: MapData

# Creates map_data, then calls _place_tiles()
func _ready():
	map_data = dungeon_generator.generate_dungeon()
	_place_tiles()

# Attaches all the tiles in map_data to be children of Map node
func _place_tiles():
	for tile in map_data.tiles:
		add_child(tile)
