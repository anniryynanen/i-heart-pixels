extends Control

var settings_applied_ = false


func _enter_tree() -> void:
    Settings.load_settings()
    set_default_settings_()

    Globals.image_changed.connect(_on_image_changed)
    Globals.unsaved_changes_changed.connect(func(_u): update_title_())
    Globals.current_path_changed.connect(func(_p): update_title_())
    Globals.pen_color_changed.connect(_on_pen_color_changed)
    Globals.app_scale_changed.connect(_on_app_scale_changed)

    get_tree().auto_accept_quit = false


func _ready() -> void:
    %ColorEditor.color_changed.connect(func(c): Globals.pen_color = c)

    apply_settings_()
    update_title_()

    var args: PackedStringArray = OS.get_cmdline_user_args()
    if args.size() > 0:
        var path: String = args[0]
        var image: IHP = IHP.load_from_file(path)
        if image:
            Globals.image = image
            Globals.current_path = path


func _notification(what: int) -> void:
    # The app is quitting
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        if Globals.image.unsaved_changes:
            $UnsavedChangesPopup.popup_centered()
        else:
            quit_()


func _on_resized() -> void:
    if not settings_applied_:
        return

    if get_window().mode == Window.Mode.MODE_WINDOWED:
        Settings.set_value("window", "x", get_window().position.x)
        Settings.set_value("window", "y", get_window().position.y)
        Settings.set_value("window", "width", get_window().size.x)
        Settings.set_value("window", "height", get_window().size.y)

    Settings.set_value("window", "mode", get_window().mode)


func _on_image_changed(image: IHP) -> void:
    %ImageSize.text = "%sx%s" % [image.size.x, image.size.y]


func _on_pen_color_changed(pen_color: OKColor) -> void:
    %ColorEditor.color = pen_color

    var style_box: StyleBoxTexture = %Gradient.get_theme_stylebox("panel") as StyleBoxTexture
    var texture: GradientTexture1D = style_box.texture as GradientTexture1D
    texture.gradient.set_color(1, pen_color.to_rgb())


func _on_main_split_dragged(offset: int) -> void:
    Settings.set_value("panels", "right_width", roundi(-offset / Globals.app_scale))


func _on_app_scale_changed(app_scale: float) -> void:
    %MainSplit.split_offset = roundi(
        -Settings.get_value("panels", "right_width") * Globals.app_scale)


func _on_unsaved_changes_popup_save() -> void:
    %MainMenu.save_unsaved_changes_(quit_)


func set_default_settings_() -> void:
    Settings.set_if_missing("app", "scale", 1.0)
    Settings.set_if_missing("panels", "right_width", 300.0)
    Settings.set_if_missing("pen", "color", OKColor.new(185.0 / 359.0, 0.4, 0.69))


func apply_settings_() -> void:
    if Settings.has_value("window", "width"):
        get_window().size.x = Settings.get_value("window", "width")
        get_window().size.y = Settings.get_value("window", "height")

    if Settings.has_value("window", "x"):
        get_window().position.x = Settings.get_value("window", "x")
        get_window().position.y = Settings.get_value("window", "y")

    get_window().mode = Settings.get_value("window", "mode", Window.Mode.MODE_MAXIMIZED)

    %MainSplit.split_offset = -Settings.get_value("panels", "right_width")

    Globals.apply_settings()
    settings_applied_ = true
    AppScale.start.call_deferred()


func update_title_() -> void:
    var title: String = ""

    if Globals.current_path:
        title += Globals.current_path.get_file()
    else:
        title += "[not saved]"

    if Globals.image.unsaved_changes:
        title += "*"

    title += " - " + ProjectSettings.get_setting("application/config/name")
    get_window().title = title


func quit_() -> void:
    if get_window().mode == Window.Mode.MODE_WINDOWED:
        Settings.set_value("window", "x", get_window().position.x)
        Settings.set_value("window", "y", get_window().position.y)

    Settings.save_settings()
    get_tree().quit()
