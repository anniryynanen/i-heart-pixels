class_name Layer
extends RefCounted

var id: int
var name: String
var image: Image


@warning_ignore("shadowed_variable")
func _init(id: int, size: Vector2i) -> void:
    self.id = id
    image = Image.create(size.x, size.y, false, IHP.FORMAT)
