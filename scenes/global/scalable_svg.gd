class_name ScalableSVG
extends RefCounted

var width_: int
var height_: int
var text_: String


func _init(texture: Texture2D):
    width_ = texture.get_width()
    height_ = texture.get_height()

    text_ = FileAccess.open(texture.resource_path, FileAccess.READ).get_as_text()


func get_texture(scale: float) -> ImageTexture:
    var image: Image = Image.create(
        roundi(width_ * scale), roundi(height_ * scale), false, Image.Format.FORMAT_RGBA8)

    image.load_svg_from_string(text_, scale)
    return ImageTexture.create_from_image(image)
