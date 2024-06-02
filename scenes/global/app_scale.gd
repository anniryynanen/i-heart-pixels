extends Node

var main: Control
var themes: Dictionary = {}
var windows: Array[Window]
var anchor_keepers: Array[AnchorKeeper]
var min_sizes: Array[Control]
var margin_overrides: Array[MarginContainer]
var box_overrides: Array[BoxContainer]
var svg_buttons: Array[Button]
var sliders: Array[Slider]
var scrollbars: Array[ScrollBar]


func start() -> void:
    main = get_tree().root.find_child("Main", true, false) as Control
    scan_nodes(main)
    save_themes()
    update_scale()

    Globals.app_scale_changed.connect(func(_s): update_scale())


func scan_nodes(node: Node) -> void:
    if node is Window and not node is PopupMenu:
        var window: Window = node as Window
        window.set_meta("width", window.size.x)
        window.set_meta("height", window.size.y)
        windows.append(window)

    elif node is Control:
        var control: Control = node as Control

        if control.theme and control.theme.get_instance_id() not in themes:
            themes[control.theme.get_instance_id()] = control.theme

        if control.has_meta("keep_anchors") and control.get_meta("keep_anchors") == true:
            anchor_keepers.append(AnchorKeeper.new(control))

        if control.custom_minimum_size != Vector2():
            control.set_meta("custom_minimum_size", control.custom_minimum_size)
            min_sizes.append(control)

        if control is MarginContainer:
            save_constant_override(control, "margin_left")
            save_constant_override(control, "margin_right")
            save_constant_override(control, "margin_top")
            save_constant_override(control, "margin_bottom")
            margin_overrides.append(control)

        elif control is BoxContainer:
            save_constant_override(control, "separation")
            box_overrides.append(control)

        elif control is Button:
            var button: Button = control as Button

            if button.icon and button.icon.resource_path.ends_with(".svg"):
                button.set_meta("icon", ScalableSVG.new(button.icon))
                svg_buttons.append(button)

        elif control is Slider:
            sliders.append(control as Slider)

        elif control is ScrollBar:
            scrollbars.append(control as ScrollBar)

    for child in node.get_children(true):
        scan_nodes(child)


func save_constant_override(control: Control, constant_name: String) -> void:
    if control.has_theme_constant_override(constant_name):
        control.set_meta(constant_name, control.get_theme_constant(constant_name))


func save_themes() -> void:
    for theme: Theme in themes.values():
        theme.set_meta("default_font_size", theme.default_font_size)

        for theme_type: String in theme.get_stylebox_type_list():
            for box_name: String in theme.get_stylebox_list(theme_type):

                save_stylebox(theme.get_stylebox(box_name, theme_type))

        for theme_type: String in theme.get_constant_type_list():
            for constant_name: String in theme.get_constant_list(theme_type):

                theme.set_meta(
                    theme_type + "_" + constant_name,
                    theme.get_constant(constant_name, theme_type))

        for theme_type: String in theme.get_icon_type_list():
            for icon_name: String in theme.get_icon_list(theme_type):

                theme.set_meta(
                    theme_type + "_" + icon_name,
                    ScalableSVG.new(theme.get_icon(icon_name, theme_type)))


func save_stylebox(box: StyleBox) -> void:
    box.set_meta("content_margin_left", box.content_margin_left)
    box.set_meta("content_margin_right", box.content_margin_right)
    box.set_meta("content_margin_top", box.content_margin_top)
    box.set_meta("content_margin_bottom", box.content_margin_bottom)

    if box is StyleBoxFlat:
        var flat_box: StyleBoxFlat = box as StyleBoxFlat
        flat_box.set_meta("corner_radius_top_left", flat_box.corner_radius_top_left)
        flat_box.set_meta("corner_radius_top_right", flat_box.corner_radius_top_right)
        flat_box.set_meta("corner_radius_bottom_left", flat_box.corner_radius_bottom_left)
        flat_box.set_meta("corner_radius_bottom_right", flat_box.corner_radius_bottom_right)

        flat_box.set_meta("border_width_left", flat_box.border_width_left)
        flat_box.set_meta("border_width_right", flat_box.border_width_right)
        flat_box.set_meta("border_width_top", flat_box.border_width_top)
        flat_box.set_meta("border_width_bottom", flat_box.border_width_bottom)

    elif box is StyleBoxLine:
        var line_box: StyleBoxLine = box as StyleBoxLine
        line_box.set_meta("grow_begin", line_box.grow_begin)
        line_box.set_meta("grow_end", line_box.grow_end)
        line_box.set_meta("thickness", line_box.thickness)


