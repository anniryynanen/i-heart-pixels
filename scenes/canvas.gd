extends Control

const ZOOM_STEP = 1.4
const BASE_PAN_STEP = 1.0

var pixel_width: float = 80.0
var top_left: Vector2 = Vector2(0.0, 0.0)
var current_pixel: Vector2i = Vector2i(-1, -1)
var pan_step: float = BASE_PAN_STEP
var dragging = false

var hovering = false
var drawing = false

var image: Image = Image.create(10, 10, false, Image.Format.FORMAT_RGBA8)
var image_changed = false
var texture: ImageTexture = ImageTexture.create_from_image(image)


func _ready() -> void:
    Globals.focus_lost.connect(_on_focus_lost)
    Globals.app_scale_changed.connect(_on_app_scale_changed)


func _process(delta: float) -> void:
    # Don't pan if some UI element has focus
    if get_viewport().gui_get_focus_owner() != null:
        return

    var distance: float = delta * pan_step * (size.x / pixel_width) * pixel_width

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
            start_drawing(button.position) if button.pressed else stop_drawing()

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

        MOUSE_BUTTON_MIDDLE:
            start_dragging() if button.pressed else stop_dragging()


func _on_motion_event(motion: InputEventMouseMotion) -> void:
    var pixel_moved = update_current_pixel(motion.position)

    if dragging:
        top_left -= motion.relative
        queue_redraw()

    if drawing:
        $DrawTimer.start()
        if pixel_moved and Rect2(Vector2(0.0, 0.0), size).has_point(motion.position):
            draw_pixel(current_pixel)


func _on_focus_lost() -> void:
    if drawing:
        stop_drawing()

    if dragging:
        stop_dragging()

    if hovering:
        stop_hovering()


func _on_app_scale_changed(app_scale: float) -> void:
    pan_step = BASE_PAN_STEP * app_scale
    queue_redraw()


func save_mouse_pos(mouse_pos: Vector2) -> Vector2:
     return (mouse_pos + top_left) / pixel_width


func restore_mouse_pos(mouse_pos: Vector2, rel_mouse_pos: Vector2) -> void:
    var new_mouse_pos: Vector2 = rel_mouse_pos * pixel_width - top_left
    top_left += new_mouse_pos - mouse_pos


func start_hovering() -> void:
    hovering = true
    queue_redraw()


func stop_hovering() -> void:
    hovering = false
    queue_redraw()


func start_dragging() -> void:
    dragging = true


func stop_dragging() -> void:
    dragging = false


func start_drawing(mouse_pos: Vector2) -> void:
    drawing = true
    Input.use_accumulated_input = false
    $DrawTimer.start()

    update_current_pixel(mouse_pos)
    draw_pixel(current_pixel)


func stop_drawing() -> void:
    drawing = false
    Input.use_accumulated_input = true
    $DrawTimer.stop()


func update_current_pixel(mouse_pos: Vector2) -> bool:
    var mouse_pixel: Vector2i = ((mouse_pos + top_left) / pixel_width).floor()
    if mouse_pixel != current_pixel:
        current_pixel = mouse_pixel
        queue_redraw()
        return true
    return false


func draw_pixel(pixel: Vector2i) -> void:
    if pixel_in_image(pixel):
        image.set_pixel(pixel.x, pixel.y, Globals.pen_color.to_rgb())
        image_changed = true
        queue_redraw()


func pixel_in_image(pixel: Vector2i) -> bool:
    return Rect2i(Vector2i(0, 0), image.get_size()).has_point(pixel)


func _draw() -> void:
    draw_background_alpha()

    if image_changed:
        texture.update(image)
        image_changed = false

    var texture_size: Vector2 = Vector2(pixel_width, pixel_width) * texture.get_size()
    draw_texture_rect(texture, Rect2(-top_left, texture_size), false)

    if hovering:
        draw_hover_highlight()


func draw_background_alpha() -> void:
    var square_size: Vector2 = Vector2(pixel_width, pixel_width) * Globals.app_scale

    while square_size.x < 10.0 * Globals.app_scale:
        square_size *= 2.0

    var offset: Vector2 = Vector2(
        fmod(top_left.x, square_size.x * 2.0),
        fmod(top_left.y, square_size.y * 2.0))

    var light_color: OKColor = OKColor.new(0.0, 0.0, 0.52)
    var dark_color: OKColor = OKColor.new(0.0, 0.0, 0.48)

    var squares: Vector2 = (size + square_size * 5) / square_size
    for x in range(ceili(squares.x)):
        for y in range(ceili(squares.y)):
            var square_color: OKColor = light_color if x % 2 == y % 2 else dark_color

            var pos: Vector2 = square_size * Vector2(x, y)
            var square: Rect2 = Rect2(pos - offset - square_size * 2.5, square_size)

            if square.intersects(get_rect()):
                draw_rect(square, square_color.to_rgb())


func draw_hover_highlight() -> void:
    var pixel_color: OKColor = OKColor.new()
    if pixel_in_image(current_pixel):
        pixel_color = OKColor.from_rgb(image.get_pixel(current_pixel.x, current_pixel.y))

    var line_width: float = Globals.app_scale

    var hl_pos: Vector2 = current_pixel * pixel_width - top_left
    hl_pos += Vector2(line_width / 2.0, line_width / 2.0)
    var hl_size: Vector2 = Vector2(pixel_width - line_width, pixel_width - line_width)

    draw_rect(Rect2(hl_pos, hl_size),
        ColorEditor.get_line_color(pixel_color).to_rgb(), false, line_width)
