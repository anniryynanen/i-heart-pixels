extends PanelContainer

@export var tool: Tool.Type
@export var physical_key: Key

var orig_tooltip_: String


func _ready() -> void:
    orig_tooltip_ = tooltip_text
    $Button.tooltip_text = tooltip_text

    match tool:
        Tool.PEN:
            $Button.icon = load("res://icons/phosphor/tools/pen-duotone.svg")
        Tool.ERASER:
            $Button.icon = load("res://icons/phosphor/tools/eraser-duotone.svg")
        Tool.COLOR_SAMPLER:
            $Button.icon = load("res://icons/phosphor/tools/eyedropper-duotone.svg")

    Globals.tool_changed.connect(_on_tool_changed)
    Globals.keyboard_layout_changed.connect(_on_keyboard_layout_changed)


func _unhandled_key_input(event: InputEvent) -> void:
    var key: InputEventKey = event as InputEventKey

    # Pen and eraser have the same shortcut, pen handles it
    if tool == Tool.ERASER:
        return

    if key.pressed and key.physical_keycode == physical_key:
        if tool == Tool.PEN and Globals.tool == Tool.PEN:
            Globals.tool = Tool.ERASER
        else:
            Globals.tool = tool

        get_viewport().set_input_as_handled()


func _on_button_pressed() -> void:
    Globals.tool = tool


func _on_tool_changed(new_tool: Tool.Type) -> void:
    var active = new_tool == tool
    $Button.disabled = active
    theme_type_variation = &"ToolPanelActive" if active else &"ToolPanelInactive"


func _on_keyboard_layout_changed():
    if physical_key:
        $Button.tooltip_text = "%s (%s)" % [
            orig_tooltip_,
            OS.get_keycode_string(DisplayServer.keyboard_get_label_from_physical(physical_key))]
