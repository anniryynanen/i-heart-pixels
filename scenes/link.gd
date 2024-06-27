extends HBoxContainer

@export var text: String:
    set(value):
        text = value
        $LinkButton.text = text

@export var url: String:
    set(value):
        url = value
        $LinkButton.uri = url
        $LinkButton.tooltip_text = url
