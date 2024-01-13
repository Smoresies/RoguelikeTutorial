class_name Map
extends Node2D

# width/height. Allows us to change in editor.
@export var map_width: int = 80
@export var map_height: int = 45

# Holds all our MapData
var map_data: MapData

# Creates map_data, then calls _place_tiles()
func _ready():
	map_data = MapData.new(map_width, map_height)
	_place_tiles()

# Attaches all the tiles in map_data to be children of Map node
func _place_tiles():
	for tile in map_data.tiles:
		add_child(tile)
