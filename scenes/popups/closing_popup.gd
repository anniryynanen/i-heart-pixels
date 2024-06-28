class_name ClosingPopup
extends Window


func _init() -> void:
    wrap_controls = true
    transient = true
    unresizable = true
    popup_window = true

    close_requested.connect(hide)
    visibility_changed.connect(_on_visibility_changed)


func _unhandled_key_input(event: InputEvent) -> void:
    var key: InputEventKey = event as InputEventKey

    if key.pressed and key.physical_keycode == KEY_ESCAPE:
        hide()
        get_viewport().set_input_as_handled()


func _on_visibility_changed() -> void:
    if visible:
        Globals.show_mouse_eater.emit(hide)
    else:
        Globals.hide_mouse_eater.emit()
