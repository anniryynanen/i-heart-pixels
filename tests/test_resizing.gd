extends Test


func should_resize_canvas() -> bool:
    var width: SpinBox = find_node(["ResizeCanvasPopup", "Width"]) as SpinBox
    var height: SpinBox = find_node(["ResizeCanvasPopup", "Height"]) as SpinBox
    var x_offset: SpinBox = find_node(["ResizeCanvasPopup", "XOffset"]) as SpinBox
    var y_offset: SpinBox = find_node(["ResizeCanvasPopup", "YOffset"]) as SpinBox

    await activate_menu_item("Image", "Resize Canvas...")
    if not is_visible("ResizeCanvasPopup"): return false
    if not input_value_is(width, 16): return false
    if not input_value_is(height, 16): return false
    if not input_value_is(x_offset, 0): return false
    if not input_value_is(y_offset, 0): return false

    await press_button(["ResizeCanvasPopup", "Cancel"])
    if not is_not_visible("ResizeCanvasPopup"): return false

    await click(pixel_pos(Vector2i(2, 2)))
    if not pixel_is_tool_color(Vector2i(2, 2)): return false

    await activate_menu_item("Image", "Resize Canvas...")

    width.value = 19
    await press_button(["ResizeCanvasPopup", "AlignLeft"])
    if not input_value_is(x_offset, 0): return false
    await press_button(["ResizeCanvasPopup", "AlignCenterH"])
    if not input_value_is(x_offset, 2): return false
    await press_button(["ResizeCanvasPopup", "AlignRight"])
    if not input_value_is(x_offset, 3): return false

    height.value = 19
    await press_button(["ResizeCanvasPopup", "AlignTop"])
    if not input_value_is(y_offset, 0): return false
    await press_button(["ResizeCanvasPopup", "AlignCenterV"])
    if not input_value_is(y_offset, 2): return false
    await press_button(["ResizeCanvasPopup", "AlignBottom"])
    if not input_value_is(y_offset, 3): return false

    width.value = 13
    await press_button(["ResizeCanvasPopup", "AlignLeft"])
    if not input_value_is(x_offset, 0): return false
    await press_button(["ResizeCanvasPopup", "AlignCenterH"])
    if not input_value_is(x_offset, -1): return false
    await press_button(["ResizeCanvasPopup", "AlignRight"])
    if not input_value_is(x_offset, -3): return false

    height.value = 13
    await press_button(["ResizeCanvasPopup", "AlignTop"])
    if not input_value_is(y_offset, 0): return false
    await press_button(["ResizeCanvasPopup", "AlignCenterV"])
    if not input_value_is(y_offset, -1): return false
    await press_button(["ResizeCanvasPopup", "AlignBottom"])
    if not input_value_is(y_offset, -3): return false

    width.value = 19
    height.value = 13
    x_offset.value = 0
    y_offset.value = 0
    await press_button(["ResizeCanvasPopup", "Resize"])
    if not image_size_is(Vector2i(19, 13)): return false
    if not pixel_is_tool_color(Vector2i(2, 2)): return false

    await activate_menu_item("Image", "Resize Canvas...")
    width.value = 13
    height.value = 19
    await press_button(["ResizeCanvasPopup", "Resize"])
    if not image_size_is(Vector2i(13, 19)): return false
    if not pixel_is_tool_color(Vector2i(2, 2)): return false

    await activate_menu_item("Image", "Resize Canvas...")
    width.value = 13
    height.value = 13
    x_offset.value = 1
    y_offset.value = 2
    await press_button(["ResizeCanvasPopup", "Resize"])
    if not image_size_is(Vector2i(13, 13)): return false
    if not pixel_is_tool_color(Vector2i(3, 4)): return false

    await activate_menu_item("Image", "Resize Canvas...")
    width.value = 19
    height.value = 19
    x_offset.value = -2
    y_offset.value = -1
    await press_button(["ResizeCanvasPopup", "Resize"])
    if not image_size_is(Vector2i(19, 19)): return false
    if not pixel_is_tool_color(Vector2i(1, 3)): return false

    await activate_menu_item("Image", "Resize Canvas...")
    width.value = 19
    height.value = 19
    x_offset.value = 1
    y_offset.value = 1
    await press_button(["ResizeCanvasPopup", "Resize"])
    if not image_size_is(Vector2i(19, 19)): return false
    if not pixel_is_tool_color(Vector2i(2, 4)): return false

    return true
