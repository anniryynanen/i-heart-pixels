class_name OKColor
extends RefCounted

enum Param {
    HUE,
    SATURATION,
    LIGHTNESS
}

var h: float
var s: float
var l: float
var a: float


func _init(hue: float = 0.0, saturation: float = 0.0, lightness: float = 0.0,
        alpha: float = 1.0):
    h = hue
    s = saturation
    l = lightness
    a = alpha


func _to_string() -> String:
    return "(%s, %s, %s, %s)" % [h, s, l, a]


func equals(other: OKColor) -> bool:
    if other == null:
        return false

    return is_equal_approx(h, other.h) \
        and is_equal_approx(s, other.s) \
        and is_equal_approx(l, other.l) \
        and is_equal_approx(a, other.a)


func is_light() -> bool:
    return l > 0.5


func to_hex() -> String:
    return to_rgb().to_html(false)


func duplicate() -> OKColor:
    return OKColor.new(h, s, l, a)


func rounded() -> OKColor:
    var h_steps: int = OKColor.steps(OKColor.Param.HUE)
    var s_steps: int = OKColor.steps(OKColor.Param.SATURATION)
    var l_steps: int = OKColor.steps(OKColor.Param.LIGHTNESS)

    return OKColor.new(
        roundf(h * h_steps) / h_steps,
        roundf(s * s_steps) / s_steps,
        roundf(l * l_steps) / l_steps, a)


func opaque() -> OKColor:
    return OKColor.new(h, s, l)


func to_rgb() -> Color:
    return Color.from_ok_hsl(h, s, l, a)


func get_param_in_steps(param: Param) -> int:
    var param_steps: int = OKColor.steps(param)

    match param:
        Param.HUE: return roundi(h * param_steps)
        Param.SATURATION: return roundi(s * param_steps)
        Param.LIGHTNESS: return roundi(l * param_steps)
        _: return -1


func set_param_in_steps(param: Param, value: int) -> void:
    var param_steps: int = OKColor.steps(param)

    match param:
        Param.HUE: h = value / float(param_steps)
        Param.SATURATION: s = value / float(param_steps)
        Param.LIGHTNESS: l = value / float(param_steps)


static func from_rgb(color: Color) -> OKColor:
    var ok: OKColor = srgb_to_okhsl(color)

    # Saturation comes out NaN for black
    if is_nan(ok.s):
        ok.s = 0.0

    ok.h = clampf(ok.h, 0.0, 1.0)
    ok.s = clampf(ok.s, 0.0, 1.0)
    ok.l = clampf(ok.l, 0.0, 1.0)

    return ok


static func steps(param: Param) -> int:
    match param:
        Param.HUE:
            return 359
        Param.SATURATION, Param.LIGHTNESS:
            return 100
        _:
            return -1


static func cbrt(x: float) -> float:
    return pow(x, 1.0/3.0)


# Ported to GDScript by Anni Ryynänen, from
# https://github.com/bottosson/bottosson.github.io/blob/master/misc/colorpicker/colorconversion.js
#
# Copyright (c) 2021 Björn Ottosson
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


@warning_ignore("shadowed_variable")
static func srgb_transfer_function_inv(a: float) -> float:
    return pow((a + 0.055) / 1.055, 2.4) if 0.04045 < a else a / 12.92


@warning_ignore("shadowed_variable")
static func linear_srgb_to_oklab(r: float, g: float, b: float) -> Array[float]:
    var l: float = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    var m: float = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    var s: float = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

    var l_: float = cbrt(l)
    var m_: float = cbrt(m)
    var s_: float = cbrt(s)

    return [
        0.2104542553*l_ + 0.7936177850*m_ - 0.0040720468*s_,
        1.9779984951*l_ - 2.4285922050*m_ + 0.4505937099*s_,
        0.0259040371*l_ + 0.7827717662*m_ - 0.8086757660*s_,
    ]


