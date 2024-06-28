extends Node

signal loading_done
signal image_changed(image: IHP)
signal unsaved_changes_changed(unsaved_changes: bool)
signal current_path_changed(current_path: String)

signal tool_changed(tool: Tool.Type)
signal tool_color_changed(color: OKColor)
signal pen_size_changed(pen_size: int)
signal app_scale_changed(app_scale: float)
signal keyboard_layout_changed
signal focus_lost

@warning_ignore("unused_signal") signal show_notification(message: String)
@warning_ignore("unused_signal") signal show_mouse_eater(pressed: Callable)
@warning_ignore("unused_signal") signal hide_mouse_eater

const ERROR_TITLE = ":("
const GITHUB_URL = "https://github.com/anniryynanen/i-heart-pixels"

var loading = true:
    set(value):
        if loading and not value:
            loading = false
            loading_done.emit()

var image: IHP:
    set(value):
        if image:
            image.unsaved_changes_changed.disconnect(emit_unsaved_changes_changed_)

        image = value
        image.unsaved_changes_changed.connect(emit_unsaved_changes_changed_)
        image_changed.emit(image)

var current_path: String:
    set(value):
        current_path = value
        current_path_changed.emit(current_path)

var tool: Tool.Type:
    set(value):
        tool = value
        tool_changed.emit(tool)

var tool_color: OKColor:
    set(value):
        tool_color = value
        Settings.set_value("tool", "color", tool_color)
        tool_color_changed.emit(tool_color)

var pen_size: int:
    set(value):
        pen_size = value
        Settings.set_value("pen", "size", pen_size)
        pen_size_changed.emit(pen_size)

var app_scale: float:
    set(value):
        app_scale = value
        Settings.set_value("app", "scale", app_scale)
        app_scale_changed.emit(app_scale)

var last_keyboard_layout_: String


func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        focus_lost.emit()


func _on_keyboard_timer_timeout() -> void:
    var new_layout: String = DisplayServer.keyboard_get_layout_name(
        DisplayServer.keyboard_get_current_layout())

    if new_layout != last_keyboard_layout_:
        last_keyboard_layout_ = new_layout
        keyboard_layout_changed.emit()


func apply_settings() -> void:
    image = IHP.new(Vector2i(16, 16))
    pen_size = Settings.get_value("pen", "size", 1)
    app_scale = Settings.get_value("app", "scale", 1.0)

    $KeyboardTimer.timeout.emit()
    $KeyboardTimer.start()


func load_image(path: String) -> void:
    var loaded_image: IHP = IHP.load_from_file(path)
    if loaded_image:
        image = loaded_image

        if not path.to_lower().ends_with(".png") and not path.to_lower().ends_with(".ihp"):
            if path.get_file().contains("."):
                path = path.rsplit(".", false, 1)[0] + ".png"
            else:
                path += ".png"

        Globals.current_path = path


func emit_unsaved_changes_changed_(unsaved_changes: bool) -> void:
    unsaved_changes_changed.emit(unsaved_changes)
