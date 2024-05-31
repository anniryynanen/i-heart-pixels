class_name AnchorKeeper
extends RefCounted

var control: Control
var offset_left: float
var offset_right: float
var offset_top: float
var offset_bottom: float


@warning_ignore("shadowed_variable")
func _init(control: Control):
    self.control = control
    self.offset_right = control.offset_right
    self.offset_left = control.offset_left
    self.offset_top = control.offset_top
    self.offset_bottom = control.offset_bottom


func fix() -> void:
    if control.anchor_left == 1 and control.anchor_right == 1:
        control.offset_right = offset_right * Globals.app_scale

    if control.anchor_top == 1 and control.anchor_bottom == 1:
        control.offset_bottom = offset_bottom * Globals.app_scale