@warning_ignore("shadowed_variable")
static func oklab_to_linear_srgb(L: float, a: float, b: float) -> Array[float]:
    var l_: float = L + 0.3963377774 * a + 0.2158037573 * b
    var m_: float = L - 0.1055613458 * a - 0.0638541728 * b
    var s_: float = L - 0.0894841775 * a - 1.2914855480 * b

    var l: float = l_*l_*l_
    var m: float = m_*m_*m_
    var s: float = s_*s_*s_

    return [
        (+4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s),
        (-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s),
        (-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s),
    ]


static func toe(x: float) -> float:
    var k_1: float = 0.206
    var k_2: float = 0.03
    var k_3: float = (1.0+k_1)/(1.0+k_2)

    return 0.5*(k_3*x - k_1 + sqrt((k_3*x - k_1)*(k_3*x - k_1) + 4.0*k_2*k_3*x))


# Finds the maximum saturation possible for a given hue that fits in sRGB
# Saturation here is defined as S = C/L
# a and b must be normalized so a^2 + b^2 == 1
@warning_ignore("shadowed_variable")
static func compute_max_saturation(a: float, b: float) -> float:
    # Max saturation will be when one of r, g or b goes below zero.

    # Select different coefficients depending on which component goes below zero first
    var k0: float
    var k1: float
    var k2: float
    var k3: float
    var k4: float
    var wl: float
    var wm: float
    var ws: float

    if -1.88170328 * a - 0.80936493 * b > 1.0:
        # Red component
        k0 = +1.19086277
        k1 = +1.76576728
        k2 = +0.59662641
        k3 = +0.75515197
        k4 = +0.56771245
        wl = +4.0767416621
        wm = -3.3077115913
        ws = +0.2309699292
    elif 1.81444104 * a - 1.19445276 * b > 1.0:
        # Green component
        k0 = +0.73956515
        k1 = -0.45954404
        k2 = +0.08285427
        k3 = +0.12541070
        k4 = +0.14503204
        wl = -1.2684380046
        wm = +2.6097574011
        ws = -0.3413193965
    else:
        # Blue component
        k0 = +1.35733652
        k1 = -0.00915799
        k2 = -1.15130210
        k3 = -0.50559606
        k4 = +0.00692167
        wl = -0.0041960863
        wm = -0.7034186147
        ws = +1.7076147010

    # Approximate max saturation using a polynomial:
    var S: float = k0 + k1 * a + k2 * b + k3 * a * a + k4 * a * b

    # Do one step Halley's method to get closer
    # this gives an error less than 10e6, except for some blue hues where the dS/dh is close to infinite
    # this should be sufficient for most applications, otherwise do two/three steps

    var k_l: float = +0.3963377774 * a + 0.2158037573 * b
    var k_m: float = -0.1055613458 * a - 0.0638541728 * b
    var k_s: float = -0.0894841775 * a - 1.2914855480 * b

    #region
    var l_: float = 1.0 + S * k_l
    var m_: float = 1.0 + S * k_m
    var s_: float = 1.0 + S * k_s

    var l: float = l_ * l_ * l_
    var m: float = m_ * m_ * m_
    var s: float = s_ * s_ * s_

    var l_dS: float = 3.0 * k_l * l_ * l_
    var m_dS: float = 3.0 * k_m * m_ * m_
    var s_dS: float = 3.0 * k_s * s_ * s_

    var l_dS2: float = 6.0 * k_l * k_l * l_
    var m_dS2: float = 6.0 * k_m * k_m * m_
    var s_dS2: float = 6.0 * k_s * k_s * s_

    var f: float  = wl * l     + wm * m     + ws * s
    var f1: float = wl * l_dS  + wm * m_dS  + ws * s_dS
    var f2: float = wl * l_dS2 + wm * m_dS2 + ws * s_dS2

    S = S - f * f1 / (f1*f1 - 0.5 * f * f2)
    #endregion

    return S


