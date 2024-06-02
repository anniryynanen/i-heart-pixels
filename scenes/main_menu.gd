extends MenuBar

enum File {
    NEW = 0,
    OPEN = 1,
    SAVE = 3,
    SAVE_AS = 4,
    EXPORT = 6,
    EXPORT_AS = 7,
    QUIT = 9
}

enum View {
    APP_SCALE = 0
}


func _ready() -> void:
    setup_shortcut(File.NEW, KEY_N)
    setup_shortcut(File.OPEN, KEY_O)
    setup_shortcut(File.SAVE, KEY_S)
    setup_shortcut(File.SAVE_AS, KEY_S, true)
    setup_shortcut(File.EXPORT, KEY_E)
    setup_shortcut(File.EXPORT_AS, KEY_E, true)
    setup_shortcut(File.QUIT, KEY_Q,)


func setup_shortcut(index: int, keycode: Key, shift_pressed: bool = false) -> void:
    var key: InputEventKey = InputEventKey.new()
    key.keycode = keycode
    key.ctrl_pressed = true
    key.shift_pressed = shift_pressed

    var shortcut: Shortcut = Shortcut.new()
    shortcut.events.append(key)
    $File.set_item_shortcut(index, shortcut, true)


func _on_file_index_pressed(index: int) -> void:
    match index:
        File.NEW:
            OS.create_instance([])

        File.OPEN:
            $OpenDialog.popup_centered()

        File.SAVE:
            if Globals.current_path:
                Globals.image.save_to_file(Globals.current_path)
            else:
                $SaveDialog.popup_centered()

        File.SAVE_AS:
            $SaveDialog.popup_centered()

        File.EXPORT:
            if Globals.current_path:
                var export_path: String = Cache.get_export_path(Globals.current_path)
                if export_path:
                    export(export_path)
                else:
                    $ExportDialog.popup_centered()
            else:
                $ExportDialog.popup_centered()

        File.EXPORT_AS:
            $ExportDialog.popup_centered()

        File.QUIT:
            get_tree().root.propagate_notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)


func _on_view_index_pressed(index: int) -> void:
    match index:
        View.APP_SCALE:
            $AppScalePopup.popup_centered()


func open(path: String) -> void:
    if Globals.image.empty:
        var image: IHP = IHP.load_from_file(path)
        if image:
            Globals.image = image
            Globals.current_path = path
    else:
        OS.create_instance(["--", path])


func save(path: String) -> void:
    if not path.to_lower().ends_with(".ihp"):
        path += ".ihp"

    var success = Globals.image.save_to_file(path)
    if success:
        Globals.current_path = path


func export(path: String) -> void:
    if not path.to_lower().ends_with(".png"):
        path += ".png"

    var err: Error = Globals.image.current_layer.image.save_png(path)
    if err:
        OS.alert("Couldn't save %s (%s)" % [path, error_string(err)], Globals.ERROR_TITLE)
        return

    if Globals.current_path:
        Cache.set_export_path(Globals.current_path, path)
