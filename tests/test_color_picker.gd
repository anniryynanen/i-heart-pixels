extends Test


func should_pick_colors() -> bool:
    var popup: IHPColorPicker = find_node("ColorPickerPopup") as IHPColorPicker

    await press_key(Controls.COLOR_PICKER)
    if not is_visible(popup): return false

    await press_key(Controls.COLOR_PICKER)
    if not is_not_visible(popup): return false

    await press_key(Controls.COLOR_PICKER)
    await press_key(KEY_ESCAPE)
    if not is_not_visible(popup): return false

    await press_key(Controls.COLOR_PICKER)
    var window_id: int = popup.get_window_id()
    if not picker_color_param_is(OKColor.Param.LIGHTNESS, 20): return false

    await click(Vector2(360, 250), window_id)
    if not picker_color_param_is(OKColor.Param.LIGHTNESS, 20): return false

    await click(Vector2(500, 250), window_id)
    if not picker_color_param_is(OKColor.Param.LIGHTNESS, 67): return false

    await hold_mouse(Vector2(500, 250), window_id)
    await move_mouse(Vector2(480, 250), window_id)
    await release_mouse(window_id)
    if not picker_color_param_is(OKColor.Param.LIGHTNESS, 59): return false

    await hold_mouse(Vector2(360, 250), window_id)
    await move_mouse(Vector2(400, 250), window_id)
    await release_mouse(window_id)
    if not picker_color_param_is(OKColor.Param.LIGHTNESS, 75): return false

    await hold_mouse(Vector2(360, 250), window_id)
    await move_mouse(Vector2(362, 250), window_id)
    await release_mouse(window_id)
    if not picker_color_param_is(OKColor.Param.LIGHTNESS, 25): return false

    await scroll_up(Vector2(400, 250), window_id)
    if not picker_color_param_is(OKColor.Param.LIGHTNESS, 26): return false

    await scroll_down(Vector2(400, 250), window_id)
    if not picker_color_param_is(OKColor.Param.LIGHTNESS, 25): return false

    await press_button("LastColor")
    if not picker_color_param_is(OKColor.Param.LIGHTNESS, 20): return false

    var hex: LineEdit = find_node(["ColorPickerPopup", "Hex"]) as LineEdit

    if not tool_color_param_is(OKColor.Param.LIGHTNESS, 20): return false
    if not input_value_is(hex, "#2e2e2e"): return false

    await scroll_up(Vector2(400, 250), window_id)
    if not tool_color_param_is(OKColor.Param.LIGHTNESS, 21): return false
    if not input_value_is(hex, "#303030"): return false

    hex.grab_focus()
    hex.text = "#2e2e2e"
    if not picker_color_param_is(OKColor.Param.LIGHTNESS, 21): return false
    if not tool_color_param_is(OKColor.Param.LIGHTNESS, 21): return false

    hex.text_submitted.emit(hex.text)
    await RenderingServer.frame_post_draw
    if not picker_color_param_is(OKColor.Param.LIGHTNESS, 20): return false
    if not tool_color_param_is(OKColor.Param.LIGHTNESS, 20): return false

    var color: OKColor = Globals.tool_color.duplicate()
    color.l = 0.21
    color.a = 0.5
    Globals.tool_color = color

    await press_key(Controls.COLOR_PICKER)
    await press_key(Controls.COLOR_PICKER)
    if not picker_color_param_is(OKColor.Param.LIGHTNESS, 21): return false
    if not input_value_is(hex, "#303030"): return false

    color.a = 1.0
    await scroll_up(Vector2(400, 250), window_id)
    if not tool_color_is(color.to_rgb()): return false

    hex.text = "#hi"
    hex.text_submitted.emit(hex.text)
    await RenderingServer.frame_post_draw
    if not tool_color_is(color.to_rgb()): return false

    return true
