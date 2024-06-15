extends Node

const PEN = KEY_E
const COLOR_SAMPLER = KEY_ALT
const COLOR_PICKER = KEY_F


func get_key_label(key: Key) -> String:
    return OS.get_keycode_string(DisplayServer.keyboard_get_label_from_physical(key))
