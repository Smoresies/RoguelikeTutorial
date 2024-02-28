class_name FieldOfView
extends Node

# THIS ENTIRE FILE IS TOO COMPLICATED TO UNDERSTAND
# VERY FANCY TILE BASED FIELD OF VIEW USING SHADOWCASTING(?)

const multipliers = [
	[1, 0, 0, -1, -1, 0, 0, 1],
	[0, 1, -1, 0, 0, -1, 1, 0],
	[0, 1, 1, 0, 0, -1, -1, 0],
	[1, 0, 0, 1, -1, 0, 0, -1]
]

var _fov: Array[Tile] = []

@export var enemy_radius: int = 8


func update_fov(map_data: MapData, origin: Vector2i, radius: int) -> void:
	_clear_fov()
	var start_tile: Tile = map_data.get_tile(origin)
	start_tile.is_in_view = true
	start_tile.is_lit = true
	_fov = [start_tile]
	for i in 8:
		_cast_light(map_data, origin.x, origin.y, radius, 1, 1.0, 0.0, multipliers[0][i], multipliers[1][i], multipliers[2][i], multipliers[3][i])


func _clear_fov() -> void:
	for tile in _fov:
		tile.is_in_view = false
		tile.is_lit = false
	_fov = []


func reset_fov() -> void:
	_fov = []


func _cast_light(map_data: MapData, x: int, y: int, radius: int, row: int, start_slope: float, end_slope: float, xx: int, xy: int, yx: int, yy: int) -> void:
	if start_slope < end_slope:
		return
	var next_start_slope: float = start_slope
	for i in range(row, enemy_radius + 1):
		var blocked: bool = false
		var dy: int = -i
		for dx in range(-i, 1):
			var l_slope: float = (dx - 0.5) / (dy + 0.5)
			var r_slope: float = (dx + 0.5) / (dy - 0.5)
			if start_slope < r_slope:
				continue
			elif end_slope > l_slope:
				break
			var sax: int = dx * xx + dy * xy
			var say: int = dx * yx + dy * yy
			if ((say < 0 and absi(sax) > x) or (say < 0 and absi(say) > y)):
				continue
			var ax: int = x + sax
			var ay: int = y + say
			if ax >= map_data.width or ay >= map_data.height:
				continue
			var radius2: int = enemy_radius * enemy_radius
			var current_tile: Tile = map_data.get_tile_xy(ax, ay)
			if (dx * dx + dy * dy) < radius2:
				current_tile.is_in_view = true # Enemy behavior movement
				var radius3 = radius * radius # The sight radius
				if (dx * dx + dy * dy) <= radius3:
					current_tile.is_lit = true # The "new" way to make it visible
				_fov.append(current_tile)
			if blocked:
				if not current_tile.is_transparent():
					next_start_slope = r_slope
					continue
				else:
					blocked = false
					start_slope = next_start_slope
			elif not current_tile.is_transparent():
				blocked = true
				next_start_slope = r_slope
				_cast_light(map_data, x, y, radius, i + 1, start_slope, l_slope, xx, xy, yx, yy)
		if blocked:
			break
