class_name ScalableSVG
extends RefCounted

var width_: int
var height_: int
var text_: String

var last_scale_: float
var last_texture_: ImageTexture


func _init(texture: Texture2D):
    width_ = texture.get_width()
    height_ = texture.get_height()

    text_ = FileAccess.open(texture.resource_path, FileAccess.READ).get_as_text()


func get_texture(scale: float) -> ImageTexture:
    if last_texture_ and is_equal_approx(scale, last_scale_):
        return last_texture_

    var image: Image = Image.create(
        roundi(width_ * scale), roundi(height_ * scale), false, Image.Format.FORMAT_RGBA8)
    image.load_svg_from_string(text_, scale)
    var texture: ImageTexture = ImageTexture.create_from_image(image)

    last_scale_ = scale
    last_texture_ = texture
    return texture
