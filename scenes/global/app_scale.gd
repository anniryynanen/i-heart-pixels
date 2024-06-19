extends Node

const SCALED_CONSTANTS_: Array[String] = [
    "separation", "h_separation", "v_separation",
    "margin_left", "margin_right", "margin_top", "margin_bottom",
    "item_start_padding", "item_end_padding",
    "shadow_offset_x", "shadow_offset_y",
    "minimum_grab_thickness",
    "indent",
    "outline_size"
]

const UNSCALED_CONSTANTS_: Array[String] = ["autohide"]

var main_: Control
var themes_: Dictionary
var windows_: Array[Window]
var anchor_keepers_: Array[AnchorKeeper]
var controls_: Array[Control]
var transient_controls_: Array[Control]


func start() -> void:
    main_ = get_tree().root.find_child("Main", true, false) as Control
    scan_nodes_(main_)
    save_themes_()
    update_scale_()

    Globals.app_scale_changed.connect(func(_s): update_scale_())


func add_transient(control: Control) -> void:
    var new_controls: Array[Control] = scan_nodes_(control, true)

    for new_control in new_controls:
        update_control_(new_control)

    update_size_(control)


func remove_transient(control: Control) -> void:
    for child in control.get_children(true):
        remove_transient(child)

    var index: int = transient_controls_.find(control)
    if index != -1:
        transient_controls_.remove_at(index)


func scan_nodes_(node: Node, transient: bool = false) -> Array[Control]:
    if node is FileDialog:
        return []

    var new_controls: Array[Control] = []

    if node is Window and not node is PopupMenu:
        var window: Window = node as Window
        window.set_meta("width", window.size.x)
        window.set_meta("height", window.size.y)
        windows_.append(window)

    elif node is Control:
        var control: Control = node as Control

        if not transient:
            if control.theme and control.theme.get_instance_id() not in themes_:
                themes_[control.theme.get_instance_id()] = control.theme

            if control.has_meta("keep_anchors") and control.get_meta("keep_anchors") == true:
                anchor_keepers_.append(AnchorKeeper.new(control))

        if control.custom_minimum_size != Vector2():
            if not control.has_meta("custom_minimum_size"):
                control.set_meta("custom_minimum_size", control.custom_minimum_size)
                new_controls.append(control)

        if control is MarginContainer:
            save_constant_override_(control, "margin_left")
            save_constant_override_(control, "margin_right")
            save_constant_override_(control, "margin_top")
            save_constant_override_(control, "margin_bottom")
            new_controls.append(control)

        elif control is BoxContainer:
            save_constant_override_(control, "separation")
            new_controls.append(control)

        elif control is Button:
            var button: Button = control as Button

            if button.icon and button.icon.resource_path.ends_with(".svg"):
                button.set_meta("icon", ScalableSVG.new(button.icon))
                new_controls.append(button)

        elif control is TextureRect:
            var rect: TextureRect = control as TextureRect

            if rect.texture.resource_path.ends_with(".svg"):
                rect.set_meta("texture", ScalableSVG.new(rect.texture))
                new_controls.append(rect)

        elif control is Slider:
            new_controls.append(control)

    if transient:
        transient_controls_.append_array(new_controls)
    else:
        controls_.append_array(new_controls)

    for child in node.get_children(true):
        new_controls.append_array(scan_nodes_(child, transient))

    return new_controls


func save_constant_override_(control: Control, constant_name: String) -> void:
    if control.has_theme_constant_override(constant_name):
        control.set_meta(constant_name, control.get_theme_constant(constant_name))


func save_themes_() -> void:
    for theme: Theme in themes_.values():
        theme.set_meta("default_font_size", theme.default_font_size)

        for theme_type: String in theme.get_stylebox_type_list():
            for box_name: String in theme.get_stylebox_list(theme_type):

                save_stylebox_(theme.get_stylebox(box_name, theme_type))

        for theme_type: String in theme.get_font_size_type_list():
            for font_size_name: String in theme.get_font_size_list(theme_type):

                theme.set_meta(
                    theme_type + "_" + font_size_name,
                    theme.get_font_size(font_size_name, theme_type))

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


func save_stylebox_(box: StyleBox) -> void:
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

        flat_box.set_meta("expand_margin_left", flat_box.expand_margin_left)
        flat_box.set_meta("expand_margin_right", flat_box.expand_margin_right)
        flat_box.set_meta("expand_margin_top", flat_box.expand_margin_top)
        flat_box.set_meta("expand_margin_bottom", flat_box.expand_margin_bottom)

    elif box is StyleBoxLine:
        var line_box: StyleBoxLine = box as StyleBoxLine
        line_box.set_meta("grow_begin", line_box.grow_begin)
        line_box.set_meta("grow_end", line_box.grow_end)
        line_box.set_meta("thickness", line_box.thickness)

    elif box is StyleBoxTexture:
        var texture_box: StyleBoxTexture = box as StyleBoxTexture

        if texture_box.texture.resource_path.ends_with(".svg"):
            texture_box.set_meta("texture", ScalableSVG.new(texture_box.texture))

        texture_box.set_meta("texture_margin_left", texture_box.texture_margin_left)
        texture_box.set_meta("texture_margin_right", texture_box.texture_margin_right)
        texture_box.set_meta("texture_margin_top", texture_box.texture_margin_top)
        texture_box.set_meta("texture_margin_bottom", texture_box.texture_margin_bottom)


