class_name Reticle
extends Node2D

signal position_selected(grid_position)

const directions = {
	"move_up": Vector2i.UP,
	"move_down": Vector2i.DOWN,
	"move_left": Vector2i.LEFT,
	"move_right": Vector2i.RIGHT,
}

var grid_position: Vector2i:
	set(value):
		grid_position = value
		position = Grid.grid_to_world(grid_position)

var map_data: MapData

@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	hide()
	set_physics_process(false)

func select_position(player: Entity, radius: int) -> Vector2i:
	map_data = player.map_data
	grid_position = player.grid_position
	
	var player_camera: Camera2D = get_viewport().get_camera_2d()
	camera.make_current()
	show()
	await get_tree().physics_frame
	set_physics_process.call_deferred(true)
	
	var selected_position: Vector2i = await position_selected
	
	set_physics_process(false)
	player_camera.make_current()
	hide()
	
	return selected_position
