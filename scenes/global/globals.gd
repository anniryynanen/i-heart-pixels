extends Node

signal loading_done
signal image_changed(image: IHP)
signal unsaved_changes_changed(unsaved_changes: bool)
signal current_path_changed(current_path: String)

signal tool_changed(tool: Tool.Type)
@warning_ignore("unused_signal")
signal color_sampled(color: OKColor)
signal app_scale_changed(app_scale: float)
signal keyboard_layout_changed
signal focus_lost

@warning_ignore("unused_signal")
signal show_notification(message: String)

const ERROR_TITLE = ":("

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

var tool_color: OKColor

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
    app_scale = Settings.get_value("app", "scale")

    $KeyboardTimer.timeout.emit()
    $KeyboardTimer.start()


func emit_unsaved_changes_changed_(unsaved_changes: bool) -> void:
    unsaved_changes_changed.emit(unsaved_changes)
