class_name AnchorKeeper
extends RefCounted

var control: Control
var offset_left: float
var offset_right: float
var offset_top: float
var offset_bottom: float


func _init(control_: Control):
    control = control_
    offset_right = control.offset_right
    offset_left = control.offset_left
    offset_top = control.offset_top
    offset_bottom = control.offset_bottom


func fix() -> void:
    if control.anchor_left == 1 and control.anchor_right == 1:
        control.offset_right = offset_right * Globals.app_scale

    if control.anchor_top == 1 and control.anchor_bottom == 1:
        control.offset_bottom = offset_bottom * Globals.app_scale
