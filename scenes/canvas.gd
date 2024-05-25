extends Control

const ZOOM_STEP = 1.1
const SCROLL_STEP = 18.0
const SHIFT_MULT = 0.3

var pixel_width: float = 80.0
var top_left: Vector2 = Vector2(0.0, 0.0)
var drawing = false


func _ready() -> void:
    pixel_width *= Settings.get_app_scale()


func _process(delta: float) -> void:
    var distance: float = delta * SCROLL_STEP * pixel_width

    if Input.is_physical_key_pressed(KEY_SHIFT):
        distance *= SHIFT_MULT

    if Input.is_physical_key_pressed(KEY_W):
        top_left.y -= distance
        queue_redraw()

    if Input.is_physical_key_pressed(KEY_S):
        top_left.y += distance
        queue_redraw()

    if Input.is_physical_key_pressed(KEY_A):
        top_left.x -= distance
        queue_redraw()

    if Input.is_physical_key_pressed(KEY_D):
        top_left.x += distance
        queue_redraw()


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        _on_button_event(event as InputEventMouseButton)

    elif event is InputEventMouseMotion:
        _on_motion_event(event as InputEventMouseMotion)


func _on_button_event(button: InputEventMouseButton) -> void:
    match button.button_index:
        MOUSE_BUTTON_LEFT:
            start_drawing() if button.pressed else stop_drawing()

        MOUSE_BUTTON_WHEEL_UP:
            if button.pressed:
                var rel_mouse_pos: Vector2 = save_mouse_pos(button.position)

                pixel_width = minf(pixel_width * ZOOM_STEP,
                    DisplayServer.screen_get_size().x / 2.0)

                restore_mouse_pos(button.position, rel_mouse_pos)
                queue_redraw()

        MOUSE_BUTTON_WHEEL_DOWN:
            if button.pressed:
                var rel_mouse_pos: Vector2 = save_mouse_pos(button.position)

                pixel_width = maxf(pixel_width / ZOOM_STEP, 0.1)

                restore_mouse_pos(button.position, rel_mouse_pos)
                queue_redraw()


func _on_motion_event(_motion: InputEventMouseMotion) -> void:
    if drawing:
        $DrawTimer.start()


func save_mouse_pos(mouse_pos: Vector2) -> Vector2:
     return (mouse_pos + top_left) / pixel_width


func restore_mouse_pos(mouse_pos: Vector2, rel_mouse_pos: Vector2) -> void:
    var new_mouse_pos: Vector2 = rel_mouse_pos * pixel_width - top_left
    top_left += new_mouse_pos - mouse_pos


func start_drawing() -> void:
    drawing = true
    Input.use_accumulated_input = false
    $DrawTimer.start()


func stop_drawing() -> void:
    drawing = false
    Input.use_accumulated_input = true
    $DrawTimer.stop()


func _draw() -> void:
    var square_size: Vector2 = Vector2(pixel_width, pixel_width)

    while square_size.x < 10.0 * Settings.get_app_scale():
        square_size *= 2.0

    var offset: Vector2 = Vector2(
        fmod(top_left.x, square_size.x * 2.0),
        fmod(top_left.y, square_size.y * 2.0))

    var light_color: OKColor = OKColor.new(0.0, 0.0, 0.52)
    var dark_color: OKColor = OKColor.new(0.0, 0.0, 0.48)

    var squares: Vector2 = (size + square_size * 5) / square_size
    for x in range(ceili(squares.x)):
        for y in range(ceili(squares.y)):
            var color: OKColor = light_color if x % 2 == y % 2 else dark_color

            var pos: Vector2 = square_size * Vector2(x, y)
            var square: Rect2 = Rect2(pos - offset - square_size * 2.5, square_size)

            if square.intersects(get_rect()):
                draw_rect(square, color.to_rgb())
