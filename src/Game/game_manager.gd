extends Node

const game_scene: PackedScene = preload("res://src/Game/game.tscn")
const main_menu_scene: PackedScene = preload("res://src/Gui/MainMenu/main_menu.tscn")

# Hold current child. Should only ever have 1 child but this is a shortcut
var current_child: Node


func _ready():
	load_main_menu()


func switch_to_scene(scene: PackedScene) -> Node:
	if current_child != null:
		current_child.queue_free()
	current_child = scene.instantiate()
	add_child(current_child)
	return current_child


func load_main_menu() -> void:
	var main_menu: MainMenu = switch_to_scene(main_menu_scene)
	main_menu.game_requested.connect(_on_game_requested)


func _on_game_requested(try_load: bool) -> void:
	var game: GameRoot = switch_to_scene(game_scene)
	game.main_menu_requested.connect(load_main_menu)
	if try_load:
		game.load_game()
	else:
		game.new_game()
