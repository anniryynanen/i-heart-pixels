class_name Controls

const PEN = KEY_F
const COLOR_SAMPLER = KEY_SPACE
const FILL = KEY_G

const COLOR_PICKER = KEY_V
const NEXT_COLOR = KEY_D
const PREV_COLOR = KEY_A
const RESELECT_COLOR = KEY_S


static func get_key_label(key: Key) -> String:
    if OS.has_feature("web"):
        return OS.get_keycode_string(key)
    else:
        return OS.get_keycode_string(DisplayServer.keyboard_get_label_from_physical(key))
