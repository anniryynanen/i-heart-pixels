extends Node
## Godot initializes the window position after the first scene has been loaded.
## This dummy scene lets the main scene be the second one, so that it can move
## the window after Godot is done.


func _ready() -> void:
    get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")
