class_name Test
extends Node

var app_name_: String
var open_dialog_: FileDialog
var save_dialog_: FileDialog
var export_dialog_: FileDialog
var mouse_pos_: Vector2


func _enter_tree() -> void:
    app_name_ = ProjectSettings.get_setting("application/config/name")

    open_dialog_ = find_node("OpenDialog") as FileDialog
    save_dialog_ = find_node("SaveDialog") as FileDialog
    export_dialog_ = find_node("ExportDialog") as FileDialog

    save_dialog_.use_native_dialog = false
    open_dialog_.use_native_dialog = false
    export_dialog_.use_native_dialog = false


func find_node(node: Variant) -> Node:
    if node is Node:
        return node

    elif node is Array:
        var child: Node = find_node(node[0])

        for i: int in range(1, node.size()):
            child = child.find_child(node[i], true, false)

        return child

    else:
        return get_tree().root.find_child(node, true, false)


func hold_mouse(pos: Vector2, window_id: int = 0) -> void:
    mouse_pos_ = pos
    await mouse_button_event_(MOUSE_BUTTON_LEFT, pos, true, window_id)


func release_mouse(window_id: int = 0) -> void:
    await mouse_button_event_(MOUSE_BUTTON_LEFT, mouse_pos_, false, window_id)


func click(pos: Vector2, window_id: int = 0) -> void:
    await hold_mouse(pos, window_id)
    await release_mouse(window_id)


func scroll_up(pos: Vector2, window_id: int = 0) -> void:
    await mouse_button_event_(MOUSE_BUTTON_WHEEL_UP, pos, true, window_id)


func scroll_down(pos: Vector2, window_id: int = 0) -> void:
    await mouse_button_event_(MOUSE_BUTTON_WHEEL_DOWN, pos, true, window_id)


func mouse_button_event_(button: MouseButton, pos: Vector2, pressed: bool, window_id: int) -> void:
    var event: InputEventMouseButton = InputEventMouseButton.new()
    event.window_id = window_id
    event.position = pos
    event.button_index = button
    event.pressed = pressed
    Input.parse_input_event(event)

    await RenderingServer.frame_post_draw


func move_mouse(pos: Vector2, window_id: int = 0) -> void:
    var event: InputEventMouseMotion = InputEventMouseMotion.new()
    event.window_id = window_id
    event.position = pos
    event.relative = pos - mouse_pos_
    event.velocity = event.relative
    Input.parse_input_event(event)

    mouse_pos_ = pos

    await RenderingServer.frame_post_draw


func pixel_pos(pos: Vector2i) -> Vector2:
    var canvas: Control = find_node("Canvas") as Control
    return Vector2(-canvas.top_left_ +
        Vector2(pos.x * canvas.pixel_width_, pos.y * canvas.pixel_width_))


func hold_key(key: Key) -> void:
    await key_event_(key, true)


func release_key(key: Key) -> void:
    await key_event_(key, false)


func press_key(key: Key) -> void:
    await hold_key(key)
    await release_key(key)


func key_event_(key: Key, pressed: bool) -> void:
    var event: InputEventKey = InputEventKey.new()
    event.physical_keycode = key
    event.pressed = pressed
    Input.parse_input_event(event)

    await RenderingServer.frame_post_draw


func press_button(node: Variant) -> void:
    var button: Button = find_node(node) as Button
    button.pressed.emit()

    await RenderingServer.frame_post_draw


func activate_menu_item(menu_name: String, item: String) -> void:
    var menu: PopupMenu = find_node(["MainMenu", menu_name]) as PopupMenu

    for i: int in range(menu.item_count):
        if menu.get_item_text(i) == item:
            menu.index_pressed.emit(i)
            break

    await RenderingServer.frame_post_draw


func select_file_to_open(path: String) -> void:
    open_dialog_.hide()
    open_dialog_.file_selected.emit(path)
    await RenderingServer.frame_post_draw


func select_file_to_save(path: String) -> void:
    save_dialog_.hide()
    save_dialog_.file_selected.emit(path)
    await RenderingServer.frame_post_draw


