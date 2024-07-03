extends Button

var pressed_callbacks_: Array[Callable]


func _ready() -> void:
    Globals.show_mouse_eater.connect(show_)
    Globals.hide_mouse_eater.connect(hide_)

    # Only needed in web build
    pressed.connect(func() -> void: pressed_callbacks_[-1].call())


func show_(on_pressed: Callable) -> void:
    pressed_callbacks_.append(on_pressed)
    visible = true


func hide_() -> void:
    pressed_callbacks_.pop_back()

    if pressed_callbacks_.is_empty():
        visible = false
