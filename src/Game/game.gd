class_name  Game
extends Node2D

# reference to our player definition
const player_definition: EntityDefinition = preload(("res://assets/definitions/entities/actors/entity_definition_player.tres"))

# All variables that are defined/init before _ready()
@onready var player: Entity
@onready var event_handler: EventHandler = $EventHandler
@onready var entities: Node2D = $Entities
@onready var map: Map = $Map

# Init all the things!
func _ready() -> void:
	player = Entity.new(Vector2i.ZERO, player_definition)
	var camera: Camera2D = $Camera2D
	remove_child(camera)
	player.add_child(camera)
	entities.add_child(player)
	map.generate(player)

# process to handle actions
func _physics_process(delta: float) -> void:
	var action: Action = event_handler.get_action()
	if action:
		action.perform(self, player)

# helper function to return the mapdata
func get_map_data() -> MapData:
	return map.map_data
