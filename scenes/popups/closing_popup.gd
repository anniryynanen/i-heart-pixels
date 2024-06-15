class_name ClosingPopup
extends Window


func _init() -> void:
    close_requested.connect(hide)


func _unhandled_key_input(event: InputEvent) -> void:
    var key: InputEventKey = event as InputEventKey

    if key.pressed and key.physical_keycode == KEY_ESCAPE:
        hide()
        get_viewport().set_input_as_handled()