func select_file_to_export(path: String) -> void:
    export_dialog_.hide()
    export_dialog_.file_selected.emit(path)
    await RenderingServer.frame_post_draw


func is_equal(a: Variant, b: Variant, message: String) -> bool:
    if a != b:
        print("Expected %s to be %s (%s)" % [a, b, message])
        print_stack_()
        return false
    return true


func is_visible(node: Variant) -> bool:
    var node_name: Variant = node.name if node is Node else node

    if not find_node(node).visible:
        print("Expected ", node_name, " to be visible")
        print_stack_()
        return false
    return true


func is_not_visible(node: Variant) -> bool:
    var node_name: Variant = node.name if node is Node else node

    if find_node(node).visible:
        print("Expected ", node_name, " to not be visible")
        print_stack_()
        return false
    return true


func input_value_is(node: Variant, value: Variant) -> bool:
    var node_name: Variant = node.name if node is Node else node
    var input: Node = find_node(node)

    var input_value: Variant
    if input is SpinBox:
        input_value = input.value
    elif input is LineEdit:
        input_value = input.text

    if input_value != value:
        print("Expected %s value to be %s, but it was %s" % [node_name, value, input_value])
        print_stack_()
        return false
    return true


func tool_is(tool: Tool.Type) -> bool:
    if Globals.tool != tool:
        print("Expected tool to be %s, but it was %s" %
            [Tool.Type.keys()[tool], Tool.Type.keys()[Globals.tool]])
        print_stack_()
        return false
    return true


func tool_color_is(color: Color) -> bool:
    if Globals.tool_color.to_rgb().to_html() != color.to_html():
        print("Expected tool color to be %s, but it was %s" % [color, Globals.tool_color])
        print_stack_()
        return false
    return true


func pixel_is(pos: Vector2i, color: Color) -> bool:
    var pixel_color: Color = Globals.image.current_layer.image.get_pixel(pos.x, pos.y)
    # Compare hexes to remove more rounding errors than `is_equal_approx`
    if pixel_color.to_html() != color.to_html():
        print("Expected color at (%s, %s) to be %s, but it was %s" %
            [pos.x, pos.y, color, pixel_color])
        print_stack_()
        return false
    return true


func pixel_is_transparent(pos: Vector2i) -> bool:
    return pixel_is(pos, Color(0, 0, 0, 0))


func pixel_is_tool_color(pos: Vector2i) -> bool:
    return pixel_is(pos, Globals.tool_color.to_rgb())


func image_size_is(image_size: Vector2i) -> bool:
    if Globals.image.size != image_size:
        print("Expected image size to be %s, but it was %s" % [image_size, Globals.image.size])
        print_stack_()
        return false
    return true


func title_is(title: String) -> bool:
    if get_window().title != title:
        print('Expected title to be "%s", but it was "%s"' % [title, get_window().title])
        print_stack_()
        return false
    return true


func picker_color_param_is(param: OKColor.Param, value: int) -> bool:
    var value_text: String
    match param:
        OKColor.Param.HUE:
            value_text = find_node(["HueHandle", "Value"]).text
        OKColor.Param.SATURATION:
            value_text = find_node(["SaturationHandle", "Value"]).text
        OKColor.Param.LIGHTNESS:
            value_text = find_node(["LightnessHandle", "Value"]).text

    if value_text != str(value):
        print("Expected color picker %s to be %s, but it was %s" %
            [OKColor.Param.keys()[param], value, value_text])
        print_stack_()
        return false
    return true


func tool_color_param_is(param: OKColor.Param, value: int) -> bool:
    var tool_value: int = Globals.tool_color.get_param_in_steps(param)
    if tool_value != value:
        print("Expected color picker %s to be %s, but it was %s" %
            [OKColor.Param.keys()[param], value, tool_value])
        print_stack_()
        return false
    return true


func print_stack_() -> void:
    for line: Dictionary in get_stack():
        print("    at %s (%s %s)" % [line.function, line.source.get_file(), line.line])
