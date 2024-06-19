extends PanelContainer

@export var tool: Tool.Type

var key_: Key


func _ready() -> void:
    match tool:
        Tool.PEN:
            key_ = Controls.PEN
            $Button.icon = load("res://icons/phosphor/24px/pen-duotone.svg")
        Tool.ERASER:
            key_ = Controls.PEN
            $Button.icon = load("res://icons/phosphor/24px/eraser-duotone.svg")
        Tool.COLOR_SAMPLER:
            key_ = Controls.COLOR_SAMPLER
            $Button.icon = load("res://icons/phosphor/24px/eyedropper-duotone.svg")
        Tool.COLOR_REPLACER:
            key_ = Controls.COLOR_REPLACER
            $Button.icon = load("res://icons/phosphor/24px/eyedropper-sample-duotone.svg")

    Globals.tool_changed.connect(_on_tool_changed)
    Globals.keyboard_layout_changed.connect(_on_keyboard_layout_changed)


func _unhandled_key_input(event: InputEvent) -> void:
    var key: InputEventKey = event as InputEventKey

    # Pen and eraser have the same shortcut, pen handles it
    if tool == Tool.ERASER:
        return

    # Color sampler is a toggle that canvas manages
    if tool == Tool.COLOR_SAMPLER:
        return

    if key.pressed and key.physical_keycode == key_:
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
    match tool:
        Tool.PEN: $Button.tooltip_text = "Pen"
        Tool.ERASER: $Button.tooltip_text = "Eraser"
        Tool.COLOR_SAMPLER: $Button.tooltip_text = "Color Sampler"
        Tool.COLOR_REPLACER: $Button.tooltip_text = "Color Replacer"

    if key_:
        $Button.tooltip_text += " (%s)" % Controls.get_key_label(key_)
