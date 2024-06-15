class_name IHPColorPicker
extends ClosingPopup

signal color_changed(color: OKColor)

var strips_: Array[ColorStrip]
var handles_: Array[ColorHandle]

var last_color_: OKColor
var last_color_orig_pos_: Vector2
var last_color_orig_size_: Vector2


func _ready() -> void:
    last_color_orig_pos_ = %LastColor.position
    last_color_orig_size_ = %LastColor.size

    strips_.append(%HueStrip)
    strips_.append(%SaturationStrip)
    strips_.append(%LightnessStrip)

    handles_.append(%HueHandle)
    handles_.append(%SaturationHandle)
    handles_.append(%LightnessHandle)

    handles_.map(func(h): h.color_changed.connect(self.set_color_))
    Globals.app_scale_changed.connect(_on_app_scale_changed)


func _unhandled_key_input(event: InputEvent) -> void:
    var key: InputEventKey = event as InputEventKey

    if key.pressed and key.physical_keycode == Controls.COLOR_PICKER:
        hide()
        get_viewport().set_input_as_handled()
    else:
        super._unhandled_key_input(event)


func _on_last_color_pressed() -> void:
    set_color_(last_color_)


func _on_hex_text_submitted(_new_text: String) -> void:
    %Hex.release_focus()


func _on_hex_focus_exited() -> void:
    if not visible:
        return

    if %Hex.text.is_valid_html_color():
        set_color_(OKColor.from_rgb(Color(%Hex.text)))
        %Warning.visible = false
    else:
        %Warning.visible = true


func _on_app_scale_changed(app_scale: float) -> void:
    %LastColor.position = last_color_orig_pos_ * app_scale
    %LastColor.size = last_color_orig_size_ * app_scale


func popup_color(color: OKColor) -> void:
    set_color_(color, false, true)
    popup_centered()


func set_color_(color: OKColor, emit: bool = true, update_last = false) -> void:
    color = color.duplicate()

    # Color picker only deals with opaque colors
    color = color.opaque()

    if update_last:
        last_color_ = color
        %LastColor.get_theme_stylebox("normal").bg_color = color.to_rgb()

    strips_.map(func(s): s.color = color)
    handles_.map(func(h): h.color = color)

    %Color.get_theme_stylebox("panel").bg_color = color.to_rgb()
    %Hex.text = "#" + color.to_hex()
    %Warning.visible = false

    var text_color: OKColor = IHPColorPicker.get_text_color(color)
    %Hex.add_theme_color_override("font_color", text_color.to_rgb())

    var bg_color: OKColor = text_color.duplicate()
    var border_color: OKColor = text_color.duplicate()
    bg_color.a = 0.08
    border_color.a = 0.18

    var stylebox: StyleBoxFlat = %Hex.get_theme_stylebox("normal", "LineEdit")
    stylebox.bg_color = bg_color.to_rgb()
    stylebox.border_color = border_color.to_rgb()

    if emit:
        color_changed.emit(color.duplicate())


static func get_line_color(bg_color: OKColor) -> OKColor:
    var line_color: OKColor = bg_color.duplicate()
    line_color.s *= 0.8
    line_color.l = 0.14 if bg_color.l > 0.5 else 0.9
    line_color.a = 0.45
    return line_color


static func get_text_color(bg_color: OKColor) -> OKColor:
    var text_color: OKColor = OKColor.new()
    text_color.l = 0.0 if bg_color.l > 0.5 else 1.0
    text_color.a = 0.8
    return text_color
