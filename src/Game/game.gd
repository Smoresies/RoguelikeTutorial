class_name  Game
extends Node2D

signal player_created(player)

# reference to our player definition
const player_definition: EntityDefinition = preload(("res://assets/definitions/entities/actors/entity_definition_player.tres"))
const level_up_menu_scene: PackedScene = preload("res://src/Gui/LevelUpMenu/level_up_menu.tscn")

# All variables that are defined/init before _ready()
@onready var player: Entity
@onready var input_handler: InputHandler = $InputHandler
@onready var map: Map = $Map
@onready var camera: Camera2D = $Camera2D

# Init all the things!
func new_game() -> void:
	player = Entity.new(null, Vector2i.ZERO, "player")
	player.level_component.level_up_required.connect(_on_player_level_up_requested)
	player_created.emit(player)
	remove_child(camera)
	player.add_child(camera)
	map.generate(player)
	map.update_fov(player.grid_position)
	MessageLog.send_message.bind(
		"Hello and welcome, adventurer, to yet another dungeon!",
		GameColors.WELCOME_TEXT
	).call_deferred()
	camera.make_current.call_deferred()


func load_game() -> bool:
	player = Entity.new(null, Vector2i.ZERO, "")
	remove_child(camera)
	player.add_child(camera)
	if not map.load_game(player):
		return false
	player.level_component.level_up_required.connect(_on_player_level_up_requested)
	player_created.emit(player)
	map.update_fov(player.grid_position)
	MessageLog.send_message.bind(
		"Welcome back, adventurer!",
		GameColors.WELCOME_TEXT
	).call_deferred()
	camera.make_current.call_deferred()
	return true


# process to handle actions
func _physics_process(_delta: float) -> void:
	var action: Action = await input_handler.get_action(player)
	if action:
		var previous_player_position: Vector2i = player.grid_position
		if action.perform():
			_handle_enemy_turns()
			map.update_fov(player.grid_position)
			

# helper function to return the mapdata
func get_map_data() -> MapData:
	return map.map_data

# Do AI stuff for enemies
func _handle_enemy_turns() -> void:
	for entity in get_map_data().get_actors():
		if entity.is_alive() and entity != player:
			entity.ai_component.perform()


func _on_player_level_up_requested() -> void:
	var level_up_menu: LevelUpMenu = level_up_menu_scene.instantiate()
	add_child(level_up_menu)
	level_up_menu.setup(player)
	set_physics_process(false)
	await level_up_menu.level_up_completed
	set_physics_process.bind(true).call_deferred()
