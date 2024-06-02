class_name Layer
extends RefCounted

var id: int
var name: String
var image: Image


func _init(id_: int, size: Vector2i) -> void:
    id = id_
    image = Image.create(size.x, size.y, false, IHP.FORMAT)
