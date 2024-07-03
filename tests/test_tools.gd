extends Test


func should_select_tools_with_keys() -> bool:
    if not tool_is(Tool.PEN): return false

    await press_key(Controls.PEN)
    if not tool_is(Tool.ERASER): return false

    await hold_key(Controls.COLOR_SAMPLER)
    if not tool_is(Tool.COLOR_SAMPLER): return false

    await release_key(Controls.COLOR_SAMPLER)
    if not tool_is(Tool.ERASER): return false

    await press_key(Controls.PEN)
    if not tool_is(Tool.PEN): return false

    await press_key(Controls.FILL)
    if not tool_is(Tool.FILL): return false

    await press_key(Controls.FILL)
    if not tool_is(Tool.CLEAR): return false

    await press_key(Controls.PEN)
    if not tool_is(Tool.PEN): return false

    await press_key(Controls.FILL)
    if not tool_is(Tool.FILL): return false

    return true


func should_draw_pixels() -> bool:
    if not pixel_is_transparent(Vector2i(1, 0)): return false

    await click(pixel_pos(Vector2i(1, 0)))
    if not pixel_is_tool_color(Vector2i(1, 0)): return false

    await press_button(["Toolbar", "Eraser", "Button"])
    await click(pixel_pos(Vector2i(1, 0)))
    if not pixel_is_transparent(Vector2i(1, 0)): return false

    await press_button(["Toolbar", "Pen", "Button"])
    await hold_mouse(pixel_pos(Vector2i(1, 0)))
    await move_mouse(pixel_pos(Vector2i(1, 1)))
    await release_mouse()
    if not pixel_is_tool_color(Vector2i(1, 0)): return false
    if not pixel_is_tool_color(Vector2i(1, 1)): return false

    await hold_mouse(pixel_pos(Vector2i(2, 0)))
    await move_mouse(pixel_pos(Vector2i(2, 2)))
    await release_mouse()
    if not pixel_is_tool_color(Vector2i(2, 0)): return false
    # Filling line in is not implemented yet
    #if not pixel_is_tool_color(Vector2i(2, 1)): return false
    if not pixel_is_tool_color(Vector2i(2, 2)): return false

    var slider: Slider = find_node(["PenSize", "Slider"]) as Slider
    slider.value += slider.step
    slider.value += slider.step
    await click(pixel_pos(Vector2i(2, 2)))
    if not pixel_is_transparent(Vector2i(0, 0)): return false
    if not pixel_is_tool_color(Vector2i(0, 1)): return false

    return true


func should_sample_colors() -> bool:
    await press_button(["Toolbar", "ColorSampler", "Button"])
    await click(pixel_pos(Vector2i(1, 0)))
    if not tool_color_is(Color(0, 0, 0, 1)): return false

    await press_button(["Toolbar", "Pen", "Button"])
    await click(pixel_pos(Vector2i(1, 0)))
    if not tool_color_is(Globals.tool_color.to_rgb()): return false

    return true


func should_fill_areas() -> bool:
    await press_button(["Toolbar", "Fill", "Button"])
    await click(pixel_pos(Vector2i(0, 0)))
    if not pixel_is_tool_color(Vector2i(0, 0)): return false
    if not pixel_is_tool_color(Vector2i(1, 0)): return false

    await press_button(["Toolbar", "Clear", "Button"])
    await click(pixel_pos(Vector2i(0, 0)))
    if not pixel_is_transparent(Vector2i(0, 0)): return false
    if not pixel_is_transparent(Vector2i(1, 0)): return false

    await press_button(["Toolbar", "Pen", "Button"])
    await click(pixel_pos(Vector2i(0, 0)))
    await click(pixel_pos(Vector2i(0, 1)))
    await click(pixel_pos(Vector2i(1, 2)))
    await click(pixel_pos(Vector2i(3, 2)))
    if not pixel_is_tool_color(Vector2i(0, 0)): return false
    if not pixel_is_tool_color(Vector2i(0, 1)): return false
    if not pixel_is_tool_color(Vector2i(1, 2)): return false
    if not pixel_is_tool_color(Vector2i(3, 2)): return false

    await press_button(["Toolbar", "Clear", "Button"])
    await click(pixel_pos(Vector2i(0, 0)))
    if not pixel_is_transparent(Vector2i(0, 0)): return false
    if not pixel_is_transparent(Vector2i(0, 1)): return false
    if not pixel_is_transparent(Vector2i(1, 2)): return false
    if not pixel_is_tool_color(Vector2i(3, 2)): return false

    await press_button(["Toolbar", "Fill", "Button"])
    await click(pixel_pos(Vector2i(3, 2)))
    if not pixel_is_transparent(Vector2i(3, 3)): return false

    return true
