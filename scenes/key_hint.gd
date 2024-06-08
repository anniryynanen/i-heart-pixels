class_name KeyHint
extends Panel

var physical_keycode: int:
    set(value):
        physical_keycode = value
        %Label.text = get_label()

        shorten_dvorak_label_(value, KEY_E, KEY_PERIOD, ".")


func get_label() -> String:
    return OS.get_keycode_string(
        DisplayServer.keyboard_get_label_from_physical(physical_keycode))


func shorten_dvorak_label_(physical_key: int, qwerty_key: int, dvorak_key: int,
        label_: String) -> void:

    if physical_key == qwerty_key and \
            DisplayServer.keyboard_get_keycode_from_physical(qwerty_key) == dvorak_key:
        %Label.text = label_