func update_scale() -> void:
    for theme: Theme in themes.values():
        theme.default_font_size = roundi(theme.get_meta("default_font_size") * Globals.app_scale)

        for theme_type: String in theme.get_stylebox_type_list():
            for box_name: String in theme.get_stylebox_list(theme_type):
                update_stylebox(theme.get_stylebox(box_name, theme_type))

        update_theme_constant(theme, "HBoxContainer", "separation")
        update_theme_constant(theme, "VBoxContainer", "separation")
        update_theme_constant(theme, "HSplitContainer", "minimum_grap_thickness")
        update_theme_constant(theme, "HSplitContainer", "separation")
        update_theme_constant(theme, "MenuBar", "h_separation")
        update_theme_constant(theme, "PopupMenu", "item_start_padding")
        update_theme_constant(theme, "PopupMenu", "end_padding")
        update_theme_constant(theme, "PopupMenu", "v_separation")

        update_theme_icon(theme, "HSplitContainer", "grabber")

    for control in min_sizes:
        control.custom_minimum_size = control.get_meta("custom_minimum_size") * Globals.app_scale

    for control in margin_overrides:
        update_constant_override(control, "margin_left")
        update_constant_override(control, "margin_right")
        update_constant_override(control, "margin_top")
        update_constant_override(control, "margin_bottom")

    for control in box_overrides:
        update_constant_override(control, "separation")

    for button in svg_buttons:
        button.icon = button.get_meta("icon").get_texture(Globals.app_scale)

    for slider in sliders:
        slider.scale = Vector2(Globals.app_scale, Globals.app_scale)

    for scrollbar in scrollbars:
        scrollbar.scale = Vector2(Globals.app_scale, Globals.app_scale)

    main.notification(Control.NOTIFICATION_THEME_CHANGED)
    update_size(main)

    (func():
        for window in windows:
            window.size = Vector2i(
                roundi(window.get_meta("width") * Globals.app_scale),
                roundi(window.get_meta("height") * Globals.app_scale))
    ).call_deferred()


func update_stylebox(box: StyleBox) -> void:
    box.content_margin_left = roundi(box.get_meta("content_margin_left") * Globals.app_scale)
    box.content_margin_right = roundi(box.get_meta("content_margin_right") * Globals.app_scale)
    box.content_margin_top = roundi(box.get_meta("content_margin_top") * Globals.app_scale)
    box.content_margin_bottom = roundi(box.get_meta("content_margin_bottom") * Globals.app_scale)

    if box is StyleBoxFlat:
        var flat_box: StyleBoxFlat = box as StyleBoxFlat

        flat_box.corner_radius_top_left \
            = roundi(box.get_meta("corner_radius_top_left") * Globals.app_scale)
        flat_box.corner_radius_top_right \
            = roundi(box.get_meta("corner_radius_top_right") * Globals.app_scale)
        flat_box.corner_radius_bottom_left \
            = roundi(box.get_meta("corner_radius_bottom_left") * Globals.app_scale)
        flat_box.corner_radius_bottom_right \
            = roundi(box.get_meta("corner_radius_bottom_right") * Globals.app_scale)

        flat_box.border_width_left \
            = roundi(box.get_meta("border_width_left") * Globals.app_scale)
        flat_box.border_width_right \
            = roundi(box.get_meta("border_width_right") * Globals.app_scale)
        flat_box.border_width_top \
            = roundi(box.get_meta("border_width_top") * Globals.app_scale)
        flat_box.border_width_bottom \
            = roundi(box.get_meta("border_width_bottom") * Globals.app_scale)

    elif box is StyleBoxLine:
        var line_box: StyleBoxLine = box as StyleBoxLine
        line_box.grow_begin = roundi(box.get_meta("grow_begin") * Globals.app_scale)
        line_box.grow_end = roundi(box.get_meta("grow_end") * Globals.app_scale)
        line_box.thickness = roundi(box.get_meta("thickness") * Globals.app_scale)


func update_theme_constant(theme: Theme, theme_type: String, constant_name: String) -> void:
    var meta_name: String = theme_type + "_" + constant_name
    if theme.has_meta(meta_name):
        theme.set_constant(
            constant_name, theme_type,
            roundi(theme.get_meta(meta_name) * Globals.app_scale))


func update_theme_icon(theme: Theme, theme_type: String, icon_name: String) -> void:
    var meta_name: String = theme_type + "_" + icon_name
    if theme.has_meta(meta_name):
        theme.set_icon(
            icon_name, theme_type,
            theme.get_meta(meta_name).get_texture(Globals.app_scale))


func update_constant_override(control: Control, override_name: String) -> void:
    if control.has_meta(override_name):
        control.add_theme_constant_override(
            override_name,
            roundi(control.get_meta(override_name) * Globals.app_scale))


func update_size(control: Control) -> void:
    for child: Node in control.get_children(true):
        if child is Control:
            update_size(child)

    control.update_minimum_size()

    for anchor_keeper in anchor_keepers:
        anchor_keeper.fix()
