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

var image: Image = Image.create(16, 16, false, Image.Format.FORMAT_RGBA8)
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

    if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
        top_left.y -= distance
        update_position()

    if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
        top_left.y += distance
        update_position()

    if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
        top_left.x -= distance
        update_position()

    if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
        top_left.x += distance
        update_position()


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
                update_position()

        MOUSE_BUTTON_WHEEL_DOWN:
            if button.pressed:
                var rel_mouse_pos: Vector2 = save_mouse_pos(button.position)

                pixel_width = maxf(pixel_width / ZOOM_STEP, 0.1)

                restore_mouse_pos(button.position, rel_mouse_pos)
                update_position()

        MOUSE_BUTTON_MIDDLE:
            start_dragging() if button.pressed else stop_dragging()


func _on_motion_event(motion: InputEventMouseMotion) -> void:
    var pixel_moved = update_current_pixel(motion.position)

    if dragging:
        top_left -= motion.relative
        update_position()

    if drawing:
        $DrawTimer.start()
        if pixel_moved and Rect2(Vector2(0.0, 0.0), size).has_point(motion.position):
            draw_pixel(current_pixel)


func _on_h_scroll_value_changed(value: float) -> void:
    top_left.x = value
    update_position()


func _on_v_scroll_value_changed(value: float) -> void:
    top_left.y = value
    update_position()


func _on_resized() -> void:
    update_position()


func _on_app_scale_changed(app_scale: float) -> void:
    pan_step = BASE_PAN_STEP * app_scale
    update_position()


func _on_focus_lost() -> void:
    if drawing:
        stop_drawing()

    if dragging:
        stop_dragging()

    if hovering:
        stop_hovering()


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


func get_image_size() -> Vector2:
    return Vector2(pixel_width, pixel_width) * texture.get_size()


func update_position() -> void:
    var min_top_left: Vector2 = -size * 0.9
    var max_top_left: Vector2 = size * 0.9 + (get_image_size() - size)

    top_left.x = clampf(top_left.x, min_top_left.x, max_top_left.x)
    top_left.y = clampf(top_left.y, min_top_left.y, max_top_left.y)

    %HScroll.min_value = min_top_left.x
    %HScroll.max_value = max_top_left.x + size.x
    %HScroll.page = size.x
    %HScroll.set_value_no_signal(top_left.x)

    %VScroll.min_value = min_top_left.y
    %VScroll.max_value = max_top_left.y + size.y
    %VScroll.page = size.y
    %VScroll.set_value_no_signal(top_left.y)

    (func():
        %HScroll.size.x = (size.x - %Corner.size.x) / Globals.app_scale
        %VScroll.size.y = (size.y - %Corner.size.y) / Globals.app_scale
    ).call_deferred()

    queue_redraw()


func _draw() -> void:
    draw_background_alpha()

    if image_changed:
        texture.update(image)
        image_changed = false

    draw_texture_rect(texture, Rect2(-top_left, get_image_size()), false)
    draw_image_outline()

    if hovering:
        draw_hover_highlight()


func draw_background_alpha() -> void:
    var square_size: Vector2 = Vector2(pixel_width, pixel_width) * Globals.app_scale

    while square_size.x < 10.0 * Globals.app_scale:
        square_size *= 2.0

    var offset: Vector2 = Vector2(square_size.x * 2.0, square_size.y * 2.0)

    var light_color: OKColor = OKColor.new(0.0, 0.0, 0.52)
    var dark_color: OKColor = OKColor.new(0.0, 0.0, 0.48)

    var image_size: Vector2 = get_image_size()
    var image_area: Rect2 = Rect2(-top_left, image_size)

    var squares: Vector2 = (image_size + square_size * 5) / square_size
    for x in range(ceili(squares.x)):
        for y in range(ceili(squares.y)):
            var square_color: OKColor = light_color if x % 2 == y % 2 else dark_color

            var pos: Vector2 = -top_left + square_size * Vector2(x, y)
            var square: Rect2 = Rect2(pos - offset - square_size * 2.5, square_size)

            if square.intersects(image_area):
                draw_rect(square.intersection(image_area), square_color.to_rgb())


func draw_image_outline() -> void:
    var line_width: int = roundi(Globals.app_scale)
    var image_size: Vector2 = get_image_size()

    draw_rect(Rect2(
        -top_left.x - line_width / 2.0,
        -top_left.y - line_width / 2.0,
        image_size.x + line_width,
        image_size.y + line_width),
        OKColor.new(0.0, 0.0, 0.6).to_rgb(), false, line_width)


func draw_hover_highlight() -> void:
    if not pixel_in_image(current_pixel):
        return

    var pixel_color: OKColor = OKColor.from_rgb(
        image.get_pixel(current_pixel.x, current_pixel.y))
    var line_width: int = roundi(Globals.app_scale)

    var hl_pos: Vector2 = current_pixel * pixel_width - top_left
    hl_pos += Vector2(line_width / 2.0, line_width / 2.0)
    var hl_size: Vector2 = Vector2(pixel_width - line_width, pixel_width - line_width)

    draw_rect(Rect2(hl_pos, hl_size),
        ColorEditor.get_line_color(pixel_color).to_rgb(), false, line_width)