@warning_ignore("shadowed_variable")
static func find_cusp(a: float, b: float) -> Array[float]:
    # First, find the maximum saturation (saturation S = C/L)
    var S_cusp: float = compute_max_saturation(a, b)

    # Convert to linear sRGB to find the first point where at least one of r,g or b >= 1:
    var rgb_at_max: Array[float] = oklab_to_linear_srgb(1.0, S_cusp * a, S_cusp * b)
    var L_cusp: float = cbrt(1.0 / maxf(maxf(rgb_at_max[0], rgb_at_max[1]), rgb_at_max[2]))
    var C_cusp: float = L_cusp * S_cusp

    return [L_cusp, C_cusp]


# Finds intersection of the line defined by
# L = L0 * (1 - t) + t * L1;
# C = t * C1;
# a and b must be normalized so a^2 + b^2 == 1
@warning_ignore("shadowed_variable")
static func find_gamut_intersection(a: float, b: float, L1: float, C1: float, L0: float,
        cusp: Array[float] = []) -> float:

    if cusp.is_empty():
        # Find the cusp of the gamut triangle
        cusp = find_cusp(a, b)

    # Find the intersection for upper and lower half seprately
    var t: float
    if ((L1 - L0) * cusp[1] - (cusp[0] - L0) * C1) <= 0.0:
        # Lower half

        t = cusp[1] * L0 / (C1 * cusp[0] + cusp[1] * (L0 - L1))
    else:
        # Upper half

        # First intersect with triangle
        t = cusp[1] * (L0 - 1.0) / (C1 * (cusp[0] - 1.0) + cusp[1] * (L0 - L1))

        # Then one step Halley's method
        #region
        var dL: float = L1 - L0
        var dC: float = C1

        var k_l: float = +0.3963377774 * a + 0.2158037573 * b
        var k_m: float = -0.1055613458 * a - 0.0638541728 * b
        var k_s: float = -0.0894841775 * a - 1.2914855480 * b

        var l_dt: float = dL + dC * k_l
        var m_dt: float = dL + dC * k_m
        var s_dt: float = dL + dC * k_s
        #endregion

        # If higher accuracy is required, 2 or 3 iterations of the following block can be used:
        #region
        var L: float = L0 * (1.0 - t) + t * L1
        var C: float = t * C1

        var l_: float = L + C * k_l
        var m_: float = L + C * k_m
        var s_: float = L + C * k_s

        var l: float = l_ * l_ * l_
        var m: float = m_ * m_ * m_
        var s: float = s_ * s_ * s_

        var ldt: float = 3.0 * l_dt * l_ * l_
        var mdt: float = 3.0 * m_dt * m_ * m_
        var sdt: float = 3.0 * s_dt * s_ * s_

        var ldt2: float = 6.0 * l_dt * l_dt * l_
        var mdt2: float = 6.0 * m_dt * m_dt * m_
        var sdt2: float = 6.0 * s_dt * s_dt * s_

        var r: float = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s - 1.0
        var r1: float = 4.0767416621 * ldt - 3.3077115913 * mdt + 0.2309699292 * sdt
        var r2: float = 4.0767416621 * ldt2 - 3.3077115913 * mdt2 + 0.2309699292 * sdt2

        var u_r: float = r1 / (r1 * r1 - 0.5 * r * r2)
        var t_r: float = -r * u_r

        var g: float = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s - 1.0
        var g1: float = -1.2684380046 * ldt + 2.6097574011 * mdt - 0.3413193965 * sdt
        var g2: float = -1.2684380046 * ldt2 + 2.6097574011 * mdt2 - 0.3413193965 * sdt2

        var u_g: float = g1 / (g1 * g1 - 0.5 * g * g2)
        var t_g: float = -g * u_g

        b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s - 1.0
        var b1: float = -0.0041960863 * ldt - 0.7034186147 * mdt + 1.7076147010 * sdt
        var b2: float = -0.0041960863 * ldt2 - 0.7034186147 * mdt2 + 1.7076147010  * sdt2

        var u_b: float = b1 / (b1 * b1 - 0.5 * b * b2)
        var t_b: float = -b * u_b

        t_r = t_r if u_r >= 0.0 else 1.79769e308
        t_g = t_g if u_g >= 0.0 else 1.79769e308
        t_b = t_b if u_b >= 0.0 else 1.79769e308

        t += minf(t_r, minf(t_g, t_b))
        #endregion

    return t


