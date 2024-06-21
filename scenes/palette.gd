extends Control

var current_index_: int = -1


func _ready() -> void:
    load_colors_()

    custom_minimum_size.y = %ColorBars.get_child(0).size.y + %ButtonContainer.size.y


func _unhandled_key_input(event: InputEvent) -> void:
    var key: InputEventKey = event as InputEventKey

    if key.pressed:
        if key.physical_keycode == Controls.COLOR_PICKER:
            if not $ColorPicker.visible:
                $ColorPicker.popup_color(Globals.tool_color)

            get_viewport().set_input_as_handled()

        elif key.physical_keycode == Controls.NEXT_COLOR:
            select_next_()
            get_viewport().set_input_as_handled()

        elif key.physical_keycode == Controls.PREV_COLOR:
            select_prev_()
            get_viewport().set_input_as_handled()


func _on_bar_pressed(bar: ColorBar) -> void:
    select_index_(bar.get_index())


func _on_color_picker_color_changed(color: OKColor) -> void:
    Globals.tool_color = color


func _on_add_pressed() -> void:
    add_bar_(Globals.tool_color)

    save_colors_()
    update_buttons_()
    show_current_bar_()


func _on_set_pressed() -> void:
    get_current_bar_().color = Globals.tool_color
    save_colors_()


func _on_move_up_pressed() -> void:
    if at_beginning_():
        return

    var index: int = current_index_ - 1
    %ColorBars.move_child(get_current_bar_(), index)
    select_index_(index)


func _on_move_down_pressed() -> void:
    if at_end_():
        return

    var index: int = current_index_ + 1
    %ColorBars.move_child(get_current_bar_(), index)
    select_index_(index)


func _on_delete_pressed() -> void:
    if %ColorBars.get_child_count() < 2:
        return

    var bar: ColorBar = get_current_bar_()
    if at_end_():
        current_index_ -= 1

    %ColorBars.remove_child(bar)
    select_index_(current_index_)

    for connection in bar.get_signal_connection_list("pressed"):
        bar.pressed.disconnect(connection.callable)

    save_colors_()
    update_buttons_()
    show_current_bar_()

    AppScale.remove_transient(bar)


func get_current_bar_() -> ColorBar:
    return %ColorBars.get_child(current_index_)


func at_beginning_() -> bool:
    return current_index_ == 0


func at_end_() -> bool:
    return current_index_ == %ColorBars.get_child_count() - 1


func add_bar_(color: OKColor) -> void:
    if %ColorBars.get_child_count() > 0:
        var prev_bar: ColorBar = get_current_bar_()
        prev_bar.selected = false

    var bar: ColorBar = load("res://scenes/color_bar.tscn").instantiate()
    bar.color = color
    bar.selected = true
    bar.pressed.connect(_on_bar_pressed.bind(bar))

    current_index_ += 1
    %ColorBars.add_child(bar)
    %ColorBars.move_child(bar, current_index_)

    AppScale.add_transient.call_deferred(bar)


func select_next_() -> void:
    select_index_((current_index_ + 1) % %ColorBars.get_child_count())


func select_prev_() -> void:
    var index: int = current_index_ -1
    if index < 0:
        index = %ColorBars.get_child_count() - 1

    select_index_(index)


func select_index_(index: int) -> void:
    get_current_bar_().selected = false

    var bar: ColorBar = %ColorBars.get_child(index)
    bar.selected = true
    Globals.tool_color = bar.color

    current_index_ = index
    save_current_index_()

    update_buttons_()
    show_current_bar_()


func update_buttons_() -> void:
    %MoveUp.disabled = at_beginning_()
    %MoveDown.disabled = at_end_()
    %Delete.disabled = %ColorBars.get_child_count() < 2


func show_current_bar_() -> void:
    await get_tree().process_frame
    %Scroll.ensure_control_visible(get_current_bar_())


func load_colors_() -> void:
    if Settings.has_value("palette", "colors"):
        for color in Settings.get_value("palette", "colors"):
            add_bar_(OKColor.new(color[0], color[1], color[2]))
            get_current_bar_().selected = false

        current_index_ = Settings.get_value("palette", "current_index", 0)
        current_index_ = clampi(current_index_, 0, %ColorBars.get_child_count() - 1)
        get_current_bar_().selected = true
    else:
        add_bar_(OKColor.new(0.0, 0.0, 0.2))

    if Settings.has_value("tool", "color"):
        Globals.tool_color = Settings.get_value("tool", "color")
    else:
        Globals.tool_color = get_current_bar_().color

    update_buttons_()
    show_current_bar_()


func save_colors_() -> void:
    var colors: Array

    for bar in %ColorBars.get_children():
        colors.append([bar.color.h, bar.color.s, bar.color.l])

    Settings.set_value("palette", "colors", colors)
    save_current_index_()


func save_current_index_() -> void:
    Settings.set_value("palette", "current_index", current_index_)
