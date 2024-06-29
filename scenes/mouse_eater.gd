extends Button

var pressed_callbacks_: Array[Callable]


func _ready() -> void:
    Globals.show_mouse_eater.connect(func(on_pressed: Callable):
        pressed_callbacks_.append(on_pressed)
        visible = true
    )

    Globals.hide_mouse_eater.connect(func():
        pressed_callbacks_.pop_back()

        if pressed_callbacks_.is_empty():
            visible = false
    )

    # Only needed in web build
    pressed.connect(func(): pressed_callbacks_[-1].call())
