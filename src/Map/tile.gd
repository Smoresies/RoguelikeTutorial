class_name Tile
extends Sprite2D

var _definition: TileDefinition


const tile_types = {
	"floor": preload("res://assets/definitions/tiles/tile_definition_floor.tres"),
	"wall": preload("res://assets/definitions/tiles/tile_definition_wall.tres"),
	"down_stairs": preload("res://assets/definitions/tiles/tile_definition_down_stairs.tres"),
}

var key: String

# Helps us track whether to show a tile or not
var is_explored: bool = false:
	set(value):
		is_explored = value
		if is_explored and not visible:
			visible = true

# Helps us make sure it's explored if it's in view
var is_in_view: bool = false:
	set(value):
		is_in_view = value
		#modulate = _definition.color_lit if is_in_view else _definition.color_dark
		#if is_in_view and not is_explored:
			#is_explored = true

var is_lit: bool = false:
	set(value):
		is_lit = value
		modulate = _definition.color_lit if is_lit else _definition.color_dark
		if is_lit and not is_explored:
			is_explored = true

func _init(grid_position: Vector2i, _key: String) -> void:
	visible = false
	centered = false
	position = Grid.grid_to_world(grid_position)
	set_tile_type(_key)

func set_tile_type(_key: String) -> void:
	self.key = _key
	_definition = tile_types[_key]
	texture = _definition.texture
	modulate = _definition.color_dark

func is_walkable() -> bool:
	return _definition.is_walkable

func is_transparent() -> bool:
	return _definition.is_transparent


func get_save_data() -> Dictionary:
	return {
		"key": key,
		"is_explored": is_explored
	}


func restore(save_data: Dictionary) -> void:
	set_tile_type(save_data["key"])
	is_explored = save_data["is_explored"]
