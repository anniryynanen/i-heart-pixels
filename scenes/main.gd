extends Control

var settings_loaded = false
var orig_font_sizes: Dictionary = {}


func _ready() -> void:
    load_settings()


func _notification(what: int) -> void:
    # The app is quitting
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        if get_window().mode == Window.Mode.MODE_WINDOWED:
            Settings.set_value("window", "x", get_window().position.x)
            Settings.set_value("window", "y", get_window().position.y)
            Settings.save()
        get_tree().quit()


func _on_resized() -> void:
    if not settings_loaded:
        return

    if get_window().mode == Window.Mode.MODE_WINDOWED:
        Settings.set_value("window", "x", get_window().position.x)
        Settings.set_value("window", "y", get_window().position.y)
        Settings.set_value("window", "width", get_window().size.x)
        Settings.set_value("window", "height", get_window().size.y)
    Settings.set_value("window", "mode", get_window().mode)
    Settings.queue_save()


func load_settings() -> void:
    Settings.load()

    if not Settings.has_key("app", "scale"):
        Settings.set_key("app", "scale", 1.0)

    set_app_scale(Settings.get_value("app", "scale"))

    if Settings.has_key("window", "x"):
        get_window().position.x = Settings.get_value("window", "x")
        get_window().position.y = Settings.get_value("window", "y")

    var default_width = ProjectSettings.get_setting("display/window/size/viewport_width")
    var default_height = ProjectSettings.get_setting("display/window/size/viewport_height")
    get_window().size.x = Settings.get_value("window", "width", default_width)
    get_window().size.y = Settings.get_value("window", "height", default_height)
    get_window().mode = Settings.get_value("window", "mode", Window.Mode.MODE_WINDOWED)

    settings_loaded = true


func set_app_scale(app_scale: float) -> void:
    for label: Label in find_children("*", "Label"):
        if not label.label_settings:
            continue

        var id: int = label.label_settings.get_instance_id()
        if id not in orig_font_sizes:
            orig_font_sizes[id] = label.label_settings.font_size

        label.label_settings.font_size = roundi(app_scale * orig_font_sizes[id])
