extends Control

const ZOOM_STEP = 1.4
const BASE_PAN_STEP = 1.0

var pixel_width_: float = 80.0
var top_left_: Vector2 = Vector2(0.0, 0.0)
var current_pixel_: Vector2i = Vector2i(-1, -1)
var pan_step_: float = BASE_PAN_STEP
var dragging_ = false
var hovering_ = false
var drawing_ = false
var cursors_: Dictionary

var current_layer_: Image
var current_layer_changed_ = false
var texture_: ImageTexture


func _ready() -> void:
    cursors_[Tools.PEN] = ScalableSVG.new(load(
        "res://icons/phosphor/cursor/cursor-28px-pen-duotone.svg"))
    cursors_[Tools.ERASER] = ScalableSVG.new(load(
        "res://icons/phosphor/cursor/cursor-28px-eraser-duotone.svg"))
    cursors_[Tools.COLOR_PICKER] = ScalableSVG.new(load(
        "res://icons/phosphor/cursor/cursor-28px-eyedropper-duotone.svg"))

    Globals.image_changed.connect(_on_image_changed)
    Globals.tool_changed.connect(func(_t): update_cursor_())
    Globals.app_scale_changed.connect(_on_app_scale_changed)
    Globals.focus_lost.connect(_on_focus_lost)


func _process(delta: float) -> void:
    # Don't pan if some other UI element has focus
    var window_has_focus = DisplayServer.window_is_focused(get_window().get_window_id())
    if not window_has_focus or get_viewport().gui_get_focus_owner() != null:
        return

    if Input.is_key_pressed(KEY_CTRL):
        return

    var distance: float = delta * pan_step_ * (size.x / pixel_width_) * pixel_width_

    if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
        top_left_.y -= distance
        update_position_()

    if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
        top_left_.y += distance
        update_position_()

    if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
        top_left_.x -= distance
        update_position_()

    if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
        top_left_.x += distance
        update_position_()


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        _on_button_event(event as InputEventMouseButton)

    elif event is InputEventMouseMotion:
        _on_motion_event(event as InputEventMouseMotion)


@warning_ignore("standalone_ternary")
func _on_button_event(button: InputEventMouseButton) -> void:
    match button.button_index:
        MOUSE_BUTTON_LEFT:
            start_drawing_(button.position) if button.pressed else stop_drawing_()

        MOUSE_BUTTON_WHEEL_UP:
            if button.pressed:
                var rel_mouse_pos: Vector2 = save_mouse_pos_(button.position)

                pixel_width_ = minf(pixel_width_ * ZOOM_STEP,
                    DisplayServer.screen_get_size().x / 2.0)

                restore_mouse_pos_(button.position, rel_mouse_pos)
                update_position_()

        MOUSE_BUTTON_WHEEL_DOWN:
            if button.pressed:
                var rel_mouse_pos: Vector2 = save_mouse_pos_(button.position)

                pixel_width_ = maxf(pixel_width_ / ZOOM_STEP, 0.1)

                restore_mouse_pos_(button.position, rel_mouse_pos)
                update_position_()

        MOUSE_BUTTON_MIDDLE:
            start_dragging_() if button.pressed else stop_dragging_()


func _on_motion_event(motion: InputEventMouseMotion) -> void:
    var pixel_moved = update_current_pixel_(motion.position)

    if dragging_:
        top_left_ -= motion.relative
        update_position_()

    if drawing_:
        $DrawTimer.start()
        if pixel_moved and Rect2(Vector2(0.0, 0.0), size).has_point(motion.position):
            draw_pixel_(current_pixel_)


func _on_h_scroll_value_changed(value: float) -> void:
    top_left_.x = value
    update_position_()


func _on_v_scroll_value_changed(value: float) -> void:
    top_left_.y = value
    update_position_()


func _on_resized() -> void:
    if not current_layer_:
        return

    update_position_()


func _on_image_changed(image: IHP) -> void:
    current_layer_ = image.current_layer.image
    current_layer_changed_ = true
    texture_ = ImageTexture.create_from_image(current_layer_)

    update_position_()


func _on_app_scale_changed(app_scale: float) -> void:
    pan_step_ = BASE_PAN_STEP * app_scale
    update_cursor_()
    update_position_()


func _on_focus_lost() -> void:
    if drawing_:
        stop_drawing_()

    if dragging_:
        stop_dragging_()

    if hovering_:
        stop_hovering_()


func save_mouse_pos_(mouse_pos: Vector2) -> Vector2:
     return (mouse_pos + top_left_) / pixel_width_


func restore_mouse_pos_(mouse_pos: Vector2, rel_mouse_pos: Vector2) -> void:
    var new_mouse_pos: Vector2 = rel_mouse_pos * pixel_width_ - top_left_
    top_left_ += new_mouse_pos - mouse_pos


func start_hovering_() -> void:
    hovering_ = true
    update_cursor_()


func stop_hovering_() -> void:
    hovering_ = false
    update_cursor_()


func start_dragging_() -> void:
    dragging_ = true


func stop_dragging_() -> void:
    dragging_ = false


func start_drawing_(mouse_pos: Vector2) -> void:
    drawing_ = true
    Input.use_accumulated_input = false
    $DrawTimer.start()

    update_current_pixel_(mouse_pos)
    draw_pixel_(current_pixel_)


func stop_drawing_() -> void:
    drawing_ = false
    Input.use_accumulated_input = true
    $DrawTimer.stop()


