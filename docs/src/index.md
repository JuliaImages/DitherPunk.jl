```@meta
CurrentModule = DitherPunk
```

# DitherPunk.jl
A [dithering & digital halftoning](https://en.wikipedia.org/wiki/Dither) package inspired by [Lucas Pope's Obra Dinn](https://obradinn.com) and [Surma's blogpost](https://surma.dev/things/ditherpunk/) of the same name.

!!! note
    This package is part of a wider [Julia-based image processing ecosystem](https://github.com/JuliaImages). If you are starting out, then you may benefit from reading about some [fundamental conventions](https://juliaimages.org/latest/tutorials/quickstart/) that the ecosystem utilizes that are markedly different from how images are typically represented in OpenCV, MATLAB, ImageJ or Python.

# Getting started
We start out by loading an image, in this case the lighthouse
from [*TestImages.jl*](https://testimages.juliaimages.org).

````@example simple_example
using DitherPunk
using Images
using TestImages

img = testimage("lighthouse")
img = imresize(img; ratio=1//2)
````

To apply binary dithering, we also need to convert the image to grayscale.

````@example simple_example
img_gray = convert.(Gray, img)
````

!!! note "Preprocessing"
    Sharpening the image and adjusting the contrast can emphasize the effect of the algorithms. It is highly recommended to play around with algorithms such as those provided by [ImageContrastAdjustment.jl](https://juliaimages.org/ImageContrastAdjustment.jl/stable/)

## Binary dithering
Since we already turned the image to grayscale, we are ready to apply a dithering method. 
When no algorithm is specified as the second argument to `dither`, [`FloydSteinberg`](@ref) is used as the default method:
````@example simple_example
dither(img_gray)
````

This is equivalent to 
````@example simple_example
dither(img_gray, FloydSteinberg())
````

!!! note
    DitherPunk currently implements around 30 algorithms. Take a look at the [Image Gallery](@ref) 
    and [Gradient Gallery](@ref) for examples of each method!

One of the implemented methods is [`Bayer`](@ref), an [ordered dithering](https://en.wikipedia.org/wiki/Ordered_dithering) algorithm that leads to characteristic cross-hatch patterns.
````@example simple_example
dither(img_gray, Bayer())
````

[`Bayer`](@ref) specifically can also be used with several "levels" of Bayer-matrices:
````@example simple_example
dither(img_gray, Bayer(3))
````

You can also specify the return type of the image:
````@example simple_example
dither(Gray{Float16}, img_gray, Bayer(3))
````

````@example simple_example
dither(Bool, img_gray, Bayer(3))
````

### Color spaces
Depending on the method, dithering in sRGB color space can lead to results that are too bright.
To obtain a dithered image that more closely matches the human perception of brightness, grayscale images can be converted to linear color space using the boolean keyword argument `to_linear`.
````@example simple_example
dither(img_gray; to_linear=true)
````

````@example simple_example
dither(img_gray, Bayer(); to_linear=true)
````

## Separate-space dithering
All dithering algorithms in DitherPunk can also be applied to color images
and will automatically apply channel-wise binary dithering.

````@example simple_example
dither(img)
````

Because the algorithm is applied once per channel, the output of this algorithm depends on the color type of input image. `RGB` is recommended, but feel free to experiment. 
Dithering is fun and you should be able to produce glitchy images if you want to!
````@example simple_example
dither(convert.(HSV, img), Bayer())
````

## Dithering with custom colors
Let's assume we want to recreate an image by stacking a bunch of Rubik's cubes. Dithering algorithms are perfect for this task!
We start out by defining a custom color scheme:

````@example simple_example
white = RGB{Float32}(1, 1, 1)
yellow = RGB{Float32}(1, 1, 0)
green = RGB{Float32}(0, 0.5, 0)
orange = RGB{Float32}(1, 0.5, 0)
red = RGB{Float32}(1, 0, 0)
blue = RGB{Float32}(0, 0, 1)

rubiks_colors = [white, yellow, green, orange, red, blue]
````

Currently, dithering in custom colors is limited to [`ErrorDiffusion`](@ref) and [`OrderedDither`](@ref) algorithms:
````@example simple_example
d = dither(img, rubiks_colors)
````

This looks much better than simply quantizing to the closest color:
````@example simple_example
dither(img, ClosestColor(), rubiks_colors)
````

The output from a color dithering algorithm is an [`IndirectArray`](https://github.com/JuliaArrays/IndirectArrays.jl), which contains a color palette
````@example simple_example
d.values
````
and indices onto this palette
````@example simple_example
d.index
````
This `index` Matrix can be used in creative ways. Take a look at [ASCII dithering](@ref) for an example!

An interesting effect can also be achieved by color dithering gray-scale images:
````@example simple_example
dither(img_gray, rubiks_colors)
````

You can also play around with [perceptual color difference metrics from Colors.jl](https://juliagraphics.github.io/Colors.jl/stable/colordifferences/). 
For faster dithering, the metric `DE_AB()` can be used, which computes Euclidean distances in `Lab` color space:
````@example simple_example
using Colors
dither(img, rubiks_colors; metric=DE_AB())
````

### ColorSchemes.jl
Predefined color schemes from [ColorSchemes.jl](https://juliagraphics.github.io/ColorSchemes.jl/stable/catalogue/) can also be used.
````@example simple_example
using ColorSchemes
dither(img, ColorSchemes.PuOr_7)
````

````@example simple_example
dither(img, Bayer(), ColorSchemes.berlin)
````

!!! note "Discover new color schemes"
    Type `ColorSchemes.<TAB>` to get color scheme suggestions!

### Automatic color schemes
DitherPunk also allows you to generate optimized color schemes. Simply pass the size of the desired color palette:
````@example simple_example
dither(img, 8)
````

````@example simple_example
dither(img, Bayer(), 8)
````

## Extra glitchiness
If you want glitchy artefacts in your art, use an [`ErrorDiffusion`](@ref) method and set the keyword argument `clamp_error=false`.
````@example simple_example
dither(img, FloydSteinberg(), [blue, white, red]; clamp_error=false)
````

Have fun playing around with different combinations of algorithms, color schemes and color difference metrics!
````@example simple_example
dither(img, Atkinson(), ColorSchemes.julia; metric=DE_CMC(), clamp_error=false)
```` 

## Braille
It is also possible to dither images directly to Braille-characters using [`braille()`](@ref). The interface is the same
as for binary dithering with `dither`:

````@example simple_example
img = imresize(img; ratio=1//3)

braille(img)
````

Depending on the color of the Unicode characters and the background, you might also want to `invert` the output:
````@example simple_example
braille(img, Bayer(); invert=true)
````
