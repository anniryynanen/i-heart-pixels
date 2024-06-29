class_name ScalableSVG
extends RefCounted

var width_: int
var height_: int
var text_: String

var last_scale_: float
var last_fill_: OKColor
var last_texture_: ImageTexture


func _init(texture: Texture2D) -> void:
    width_ = texture.get_width()
    height_ = texture.get_height()

    if OS.has_feature("editor"):
        text_ = FileAccess.open(texture.resource_path, FileAccess.READ).get_as_text()
        SVGKeeper.set_svg_(texture.resource_path, text_)
    else:
        text_ = SVGKeeper.get_svg_(texture.resource_path)


func get_texture(scale: float, fill: OKColor = null) -> ImageTexture:
    if last_texture_:
        var same_scale: bool = is_equal_approx(scale, last_scale_)
        var same_fill: bool = \
            (fill == null and last_fill_ == null) \
            or (fill and fill.equals(last_fill_))

        if same_scale and same_fill:
            return last_texture_

    var modified_text: String = text_
    if fill:
        modified_text = modified_text.replace('fill="#000000"', 'fill="#%s"' % fill.to_hex())

    var image: Image = Image.create(
        roundi(width_ * scale), roundi(height_ * scale), false, Image.Format.FORMAT_RGBA8)
    image.load_svg_from_string(modified_text, scale)
    var texture: ImageTexture = ImageTexture.create_from_image(image)

    last_scale_ = scale
    last_fill_ = fill
    last_texture_ = texture
    return texture
