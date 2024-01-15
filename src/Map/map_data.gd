class_name MapData
extends RefCounted

# Dictionary that defines floor/wall to a specific tile in our file directory.
const tile_types = {
	"floor": preload("res://assets/definitions/tiles/tile_definition_floor.tres"),
	"wall": preload("res://assets/definitions/tiles/tile_definition_wall.tres"),
}

# Basic Data for size of map + array of all tiles in map
var width: int
var height: int
var tiles: Array[Tile]

# Setup map sizes, then make tiles based on _setup_tiles()
func _init(map_width: int, map_height: int) -> void:
	width = map_width
	height = map_height
	_setup_tiles()

# Currently populates tiles array with floor, other than walls at a specific few points.
func _setup_tiles() -> void:
	tiles = []
	for y in height:
		for x in width:
			var tile_position := Vector2i(x, y)
			var tile := Tile.new(tile_position, tile_types.wall)
			tiles.append(tile)

# returns the type of tile at given position in grid
func get_tile(grid_position: Vector2i) -> Tile:
	var tile_index: int = grid_to_index(grid_position)
	if tile_index == -1:
		return null
	return tiles[tile_index]

# Wrapper for FoV tile checking, does same as get_tile but takes 2 ints
func get_tile_xy(x: int, y: int) -> Tile:
	var grid_position := Vector2i(x, y)
	return get_tile(grid_position)

# converts from grid position to an array position, Vector2i -> int
func grid_to_index(grid_position: Vector2i) -> int:
	if not is_in_bounds(grid_position):
		return -1
	return grid_position.y * width + grid_position.x

# ensures anything we do stays within the bounds of our array
func is_in_bounds(coordinate: Vector2i) -> bool:
	return (
		0 <= coordinate.x
		and coordinate.x < width
		and 0 <= coordinate.y
		and coordinate.y < height
	)