func draw_pixel_(pixel: Vector2i) -> void:
    if not pixel_in_image_(pixel):
        return

    if Globals.tool == Tools.PEN or Globals.tool == Tools.ERASER:
        var color: OKColor = Globals.tool_color

        if Globals.tool == Tools.ERASER:
            color = OKColor.new(0.0, 0.0, 0.0, 0.0)

        current_layer_.set_pixel(pixel.x, pixel.y, color.to_rgb())
        current_layer_changed_ = true
        queue_redraw()

        Globals.image.unsaved_changes = true

    elif Globals.tool == Tools.COLOR_PICKER:
        Globals.tool_color = OKColor.from_rgb(current_layer_.get_pixel(
            current_pixel_.x, current_pixel_.y)).opaque()


func pixel_in_image_(pixel: Vector2i) -> bool:
    return Rect2i(Vector2i(0, 0), current_layer_.get_size()).has_point(pixel)


func update_cursor_() -> void:
    var cursor: Resource = null
    if hovering_:
        cursor = cursors_[Globals.tool].get_texture(Globals.app_scale)

    Input.set_custom_mouse_cursor(cursor)
    queue_redraw()


func update_current_pixel_(mouse_pos: Vector2) -> bool:
    var mouse_pixel: Vector2i = ((mouse_pos + top_left_) / pixel_width_).floor()
    if mouse_pixel != current_pixel_:
        current_pixel_ = mouse_pixel
        queue_redraw()
        return true
    return false


func update_position_() -> void:
    var min_top_left: Vector2 = -size * 0.9
    var max_top_left: Vector2 = size * 0.9 + (get_image_size_() - size)

    top_left_.x = clampf(top_left_.x, min_top_left.x, max_top_left.x)
    top_left_.y = clampf(top_left_.y, min_top_left.y, max_top_left.y)

    %HScroll.min_value = min_top_left.x
    %HScroll.max_value = max_top_left.x + size.x
    %HScroll.page = size.x
    %HScroll.set_value_no_signal(top_left_.x)

    %VScroll.min_value = min_top_left.y
    %VScroll.max_value = max_top_left.y + size.y
    %VScroll.page = size.y
    %VScroll.set_value_no_signal(top_left_.y)

    (func():
        %HScroll.size.x = (size.x - %Corner.size.x) / Globals.app_scale
        %VScroll.size.y = (size.y - %Corner.size.y) / Globals.app_scale
    ).call_deferred()

    queue_redraw()


func get_image_size_() -> Vector2:
    return Vector2(pixel_width_, pixel_width_) * texture_.get_size()


func _draw() -> void:
    draw_background_alpha_()

    if current_layer_changed_:
        texture_.update(current_layer_)
        current_layer_changed_ = false

    draw_texture_rect(texture_, Rect2(-top_left_, get_image_size_()), false)
    draw_image_outline_()

    if hovering_:
        draw_hover_highlight_()


func draw_background_alpha_() -> void:
    var square_size: Vector2 = Vector2(pixel_width_, pixel_width_) * Globals.app_scale

    while square_size.x < 10.0 * Globals.app_scale:
        square_size *= 2.0

    var square_area: Rect2 = Rect2(-top_left_, get_image_size_())
    square_area = square_area.intersection(get_rect())

    var indexes: Rect2 = Rect2(
        (square_area.position / square_size).floor(),
        (square_area.size / square_size).ceil())

    var offset: Vector2 = Vector2(
        fmod(-top_left_.x, square_size.x) - square_size.x / 2.0,
        fmod(-top_left_.y, square_size.y) - square_size.y / 2.0)

    var light_color: Color = OKColor.new(0.0, 0.0, 0.52).to_rgb()
    var dark_color: Color = OKColor.new(0.0, 0.0, 0.48).to_rgb()

    var color_repeat: float = square_size.x * 2.0
    var color_offset_x: float = absf(fmod(top_left_.x, color_repeat) / color_repeat)
    var color_offset_y: float = absf(fmod(top_left_.y, color_repeat) / color_repeat)

    for x in range(indexes.position.x, indexes.position.x + indexes.size.x + 1):
        for y in range(indexes.position.y, indexes.position.y + indexes.size.y + 1):
            var color_x: int = x if color_offset_x < 0.5 else x + 1
            var color_y: int = y if color_offset_y < 0.5 else y + 1
            var square_color: Color = light_color if color_x % 2 == color_y % 2 else dark_color

            var square = Rect2(Vector2(x, y) * square_size + offset, square_size)
            draw_rect(square.intersection(square_area), square_color)


func draw_image_outline_() -> void:
    var line_width: int = roundi(Globals.app_scale)
    var image_size: Vector2 = get_image_size_()

    draw_rect(Rect2(
        -top_left_.x - line_width / 2.0,
        -top_left_.y - line_width / 2.0,
        image_size.x + line_width,
        image_size.y + line_width),
        OKColor.new(0.0, 0.0, 0.6).to_rgb(), false, line_width)


func draw_hover_highlight_() -> void:
    if not pixel_in_image_(current_pixel_):
        return

    var pixel_color: OKColor = OKColor.from_rgb(
        current_layer_.get_pixel(current_pixel_.x, current_pixel_.y))
    var line_width: int = roundi(Globals.app_scale)

    var hl_pos: Vector2 = current_pixel_ * pixel_width_ - top_left_
    hl_pos += Vector2(line_width / 2.0, line_width / 2.0)
    var hl_size: Vector2 = Vector2(pixel_width_ - line_width, pixel_width_ - line_width)

    draw_rect(Rect2(hl_pos, hl_size),
        ColorEditor.get_line_color(pixel_color).to_rgb(), false, line_width)
