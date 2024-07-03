class_name IHP
extends RefCounted

signal unsaved_changes_changed(unsaved_changes: bool)

const FORMAT = Image.FORMAT_RGBA8

var size: Vector2i
var layers: Array[Layer]
var current_layer: Layer

var untouched: bool = true
var unsaved_changes: bool = false:
    set(value):
        unsaved_changes = value
        untouched = false
        unsaved_changes_changed.emit(unsaved_changes)

var layers_by_id_: Dictionary
var next_layer_id_: int = -1


func _init(size_: Vector2i) -> void:
    size = size_

    var layer: Layer = Layer.new(get_next_layer_id_(), size)
    layers.append(layer)
    layers_by_id_[layer.id] = layer
    current_layer = layer


func resize_canvas(new_size: Vector2i, offset: Vector2i) -> void:
    size = new_size

    for layer in layers:
        var viewport: SubViewport = SubViewport.new()
        viewport.size = new_size
        viewport.transparent_bg = true
        viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
        layer.set_meta("viewport", viewport)
        Globals.add_child(viewport)

        var texture: TextureRect = TextureRect.new()
        texture.texture = ImageTexture.create_from_image(layer.image)
        viewport.add_child(texture)
        texture.position = offset

    await RenderingServer.frame_post_draw

    for layer in layers:
        var viewport: SubViewport = layer.get_meta("viewport") as SubViewport
        layer.image = viewport.get_texture().get_image()
        layer.remove_meta("viewport")
        Globals.remove_child(viewport)
        viewport.queue_free()

    unsaved_changes = true


func can_save_as_png() -> bool:
    return layers.size() == 1


func save_as_ihp(path: String) -> bool:
    var dict: Dictionary = {
        "width": size.x,
        "height": size.y,
        "current_layer_id": current_layer.id,
        "next_layer_id": next_layer_id_,
        "layers": []
    }
    for layer in layers:
        dict["layers"].append({
            "id": layer.id,
            "name": layer.name
        })

    var file: Object
    if TestRunner.TESTING:
        file = TestRunner.open_ihp(path)
    else:
        file = FileAccess.open(path, FileAccess.WRITE)

    var err: Error = FileAccess.get_open_error()
    if err:
        OS.alert("Couldn't save %s (%s)" % [path, error_string(err)], Globals.ERROR_TITLE)
        return false

    file.store_var(JSON.stringify(dict))
    file.store_var(current_layer.image.save_png_to_buffer())

    unsaved_changes = false
    Globals.show_notification.emit("Saved")
    return true


func save_as_png(path: String) -> bool:
    if not can_save_as_png():
        OS.alert("Can't save as PNG")
        return false

    var err: Error = IHP.save_png_(path, current_layer.image)
    if err:
        OS.alert("Couldn't save %s (%s)" % [path, error_string(err)], Globals.ERROR_TITLE)
        return false

    unsaved_changes = false
    Globals.show_notification.emit("Saved")
    return true


func export(path: String) -> bool:
    var err: Error = IHP.save_png_(path, current_layer.image)
    if err:
        OS.alert("Couldn't save %s (%s)" % [path, error_string(err)], Globals.ERROR_TITLE)
        return false

    Globals.show_notification.emit("Exported")
    return true


static func load_from_file(path: String) -> IHP:
    if path.to_lower().ends_with(".ihp"):
        return load_ihp_(path)
    else:
        return load_image_(path)


static func load_ihp_(path: String) -> IHP:
    var file: Object
    if TestRunner.TESTING:
        file = TestRunner.open_ihp(path)
    else:
        file = FileAccess.open(path, FileAccess.READ)

    var err: Error = FileAccess.get_open_error()
    if err:
        OS.alert("Couldn't load %s (%s)" % [path, error_string(err)], Globals.ERROR_TITLE)
        return null

    var dict: Dictionary = JSON.parse_string(file.get_var())
    if not dict:
        OS.alert("Couldn't load " + path)
        return null

    var ihp: IHP = IHP.new(Vector2(dict["width"], dict["height"]))
    ihp.next_layer_id_ = dict["next_layer_id"]

    var first: bool = true
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

        ihp.layers_by_id_[layer.id] = layer

    ihp.current_layer = ihp.layers_by_id_[int(dict["current_layer_id"])]
    ihp.untouched = false
    return ihp


static func load_image_(path: String) -> IHP:
    var image: Image
    if TestRunner.TESTING:
        image = TestRunner.load_image(path)
    else:
        image = Image.load_from_file(path)

    if not image:
        OS.alert("Couldn't load " + path)
        return null

    if image.get_format() != IHP.FORMAT:
        image.convert(IHP.FORMAT)

    var ihp: IHP = IHP.new(image.get_size())
    ihp.current_layer.image = image
    ihp.untouched = false
    return ihp


static func save_png_(path: String, image: Image) -> Error:
    if TestRunner.TESTING:
        TestRunner.save_png(path, image)
        return OK
    else:
        return image.save_png(path)


func get_next_layer_id_() -> int:
    next_layer_id_ += 1
    return next_layer_id_
