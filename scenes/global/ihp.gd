class_name IHP
extends RefCounted

const FORMAT = Image.FORMAT_RGBA8

var size: Vector2i
var layers: Array[Layer]
var current_layer: Layer

var empty = true
var unsaved_changes = false
var layers_by_id: Dictionary = {}
var next_layer_id: int = -1


func _init(size_: Vector2i) -> void:
    size = size_

    var layer: Layer = Layer.new(get_next_layer_id(), size)
    layers.append(layer)
    layers_by_id[layer.id] = layer
    current_layer = layer


func touch() -> void:
    empty = false
    unsaved_changes = true


func save_to_file(path: String) -> bool:
    var dict: Dictionary = {
        "width": size.x,
        "height": size.y,
        "current_layer_id": current_layer.id,
        "next_layer_id": next_layer_id,
        "layers": []
    }
    for layer in layers:
        dict["layers"].append({
            "id": layer.id,
            "name": layer.name
        })

    var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
    var err: Error = FileAccess.get_open_error()
    if err:
        OS.alert("Couldn't save %s (%s)" % [path, error_string(err)], Globals.ERROR_TITLE)
        return false

    file.store_var(JSON.stringify(dict))
    file.store_var(current_layer.image.save_png_to_buffer())

    empty = false
    unsaved_changes = false
    return true


func get_next_layer_id() -> int:
    next_layer_id += 1
    return next_layer_id


static func load_from_file(path: String) -> IHP:
    if path.to_lower().ends_with(".ihp"):
        return load_ihp(path)
    else:
        return import_image(path)


static func load_ihp(path: String) -> IHP:
    var file: FileAccess = FileAccess.open(path, FileAccess.READ)
    var err: Error = FileAccess.get_open_error()
    if err:
        OS.alert("Couldn't load %s (%s)" % [path, error_string(err)], Globals.ERROR_TITLE)
        return null

    var dict: Dictionary = JSON.parse_string(file.get_var())
    if not dict:
        OS.alert("Couldn't load " + path)
        return null

    var ihp: IHP = IHP.new(Vector2(dict["width"], dict["height"]))
    ihp.next_layer_id = dict["next_layer_id"]

    var first = true
    for layer_dict: Dictionary in dict["layers"]:
        var layer: Layer
        if first:
            layer = ihp.layers[0]
            layer.id = layer_dict["id"]
            first = false
        else:
            layer = Layer.new(layer_dict["id"], ihp.size)
            ihp.layers.append(layer)

        layer.name = layer_dict["name"]
        layer.image.load_png_from_buffer(file.get_var())

        ihp.layers_by_id[layer.id] = layer

    ihp.current_layer = ihp.layers_by_id[int(dict["current_layer_id"])]
    ihp.empty = false
    return ihp


static func import_image(path: String) -> IHP:
    var image: Image = Image.load_from_file(path)
    if not image:
        OS.alert("Couldn't load " + path)
        return null

    if image.get_format() != IHP.FORMAT:
        image.convert(IHP.FORMAT)

    var ihp: IHP = IHP.new(image.get_size())
    ihp.current_layer.image = image
    ihp.empty = false
    return ihp
