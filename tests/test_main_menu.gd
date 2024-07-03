extends Test

func should_open_and_close_popups() -> bool:
    await activate_menu_item("View", "App Scale...")
    if not is_visible("AppScalePopup"): return false

    await click(Vector2(10, 10))
    if not is_not_visible("AppScalePopup"): return false

    await activate_menu_item("Image", "Resize Canvas...")
    if not is_visible("ResizeCanvasPopup"): return false

    await press_key(KEY_ESCAPE)
    if not is_not_visible("ResizeCanvasPopup"): return false

    await activate_menu_item("Info", "Controls...")
    if not is_visible("ControlsPopup"): return false
    await press_key(KEY_ESCAPE)

    await activate_menu_item("Info", "About...")
    if not is_visible("AboutPopup"): return false
    await press_key(KEY_ESCAPE)

    return true


func should_apply_scale() -> bool:
    await activate_menu_item("View", "App Scale...")
    var slider: Slider = find_node("AppScaleSlider") as Slider
    slider.value += slider.step
    if not is_equal(Globals.app_scale, 1.1, "Globals.app_scale"): return false
    return true


func should_save_and_load_pngs() -> bool:
    return await load_and_save_("test.png")


func should_save_and_load_ihps() -> bool:
    return await load_and_save_("test.ihp")


func load_and_save_(path: String) -> bool:
    if not title_is("[not saved] - " + app_name_): return false

    await click(pixel_pos(Vector2i(1, 0)))
    if not pixel_is_tool_color(Vector2i(1, 0)): return false
    if not title_is("[not saved]* - " + app_name_): return false

    await activate_menu_item("File", "Save")
    if not is_visible(save_dialog_): return false
    await select_file_to_save(path)
    if not title_is(path + " - " + app_name_): return false

    await press_button(["Toolbar", "Eraser", "Button"])
    await click(pixel_pos(Vector2i(1, 0)))
    if not pixel_is_transparent(Vector2i(1, 0)): return false
    if not title_is(path + "* - " + app_name_): return false

    Globals.image.untouched = true
    await activate_menu_item("File", "Open...")
    if not is_visible(open_dialog_): return false
    await select_file_to_open(path)
    if not pixel_is_tool_color(Vector2i(1, 0)): return false
    if not title_is(path + " - " + app_name_): return false

    await activate_menu_item("Image", "Resize Canvas...")
    find_node(["ResizeCanvasPopup", "Width"]).value = 8
    find_node(["ResizeCanvasPopup", "Height"]).value = 8
    await press_button(["ResizeCanvasPopup", "Resize"])
    if not title_is(path + "* - " + app_name_): return false

    await activate_menu_item("File", "Save")
    if not is_not_visible(save_dialog_): return false
    if not title_is(path + " - " + app_name_): return false

    await activate_menu_item("Image", "Resize Canvas...")
    find_node(["ResizeCanvasPopup", "Width"]).value = 4
    find_node(["ResizeCanvasPopup", "Height"]).value = 4
    await press_button(["ResizeCanvasPopup", "Resize"])

    Globals.image.untouched = true
    await activate_menu_item("File", "Open...")
    if not is_visible(open_dialog_): return false
    await select_file_to_open(path)
    if not image_size_is(Vector2i(8, 8)): return false

    await activate_menu_item("File", "Save As...")
    if not is_visible(save_dialog_): return false
    save_dialog_.hide()

    return true


func should_export_pngs() -> bool:
    await activate_menu_item("File", "Save")
    if not is_visible(save_dialog_): return false
    await select_file_to_save("test.ihp")

    await click(pixel_pos(Vector2i(2, 0)))
    if not title_is("test.ihp* - " + app_name_): return false

    await activate_menu_item("File", "Export")
    if not is_visible(export_dialog_): return false
    await select_file_to_export("export1.png")
    if not title_is("test.ihp* - " + app_name_): return false

    await click(pixel_pos(Vector2i(3, 0)))

    Globals.image.untouched = true
    await activate_menu_item("File", "Open...")
    await select_file_to_open("export1.png")
    if not pixel_is_transparent(Vector2i(3, 0)): return false
    if not title_is("export1.png - " + app_name_): return false

    await click(pixel_pos(Vector2i(3, 0)))

    await activate_menu_item("File", "Save As...")
    await select_file_to_save("test.ihp")
    if not title_is("test.ihp - " + app_name_): return false

    await click(pixel_pos(Vector2i(4, 0)))

    await activate_menu_item("File", "Export")
    if not is_not_visible(export_dialog_): return false
    if not title_is("test.ihp* - " + app_name_): return false

    Globals.image.untouched = true
    await activate_menu_item("File", "Open...")
    await select_file_to_open("export1.png")
    if not pixel_is_tool_color(Vector2i(3, 0)): return false
    if not pixel_is_tool_color(Vector2i(4, 0)): return false
    if not title_is("export1.png - " + app_name_): return false

    await activate_menu_item("File", "Save As...")
    await select_file_to_save("test.ihp")
    if not title_is("test.ihp - " + app_name_): return false

    await activate_menu_item("File", "Export As...")
    if not is_visible(export_dialog_): return false
    export_dialog_.hide()

    return true


func should_load_jpgs() -> bool:
    await activate_menu_item("File", "Open...")
    await select_file_to_open("test.jpg")
    if not title_is("test.png - " + app_name_): return false

    return true


func should_warn_on_close_unsaved() -> bool:
    await click(pixel_pos(Vector2i(1, 0)))
    activate_menu_item("File", "Close")
    if not is_visible("UnsavedChangesPopup"): return false

    await press_button(["UnsavedChangesPopup", "Cancel"])
    if not is_not_visible("UnsavedChangesPopup"): return false

    await press_button(["UnsavedChangesPopup", "Save"])
    if not is_not_visible("UnsavedChangesPopup"): return false
    if not is_visible("SaveDialog"): return false

    return true