func update_scale_() -> void:
    for theme: Theme in themes_.values():
        theme.default_font_size = roundi(theme.get_meta("default_font_size") * Globals.app_scale)

        for theme_type: String in theme.get_stylebox_type_list():
            for box_name: String in theme.get_stylebox_list(theme_type):
                update_stylebox_(theme.get_stylebox(box_name, theme_type))

        update_theme_font_size_(theme, "KeyHintLabel", "font_size")

        for theme_type in theme.get_constant_type_list():
            for constant_name in theme.get_constant_list(theme_type):

                if constant_name in SCALED_CONSTANTS_:
                    update_theme_constant_(theme, theme_type, constant_name)
                elif constant_name not in UNSCALED_CONSTANTS_:
                    push_error("Unknown theme constant: " + constant_name)

        update_theme_icon_(theme, "HSplitContainer", "grabber")
        update_theme_icon_(theme, "VSplitContainer", "grabber")
        update_theme_icon_(theme, "SpinBox", "updown")

    for control in controls_:
        update_control_(control)

    for control in transient_controls_:
        update_control_(control)

    main_.notification(Control.NOTIFICATION_THEME_CHANGED)
    update_size_(main_)

    for window in windows_:
        (func():
            # Can't set window size if it's not visible
            if not window.visible:
                await window.visibility_changed

            var new_size: Vector2i = Vector2i(
                roundi(window.get_meta("width") * Globals.app_scale),
                roundi(window.get_meta("height") * Globals.app_scale))

            if new_size != window.size:
                (func(): # Deferring is sometimes needed to reduce window size
                    window.position += (window.size - new_size) / 2
                    window.size = new_size
                ).call_deferred()
        ).call_deferred()


func update_stylebox_(box: StyleBox) -> void:
    box.set_block_signals(true)

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

        flat_box.expand_margin_left \
            = roundi(box.get_meta("expand_margin_left") * Globals.app_scale)
        flat_box.expand_margin_right \
            = roundi(box.get_meta("expand_margin_right") * Globals.app_scale)
        flat_box.expand_margin_top \
            = roundi(box.get_meta("expand_margin_top") * Globals.app_scale)
        flat_box.expand_margin_bottom \
            = roundi(box.get_meta("expand_margin_bottom") * Globals.app_scale)

    elif box is StyleBoxLine:
        var line_box: StyleBoxLine = box as StyleBoxLine
        line_box.grow_begin = roundi(box.get_meta("grow_begin") * Globals.app_scale)
        line_box.grow_end = roundi(box.get_meta("grow_end") * Globals.app_scale)
        line_box.thickness = roundi(box.get_meta("thickness") * Globals.app_scale)

    elif box is StyleBoxTexture:
        var texture_box: StyleBoxTexture = box as StyleBoxTexture

        if texture_box.has_meta("texture"):
            texture_box.texture = box.get_meta("texture").get_texture(Globals.app_scale)

        texture_box.texture_margin_left \
            = roundi(box.get_meta("texture_margin_left") * Globals.app_scale)
        texture_box.texture_margin_right \
            = roundi(box.get_meta("texture_margin_right") * Globals.app_scale)
        texture_box.texture_margin_top \
            = roundi(box.get_meta("texture_margin_top") * Globals.app_scale)
        texture_box.texture_margin_bottom \
            = roundi(box.get_meta("texture_margin_bottom") * Globals.app_scale)

    box.set_block_signals(false)


func update_theme_font_size_(theme: Theme, theme_type: String, font_size_name: String) -> void:
    var meta_name: String = theme_type + "_" + font_size_name
    if theme.has_meta(meta_name):
        theme.set_font_size(
            font_size_name, theme_type,
            roundi(theme.get_meta(meta_name) * Globals.app_scale))


func update_theme_constant_(theme: Theme, theme_type: String, constant_name: String) -> void:
    var meta_name: String = theme_type + "_" + constant_name
    if theme.has_meta(meta_name):
        theme.set_constant(
            constant_name, theme_type,
            roundi(theme.get_meta(meta_name) * Globals.app_scale))


func update_theme_icon_(theme: Theme, theme_type: String, icon_name: String) -> void:
    var meta_name: String = theme_type + "_" + icon_name
    if theme.has_meta(meta_name):
        theme.set_icon(
            icon_name, theme_type,
            theme.get_meta(meta_name).get_texture(Globals.app_scale))


func update_constant_override_(control: Control, override_name: String) -> void:
    if control.has_meta(override_name):
        control.add_theme_constant_override(
            override_name,
            roundi(control.get_meta(override_name) * Globals.app_scale))


func update_control_(control: Control) -> void:
    if control.has_meta("custom_minimum_size"):
        control.custom_minimum_size = \
            control.get_meta("custom_minimum_size") * Globals.app_scale

    if control is MarginContainer:
        update_constant_override_(control, "margin_left")
        update_constant_override_(control, "margin_right")
        update_constant_override_(control, "margin_top")
        update_constant_override_(control, "margin_bottom")

    elif control is BoxContainer:
        update_constant_override_(control, "separation")

    elif control is Button and control.has_meta("icon"):
        control.icon = control.get_meta("icon").get_texture(Globals.app_scale)

    elif control is TextureRect and control.has_meta("texture"):
        control.texture = control.get_meta("texture").get_texture(Globals.app_scale)

    # To scale sliders this way, they need to be inside a Control (not a
    # Container). Set the slider's size with transform.
    #
    # If that becomes too tedious, slider textures can be converted to SVGs.
    elif control is Slider:
        control.scale = Vector2(Globals.app_scale, Globals.app_scale)


func update_size_(control: Control) -> void:
    for child: Node in control.get_children(true):
        if child is Control:
            update_size_(child)

    control.update_minimum_size()

    for anchor_keeper in anchor_keepers_:
        anchor_keeper.fix()