static func get_ST_max(a_: float, b_: float, cusp: Array[float] = []) -> Array[float]:
    if cusp.is_empty():
        cusp = find_cusp(a_, b_)

    var L: float = cusp[0]
    var C: float = cusp[1]
    return [C/L, C/(1.0-L)]


static func get_Cs(L: float, a_: float, b_: float) -> Array[float]:
    var cusp: Array[float] = find_cusp(a_, b_)

    var C_max: float = find_gamut_intersection(a_, b_, L, 1.0, L, cusp)
    var ST_max: Array[float] = get_ST_max(a_, b_, cusp)

    var S_mid: float = 0.11516993 + 1.0/(
        + 7.44778970 + 4.15901240*b_
        + a_*(- 2.19557347 + 1.75198401*b_
        + a_*(- 2.13704948 -10.02301043*b_
        + a_*(- 4.24894561 + 5.38770819*b_ + 4.69891013*a_
        )))
    )

    var T_mid: float = 0.11239642 + 1.0/(
        + 1.61320320 - 0.68124379*b_
        + a_*(+ 0.40370612 + 0.90148123*b_
        + a_*(- 0.27087943 + 0.61223990*b_
        + a_*(+ 0.00299215 - 0.45399568*b_ - 0.14661872*a_
        )))
    )

    var k: float = C_max/minf((L*ST_max[0]), (1.0-L)*ST_max[1])

    var C_a: float = L*S_mid
    var C_b: float = (1.0-L)*T_mid

    var C_mid: float = 0.9*k*sqrt(sqrt(1.0/(1.0/(C_a*C_a*C_a*C_a) + 1.0/(C_b*C_b*C_b*C_b))))

    C_a = L*0.4
    C_b = (1.0-L)*0.8

    var C_0: float = sqrt(1.0/(1.0/(C_a*C_a) + 1.0/(C_b*C_b)))

    return [C_0, C_mid, C_max]


@warning_ignore("shadowed_variable")
static func srgb_to_okhsl(color: Color) -> OKColor:
    var lab: Array[float] = linear_srgb_to_oklab(
        srgb_transfer_function_inv(color.r),
        srgb_transfer_function_inv(color.g),
        srgb_transfer_function_inv(color.b)
    )

    var C: float = sqrt(lab[1]*lab[1] + lab[2]*lab[2])
    var a_: float = lab[1]/C
    var b_: float = lab[2]/C

    var L: float = lab[0]
    var h: float = 0.5 + 0.5*atan2(-lab[2], -lab[1])/PI

    var Cs: Array[float] = get_Cs(L, a_, b_)
    var C_0: float = Cs[0]
    var C_mid: float = Cs[1]
    var C_max: float = Cs[2]

    var s: float
    if C < C_mid:
        var k_0: float = 0.0
        var k_1: float = 0.8*C_0
        var k_2: float = (1.0-k_1/C_mid)

        var t: float = (C - k_0)/(k_1 + k_2*(C - k_0))
        s = t*0.8
    else:
        var k_0: float = C_mid
        var k_1: float = 0.2*C_mid*C_mid*1.25*1.25/C_0
        var k_2: float = (1.0 - (k_1)/(C_max - C_mid))

        var t: float = (C - k_0)/(k_1 + k_2*(C - k_0))
        s = 0.8 + 0.2*t

    var l: float = toe(L)
    return OKColor.new(h, s, l, color.a)
