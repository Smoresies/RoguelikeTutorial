class_name Map
extends Node2D

# Create/Find Dungeon Generator object
@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator
@onready var field_of_view: FieldOfView = $FieldOfView
@onready var tiles: Node2D = $Tiles
@onready var entities: Node2D = $Entities

# Changable in inspector, controls our "sight"
@export var fov_radius: int = 8

signal dungeon_floor_changed(floor)

# Holds all our MapData
var map_data: MapData

func _ready() -> void:
	SignalBus.player_descended.connect(next_floor)

# Creates map_data, then calls _place_tiles()
func generate(player: Entity, current_floor: int = 1) -> void:
	map_data = dungeon_generator.generate_dungeon(player, current_floor)
	if not map_data.entity_placed.is_connected(entities.add_child):
		map_data.entity_placed.connect(entities.add_child)
	_place_tiles()
	_place_entities()
	dungeon_floor_changed.emit(current_floor)

# Lets us just call FieldOfView's update easier
func update_fov(player_position: Vector2i) -> void:
	field_of_view.update_fov(map_data, player_position, fov_radius)
	
	for entity in map_data.entities:
		entity.visible = map_data.get_tile(entity.grid_position).is_lit

# Attaches all the tiles in map_data to be children of Map node
func _place_tiles() -> void:
	for tile in map_data.tiles:
		tiles.add_child(tile)

# Each entity in map_data, gets added to entities Node
func _place_entities() -> void:
	for entity in map_data.entities:
		entities.add_child(entity)

func load_game(player: Entity) -> bool:
	map_data = MapData.new(0, 0, player)
	map_data.entity_placed.connect(entities.add_child)
	if not map_data.load_game():
		return false
	_place_tiles()
	_place_entities()
	dungeon_floor_changed.emit(map_data.current_floor)
	return true


func next_floor() -> void:
	var player: Entity = map_data.player
	entities.remove_child(player)
	for entity in entities.get_children():
		entity.queue_free()
	for tile in tiles.get_children():
		tile.queue_free()
	generate(player, map_data.current_floor + 1)
	player.get_node("Camera2D").make_current()
	field_of_view.reset_fov()
	update_fov(player.grid_position)
