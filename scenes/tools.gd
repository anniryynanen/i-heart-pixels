class_name Tools
extends MarginContainer

enum ToolType {
    NONE,
    PEN,
    ERASER
}
const NONE = ToolType.NONE
const PEN = ToolType.PEN
const ERASER = ToolType.ERASER

var last_tool_: ToolType = ToolType.NONE
var tool_buttons_: Dictionary
var tool_panels_: Dictionary


func _ready() -> void:
    tool_buttons_[NONE] = Button.new()
    tool_panels_[NONE] = PanelContainer.new()

    tool_buttons_[PEN] = %Pen
    tool_panels_[PEN] = %PenPanel
    %Pen.pressed.connect(func(): Globals.tool = PEN)

    tool_buttons_[ERASER] = %Eraser
    tool_panels_[ERASER] = %EraserPanel
    %Eraser.pressed.connect(func(): Globals.tool = ERASER)

    Globals.tool_changed.connect(_on_tool_changed)
    Globals.keyboard_layout_changed.connect(_on_keyboard_layout_changed)


func _unhandled_key_input(event: InputEvent) -> void:
    var key: InputEventKey = event as InputEventKey

    if not key.pressed:
        return

    match key.physical_keycode:
        KEY_E:
            if Globals.tool == PEN:
                Globals.tool = ERASER
            else:
                Globals.tool = PEN


func _on_tool_changed(tool: Tools.ToolType) -> void:
    tool_buttons_[last_tool_].disabled = false
    tool_panels_[last_tool_].theme_type_variation = &"ToolPanelInactive"
    last_tool_ = tool

    tool_buttons_[tool].disabled = true
    tool_panels_[tool].theme_type_variation = &"ToolPanelActive"


func _on_keyboard_layout_changed():
    %PenHint.physical_keycode = KEY_E
    %Pen.tooltip_text = "Pen (" + %PenHint.get_label() + ")"
    %Eraser.tooltip_text = "Eraser (" + %PenHint.get_label() + ")"
