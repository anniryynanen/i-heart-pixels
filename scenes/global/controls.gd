class_name Controls

const PEN = KEY_E
const COLOR_SAMPLER = KEY_SPACE
const COLOR_REPLACER = KEY_V

const COLOR_PICKER = KEY_F
const NEXT_COLOR = KEY_D
const PREV_COLOR = KEY_A


static func get_key_label(key: Key) -> String:
    return OS.get_keycode_string(DisplayServer.keyboard_get_label_from_physical(key))
