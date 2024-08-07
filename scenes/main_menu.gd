extends MenuBar

enum File {
    NEW = 1,
    OPEN = 2,
    SAVE = 3,
    SAVE_AS = 4,
    EXPORT = 5,
    EXPORT_AS = 6,
    CLOSE = 7
}

enum View {
    APP_SCALE = 1
}

enum Image_ {
    RESIZE_CANVAS = 1
}

enum Info {
    CONTROLS = 1,
    ABOUT = 2
}

var on_saved_: Callable


func _ready() -> void:
    setup_shortcut_($File, File.SAVE, KEY_S)
    setup_shortcut_($File, File.SAVE_AS, KEY_S, true)
    setup_shortcut_($File, File.EXPORT, KEY_E)
    setup_shortcut_($File, File.EXPORT_AS, KEY_E, true)

    if OS.has_feature("web"):
        $File.remove_item($File.get_item_index(File.NEW))
        $File.remove_item($File.get_item_index(File.CLOSE) - 1)
        $File.remove_item($File.get_item_index(File.CLOSE))

        # Not implemented yet
        remove_child($File)
    else:
        # No "open" shortcut in web build, there it fails before first click
        setup_shortcut_($File, File.OPEN, KEY_O)

        setup_shortcut_($File, File.NEW, KEY_N)
        setup_shortcut_($File, File.CLOSE, KEY_W)


func setup_shortcut_(menu: PopupMenu, id: int, keycode: Key, shift_pressed: bool = false) -> void:
    var key: InputEventKey = InputEventKey.new()
    key.keycode = keycode
    key.ctrl_pressed = true
    key.shift_pressed = shift_pressed

    var shortcut: Shortcut = Shortcut.new()
    shortcut.events.append(key)
    menu.set_item_shortcut(menu.get_item_index(id), shortcut, true)


func _on_file_index_pressed(index: int) -> void:
    match $File.get_item_id(index):
        File.NEW:
            OS.create_instance([])

        File.OPEN:
            $OpenDialog.popup_centered()

        File.SAVE:
            save(Globals.current_path)

        File.SAVE_AS:
            show_save_dialog_()

        File.EXPORT:
            if Globals.current_path:
                var export_path: String = Cache.get_export_path(Globals.current_path)
                if export_path:
                    export_(export_path)
                else:
                    $ExportDialog.popup_centered()
            else:
                $ExportDialog.popup_centered()

        File.EXPORT_AS:
            $ExportDialog.popup_centered()

        File.CLOSE:
            get_tree().root.propagate_notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)


func _on_view_index_pressed(index: int) -> void:
    match $View.get_item_id(index):
        View.APP_SCALE:
            $AppScalePopup.popup_centered()


func _on_image_index_pressed(index: int) -> void:
    match $Image.get_item_id(index):
        Image_.RESIZE_CANVAS:
            $ResizeCanvasPopup.popup_centered()


func _on_info_index_pressed(index: int) -> void:
    match $Info.get_item_id(index):
        Info.CONTROLS:
            $ControlsPopup.popup_centered()

        Info.ABOUT:
            $AboutPopup.popup_centered()


func _on_open_dialog_file_selected(path: String) -> void:
    if Globals.image.untouched:
        Globals.load_image(path)
    else:
        OS.create_instance(["--", path])


func _on_save_dialog_file_selected(path: String) -> void:
    save(path, on_saved_)


func save(path: String = "", on_saved: Callable = func() -> void: pass) -> void:
    if not path:
        show_save_dialog_(on_saved)
        return

    var success: bool

    if path.to_lower().ends_with(".ihp"):
        success = Globals.image.save_as_ihp(path)
    else:
        success = Globals.image.save_as_png(path)

    if success:
        Globals.current_path = path
        on_saved.call()


func show_save_dialog_(on_saved: Callable = func() -> void: pass) -> void:
    on_saved_ = on_saved
    $SaveDialog.popup_centered()


func export_(path: String) -> void:
    var success: bool = Globals.image.export(path)
    if success:
        if Globals.current_path:
            Cache.set_export_path(Globals.current_path, path)
