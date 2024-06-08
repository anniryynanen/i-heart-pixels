extends Node

signal image_changed(image: IHP)
signal unsaved_changes_changed(unsaved_changes: bool)
signal current_path_changed(current_path: String)

signal tool_changed(tool: Tools.ToolType)
signal tool_color_changed(pen_color: OKColor)
signal app_scale_changed(app_scale: float)
signal keyboard_layout_changed
signal focus_lost

const ERROR_TITLE = ":("

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

var tool: Tools.ToolType:
    set(value):
        tool = value
        tool_changed.emit(tool)

var tool_color: OKColor:
    set(value):
        tool_color = value
        Settings.set_value("tool", "color", tool_color)
        tool_color_changed.emit(tool_color)

var app_scale: float:
    set(value):
        app_scale = value
        Settings.set_value("app", "scale", app_scale)
        app_scale_changed.emit(app_scale)

var last_keyboard_layout_: int = -1


func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        focus_lost.emit()


func _on_check_keyboard_timeout() -> void:
    var new_layout: int = DisplayServer.keyboard_get_current_layout()
    if new_layout != last_keyboard_layout_:
        last_keyboard_layout_ = new_layout
        keyboard_layout_changed.emit()


func apply_settings() -> void:
    image = IHP.new(Vector2i(16, 16))

    tool_color = Settings.get_value("tool", "color")
    app_scale = Settings.get_value("app", "scale")

    $CheckKeyboard.timeout.emit()
    $CheckKeyboard.start()


func emit_unsaved_changes_changed_(unsaved_changes: bool) -> void:
    unsaved_changes_changed.emit(unsaved_changes)
