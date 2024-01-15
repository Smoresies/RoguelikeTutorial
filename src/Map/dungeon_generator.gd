class_name DungeonGenerator
extends Node

# Inspector Variables
@export_category("Map Dimensions")
@export var map_width: int = 80
@export var map_height: int = 45

@export_category("Rooms RNG")
@export var max_rooms: int = 30
@export var room_max_size: int = 10
@export var room_min_size: int = 6

@export_category("Monsters RNG")
@export var max_monster_per_room: int = 2

# Create some random number
var _rng := RandomNumberGenerator.new()

# define enemy types
const entity_types = {
	"orc": preload("res://assets/definitions/entities/actors/entity_definition_orc.tres"),
	"troll": preload("res://assets/definitions/entities/actors/entity_definition_troll.tres"),
}

# On ready, just randomize
func _ready() -> void:
	_rng.randomize()

# Carving out the layout of the dungeon, given x/y turn to floor.
func _carve_tile(dungeon: MapData, x: int, y: int) -> void:
	var tile_position = Vector2i(x, y)
	var tile: Tile = dungeon.get_tile(tile_position)
	tile.set_tile_type(dungeon.tile_types.floor)

# Given a rect and the mapdata, carve out a rectangular room.
func _carve_room(dungeon: MapData, room: Rect2i) -> void:
	var inner: Rect2i = room.grow(-1)
	for y in range(inner.position.y, inner.end.y +1):
		for x in range(inner.position.x, inner.end.x + 1):
			_carve_tile(dungeon, x, y)

# Create horizontal tunnels between rooms
func _tunnel_horizontal(dungeon: MapData, y: int, x_start: int, x_end: int) -> void:
	var x_min: int = mini(x_start, x_end)
	var x_max: int = maxi(x_start, x_end)
	for x in range(x_min, x_max + 1):
		_carve_tile(dungeon, x, y)

# Create vertical tunnels between rooms
func _tunnel_vertical(dungeon: MapData, x: int, y_start: int, y_end: int) -> void:
	var y_min: int = mini(y_start, y_end)
	var y_max: int = maxi(y_start, y_end)
	for y in range(y_min, y_max + 1):
		_carve_tile(dungeon, x, y)

# Create an L shaped tunnel
func _tunnel_between(dungeon: MapData, start: Vector2i, end: Vector2i) -> void:
	if _rng.randf() < 0.5:
		_tunnel_horizontal(dungeon, start.y, start.x, end.x)
		_tunnel_vertical(dungeon, end.x, start.y, end.y)
	else:
		_tunnel_vertical(dungeon, start.x, start.y, end.y)
		_tunnel_horizontal(dungeon, end.y, start.x, end.x)

# Determine if this room will have any enemies/entities and add them
func _place_entities(dungeon: MapData, room: Rect2i) -> void:
	# Randomly determine number of possible enemies
	var number_of_monsters: int = _rng.randi_range(1, max_monster_per_room)
	
	for _i in number_of_monsters:
		# Determine random X/Y position INSIDE OF ROOM to place them
		var x: int = _rng.randi_range(room.position.x + 1, room.end.x - 1)
		var y: int = _rng.randi_range(room.position.y + 1, room.end.y - 1)
		var new_entity_position := Vector2i(x, y)
		
		# Check to see if random position is already taken
		var cannot_place = false
		for entity in dungeon.entities:
			if entity.grid_position == new_entity_position:
				cannot_place = true
				break
		
		# If for some reason there is an entity in the same space, continue loop
		if not cannot_place:
			continue
		
		# if we can place, then we determine which type randomly and add
		var new_entity: Entity
		if _rng.randf() < 0.8:
			new_entity = Entity.new(new_entity_position, entity_types.orc)
		else:
			new_entity = Entity.new(new_entity_position, entity_types.troll)
		dungeon.entities.append(new_entity)

# Actually generate a dungeon, also places character in middle of first room 
func generate_dungeon(player: Entity) -> MapData:
	var dungeon := MapData.new(map_width, map_height)
	dungeon.entities.append(player)
	
	var rooms: Array[Rect2i] = []
	
	# tries to make a room for max number of possible rooms, not all work
	for _try_room in max_rooms:
		# Size of room in dungeon
		var room_width: int = _rng.randi_range(room_min_size, room_max_size)
		var room_height: int = _rng.randi_range(room_min_size, room_max_size)
		
		# Location in dungeon
		var x: int = _rng.randi_range(0, dungeon.width - room_width - 1)
		var y: int = _rng.randi_range(0, dungeon.height - room_height - 1)
		
		# Create the Rect for room
		var new_room := Rect2i(x, y, room_width, room_height)
		
		# Secret tool we use for later
		var has_intersections := false
		# For each created room...
		for room in rooms:
			# Check if it intersects with new room
			if room.intersects(new_room.grow(-1)):
				has_intersections = true
				break
		# If any intersected, cancel this room
		if has_intersections:
			continue
		
		# If we got this far we can make the new room.
		_carve_room(dungeon, new_room)
		
		# If this is first room, set player position
		if rooms.is_empty():
			player.grid_position = new_room.get_center()
		# If this isn't the first room... 
		# Create a tunnel between last room made and this one
		else:
			_tunnel_between(dungeon, rooms.back().get_center(), new_room.get_center())
		
		# Add any entities that would exist in this room.
		_place_entities(dungeon, new_room)
		
		# Add newly made room to array
		rooms.append(new_room)
	
	return dungeon
