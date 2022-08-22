![](./docs/logo/DitheredPunk.png)
# 💀 DitherPunk.jl 💀

| **Documentation**                                                     | **Build Status**                                      |
|:--------------------------------------------------------------------- |:----------------------------------------------------- |
| [![][docs-stab-img]][docs-stab-url] [![][docs-dev-img]][docs-dev-url] | [![][ci-img]][ci-url] [![][codecov-img]][codecov-url] |

A dithering / digital halftoning package inspired by Lucas Pope's [Obra Dinn](https://obradinn.com) and [Surma's blogpost](https://surma.dev/things/ditherpunk/) of the same name. 
**[Check out the gallery](https://JuliaImages.github.io/DitherPunk.jl/stable/generated/gallery_images/)** for an overview of all currently implemented algorithms.

## Installation
To install this package and its dependencies, open the Julia REPL and run 
```julia-repl
julia> ]add DitherPunk
```

## Examples
```julia
using DitherPunk
using Images
using TestImages
img = testimage("fabio_gray_256")

d = dither(img)                   # apply default algorithm: FloydSteinberg()
d = dither(img, Bayer())          # apply algorithm of choice

dither!(img)                      # or in-place modify image
dither!(img, Bayer())             # with the algorithm of your choice
```

If no color palette is provided, DitherPunk will apply binary dithering to each color channel of the input:
| **Error diffusion** | **Ordered dithering** | **Digital halftoning** |
|:-------------------:|:---------------------:|:----------------------:|
| ![][atkinson-bw]    | ![][bayer-bw]         | ![][ordered-bw]        |
| ![][atkinson-col]   | ![][bayer-col]        | ![][ordered-col]       |

Any of the [29 implemented algorithms][alg-list-url] can be used.

### Color dithering
All error diffusion, ordered dithering and halftoning methods support custom color palettes. Define your own palette or use those from [ColorSchemes.jl](https://juliagraphics.github.io/ColorSchemes.jl/stable/catalogue):
```julia
using ColorSchemes

cs = ColorSchemes.flag_us
dither(img, cs) 
```
| `flag_us`       | `PuOr_6`       | `websafe`    |
|:---------------:|:--------------:|:------------:|
| ![][cs_flag_us] | ![][cs_PuOr_6] | ![][websafe] |

DitherPunk also lets you generate optimized color palettes for each input image:
```julia
ncolors = 8
dither(img, ncolors)
```
| 2 colors          | 8 colors          | 32 colors          |
|:-----------------:|:-----------------:|:------------------:|
| ![][clustering_2] | ![][clustering_8] | ![][clustering_32] |

Dithering in custom colors is supported by all error diffusion, ordered dithering and halftoning methods:
```julia
dither(img, Atkinson(), cs)
dither(img, Atkinson(), ncolors)
```

### Braille pattern images
Images can also be printed using Unicode Braille Patterns
```julia
braille(img, Bayer())
braille(img, Bayer(); invert=true)
```
```
⠕⠅⠅⠅⠕⠅⠕⠅⠅⠅⠅⠅⠅⠅⠅⠅⠅⠅⠕⠅⠕⠅⠕⢅⠕⠅⠕⢅⠕⠅⠕⠅⠅⠅⠅⠅⠅⠅⠕⠅⠁⠅⠁⠅⠁⠅⠁⠅⠁⠅⠁⠅⣪⣺⣺⣺⣪⣺⣪⣺⣺⣺⣺⣺⣺⣺⣺⣺⣺⣺⣪⣺⣪⣺⣪⡺⣪⣺⣪⡺⣪⣺⣪⣺⣺⣺⣺⣺⣺⣺⣪⣺⣾⣺⣾⣺⣾⣺⣾⣺⣾⣺⣾⡂
⠕⢅⠅⠅⠕⠅⠕⠅⠅⠅⠁⠅⠁⠅⠁⠅⠁⠅⠕⠅⠕⢅⢕⢕⢕⠅⠕⠅⢕⢅⠕⢅⠅⠅⠅⠅⠅⠅⠅⠅⠅⠅⠁⠄⠁⠄⠁⠄⠁⠄⠁⠄⣪⡺⣺⣺⣪⣺⣪⣺⣺⣺⣾⣺⣾⣺⣾⣺⣾⣺⣪⣺⣪⡺⡪⡪⡪⣺⣪⣺⡪⡺⣪⡺⣺⣺⣺⣺⣺⣺⣺⣺⣺⣺⣾⣻⣾⣻⣾⣻⣾⣻⣾⡃
⠕⢅⠅⠅⠕⠅⠕⠅⠅⠅⠁⠅⠁⠅⠁⠅⠅⠅⠅⢅⢕⢅⢕⢥⠕⢕⢕⢅⢕⢅⠕⠅⠅⠅⠅⠅⠁⠅⠁⠅⠁⠅⠁⠄⠁⠄⠁⠄⠁⠄⠁⠄⣪⡺⣺⣺⣪⣺⣪⣺⣺⣺⣾⣺⣾⣺⣾⣺⣺⣺⣺⡺⡪⡺⡪⡚⣪⡪⡪⡺⡪⡺⣪⣺⣺⣺⣺⣺⣾⣺⣾⣺⣾⣺⣾⣻⣾⣻⣾⣻⣾⣻⣾⡃
⠕⠅⠅⠅⠕⠅⠕⠅⠅⠅⠅⠅⠅⠅⠁⠅⠅⢵⢝⢵⢽⢽⢝⢵⢽⢽⢝⢕⠕⢕⠕⠕⠕⢅⠑⠄⠁⠅⠁⠅⠁⠅⠁⠄⠁⠄⠁⠄⠁⠄⠁⠄⣪⣺⣺⣺⣪⣺⣪⣺⣺⣺⣺⣺⣺⣺⣾⣺⣺⡊⡢⡊⡂⡂⡢⡊⡂⡂⡢⡪⣪⡪⣪⣪⣪⡺⣮⣻⣾⣺⣾⣺⣾⣺⣾⣻⣾⣻⣾⣻⣾⣻⣾⡃
⠕⠅⠅⠅⠕⠅⠕⠅⠅⠅⠅⠅⠅⠅⠅⢕⢝⢵⢝⢝⢕⢅⢅⢅⠕⠅⠅⠕⢕⢅⠅⠅⠅⢅⠕⠅⠅⠕⠁⠅⠁⠅⠁⠄⠁⠄⠁⠄⠁⠄⠁⠄⣪⣺⣺⣺⣪⣺⣪⣺⣺⣺⣺⣺⣺⣺⣺⡪⡢⡊⡢⡢⡪⡺⡺⡺⣪⣺⣺⣪⡪⡺⣺⣺⣺⡺⣪⣺⣺⣪⣾⣺⣾⣺⣾⣻⣾⣻⣾⣻⣾⣻⣾⡃
⠕⢅⠅⠅⠁⠅⠁⠅⠁⠅⠅⠅⠅⢅⢕⢕⠝⠅⠕⠅⠅⠅⠅⢕⠅⢕⠅⠄⠁⠕⠁⠅⠁⠅⠁⠅⠁⠅⢕⢅⠅⠅⠁⠅⠁⠄⠁⠄⠁⠄⠁⠄⣪⡺⣺⣺⣾⣺⣾⣺⣾⣺⣺⣺⣺⡺⡪⡪⣢⣺⣪⣺⣺⣺⣺⡪⣺⡪⣺⣻⣾⣪⣾⣺⣾⣺⣾⣺⣾⣺⡪⡺⣺⣺⣾⣺⣾⣻⣾⣻⣾⣻⣾⡃
⠕⢅⠅⠅⠁⠅⠕⠅⠅⠅⠅⠅⠅⢕⠕⢅⠕⠅⠁⠅⠅⠅⠁⠅⠅⠅⠁⠅⠅⠅⠁⠅⠁⠄⠅⢅⠅⠅⠁⠅⠑⠅⠁⠅⠁⠄⠁⠄⠁⠄⠁⠄⣪⡺⣺⣺⣾⣺⣪⣺⣺⣺⣺⣺⣺⡪⣪⡺⣪⣺⣾⣺⣺⣺⣾⣺⣺⣺⣾⣺⣺⣺⣾⣺⣾⣻⣺⡺⣺⣺⣾⣺⣮⣺⣾⣺⣾⣻⣾⣻⣾⣻⣾⡃
⠕⢅⠅⠅⠁⠅⠕⠅⠅⠅⠅⠅⢕⢅⠅⢅⠅⠅⠁⢕⢽⣵⢵⢵⢵⢵⢕⢵⢕⢅⢅⢅⢵⢵⢕⢕⢕⢕⠕⠄⠁⠅⠅⠅⠁⠄⠁⠄⠁⠄⠁⠄⣪⡺⣺⣺⣾⣺⣪⣺⣺⣺⣺⣺⡪⡺⣺⡺⣺⣺⣾⡪⡂⠊⡊⡊⡊⡊⡪⡊⡪⡺⡺⡺⡊⡊⡪⡪⡪⡪⣪⣻⣾⣺⣺⣺⣾⣻⣾⣻⣾⣻⣾⡃
⠕⢅⠕⠅⠁⠅⠕⠅⠅⠅⠕⢵⢕⠅⠅⠅⠅⠄⠕⢕⢽⢽⢿⣽⢿⢽⢿⣽⢿⢽⢿⢽⢿⢽⢝⢵⢕⢕⠕⠅⠅⠅⠁⠅⠅⠅⠁⠅⠁⠅⠁⠄⣪⡺⣪⣺⣾⣺⣪⣺⣺⣺⣪⡊⡪⣺⣺⣺⣺⣻⣪⡪⡂⡂⡀⠂⡀⡂⡀⠂⡀⡂⡀⡂⡀⡂⡢⡊⡪⡪⣪⣺⣺⣺⣾⣺⣺⣺⣾⣺⣾⣺⣾⡃
⠕⠅⠕⠅⠁⠅⠕⢅⠅⢅⢕⢕⠕⢅⠅⠅⠅⠅⠅⠅⢝⢽⢿⢽⢿⢽⢿⢽⢿⢽⢿⣽⢿⢽⢝⢵⢝⢕⠅⠄⠁⠅⠕⢅⢅⠅⠅⠅⠁⠅⠁⠄⣪⣺⣪⣺⣾⣺⣪⡺⣺⡺⡪⡪⣪⡺⣺⣺⣺⣺⣺⣺⡢⡂⡀⡂⡀⡂⡀⡂⡀⡂⡀⠂⡀⡂⡢⡊⡢⡪⣺⣻⣾⣺⣪⡺⡺⣺⣺⣺⣾⣺⣾⡃
⠕⠅⠕⠅⠁⢅⢕⢕⢝⢽⢝⢅⢕⢅⠅⠄⠕⠅⠁⢵⢝⢽⢽⢽⢿⣽⢿⢽⢿⣽⢿⣽⢿⢽⢝⢵⢝⢕⠕⠅⠁⠅⠕⢕⠕⠅⠅⠅⠁⠄⠁⠄⣪⣺⣪⣺⣾⡺⡪⡪⡢⡂⡢⡺⡪⡺⣺⣻⣪⣺⣾⡊⡢⡂⡂⡂⡀⠂⡀⡂⡀⠂⡀⠂⡀⡂⡢⡊⡢⡪⣪⣺⣾⣺⣪⡪⣪⣺⣺⣺⣾⣻⣾⡃
⠕⠅⠕⠅⠑⢅⠕⢅⢝⢵⢕⢵⢕⠅⠁⠅⠁⠄⠁⢵⢝⢝⠝⠝⠝⠝⠟⠝⢿⢽⢽⢽⠝⠝⠝⠅⠁⢅⢕⠅⠁⠄⠁⠅⠑⠅⠁⠅⠅⠄⠁⠄⣪⣺⣪⣺⣮⡺⣪⡺⡢⡊⡪⡊⡪⣺⣾⣺⣾⣻⣾⡊⡢⡢⣢⣢⣢⣢⣠⣢⡀⡂⡂⡂⣢⣢⣢⣺⣾⡺⡪⣺⣾⣻⣾⣺⣮⣺⣾⣺⣺⣻⣾⡃
⠕⠅⠕⠅⠕⢅⢝⢵⢝⢵⢽⢕⢝⠅⠅⠄⠁⠄⢑⢽⢽⢵⢕⢵⢕⢵⢕⢵⢝⢽⢿⢕⢕⢕⢕⢕⢕⢕⢕⢕⢕⠅⠁⠅⠁⠅⠅⠅⠅⠅⠁⠄⣪⣺⣪⣺⣪⡺⡢⡊⡢⡊⡂⡪⡢⣺⣺⣻⣾⣻⡮⡂⡂⡊⡪⡊⡪⡊⡪⡊⡢⡂⡀⡪⡪⡪⡪⡪⡪⡪⡪⡪⡪⣺⣾⣺⣾⣺⣺⣺⣺⣺⣾⡃
⠕⠅⠕⠅⠕⢕⢽⢕⢝⢽⢝⢕⢕⢅⠅⠄⠅⠄⠑⢽⢽⢽⢿⣿⢿⣽⢿⢽⢝⢽⢝⢕⢝⢽⢝⢽⢽⢽⢝⢅⢝⠕⠁⠄⠑⢅⠕⢅⠁⠅⠁⠄⣪⣺⣪⣺⣪⡪⡂⡪⡢⡂⡢⡪⡪⡺⣺⣻⣺⣻⣮⡂⡂⡂⡀⠀⡀⠂⡀⡂⡢⡂⡢⡪⡢⡂⡢⡂⡂⡂⡢⡺⡢⣪⣾⣻⣮⡺⣪⡺⣾⣺⣾⡃
⠕⠅⠕⠅⠕⢅⢝⢵⢽⢵⢝⢝⢝⢅⠕⢅⠕⠅⠁⢕⢝⢽⢿⣽⢿⣽⢿⢽⢝⢽⢟⢕⢕⢽⢝⢽⢝⢕⢕⢅⠝⠅⠁⠄⠑⢕⢕⠅⠕⠅⠁⠄⣪⣺⣪⣺⣪⡺⡢⡊⡂⡊⡢⡢⡢⡺⣪⡺⣪⣺⣾⡪⡢⡂⡀⠂⡀⠂⡀⡂⡢⡂⡠⡪⡪⡂⡢⡂⡢⡪⡪⡺⣢⣺⣾⣻⣮⡪⡪⣺⣪⣺⣾⡃
⠕⠅⠕⠕⠕⢅⢽⢵⢝⢽⠝⢕⢕⢕⢕⢅⠁⠀⠁⢕⢝⢽⢝⢽⢽⢽⢿⢽⢝⢽⢝⢕⢝⢵⢝⢕⢝⢕⠕⢅⠁⠀⠁⠄⠁⠕⠕⠅⠅⠅⠁⠄⣪⣺⣪⣪⣪⡺⡂⡊⡢⡂⣢⡪⡪⡪⡪⡺⣾⣿⣾⡪⡢⡂⡢⡂⡂⡂⡀⡂⡢⡂⡢⡪⡢⡊⡢⡪⡢⡪⣪⡺⣾⣿⣾⣻⣾⣪⣪⣺⣺⣺⣾⡃
⠕⠅⠅⠅⠕⢵⢟⢵⢽⢝⢕⢕⢕⢕⠕⠅⠁⠀⠁⢅⢕⢕⢝⢽⢿⢽⢽⢵⢝⢝⠝⢕⢝⢕⢝⢕⠝⢕⢕⢅⠁⠀⠁⠄⠁⠅⠕⠅⠅⠄⠁⠄⣪⣺⣺⣺⣪⡊⡠⡊⡂⡢⡪⡪⡪⡪⣪⣺⣾⣿⣾⡺⡪⡪⡢⡂⡀⡂⡂⡊⡢⡢⣢⡪⡢⡪⡢⡪⣢⡪⡪⡺⣾⣿⣾⣻⣾⣺⣪⣺⣺⣻⣾⡃
⠕⢅⠕⢕⢕⢝⢟⢽⢝⢵⢕⢵⢕⠕⠅⠅⠁⠀⠁⢅⢝⢕⢝⢽⢝⢽⢝⢽⢝⢕⢕⢕⢝⢕⢕⢕⠕⢕⠕⠅⠁⠀⠁⠀⠁⠅⠅⠅⠁⠅⠁⠄⣪⡺⣪⡪⡪⡢⡠⡂⡢⡊⡪⡊⡪⣪⣺⣺⣾⣿⣾⡺⡢⡪⡢⡂⡢⡂⡢⡂⡢⡪⡪⡪⡢⡪⡪⡪⣪⡪⣪⣺⣾⣿⣾⣿⣾⣺⣺⣺⣾⣺⣾⡃
⠕⢅⢕⢕⢝⢝⢝⢽⢽⢵⢝⢕⠅⠅⠅⠅⠁⠄⠁⠀⠝⢵⢝⢽⢝⢵⢵⢵⢵⢭⢝⢵⢕⢕⢕⢕⠕⢕⠕⢕⠅⠄⠁⠀⠁⠅⠅⠅⠅⠅⠕⠅⣪⡺⡪⡪⡢⡢⡢⡂⡂⡊⡢⡪⣺⣺⣺⣺⣾⣻⣾⣿⣢⡊⡢⡂⡢⡊⡊⡊⡊⡒⡢⡊⡪⡪⡪⡪⣪⡪⣪⡪⣺⣻⣾⣿⣾⣺⣺⣺⣺⣺⣪⡂
⠕⢝⢕⢕⢕⢽⢽⢽⢽⢽⢝⢕⢕⠅⠅⠅⠁⠀⠁⠀⠁⠑⠝⢕⢝⢽⢝⢵⢝⢕⢕⢕⢕⢕⢕⢕⠕⢅⢕⢅⠕⢕⢕⢄⠅⠀⠁⠅⠁⠅⠁⠅⣪⡢⡪⡪⡪⡂⡂⡂⡂⡂⡢⡪⡪⣺⣺⣺⣾⣿⣾⣿⣾⣮⣢⡪⡢⡂⡢⡊⡢⡪⡪⡪⡪⡪⡪⡪⣪⡺⡪⡺⣪⡪⡪⡻⣺⣿⣾⣺⣾⣺⣾⡂
⠕⢵⢕⢵⢝⢽⢽⣽⢝⢕⢕⢕⠝⠅⠅⠅⠁⠄⠁⠀⠁⠀⠑⢅⠝⢽⢝⢽⢿⢽⢿⢽⢝⢕⠕⢅⢕⢕⢕⢕⢕⢕⢝⢕⢕⢕⠅⠄⠁⠀⠁⠄⣪⡊⡪⡊⡢⡂⡂⠂⡢⡪⡪⡪⣢⣺⣺⣺⣾⣻⣾⣿⣾⣿⣮⡺⣢⡂⡢⡂⡀⡂⡀⡂⡢⡪⣪⡺⡪⡪⡪⡪⡪⡪⡢⡪⡪⡪⣺⣻⣾⣿⣾⡃
⢕⢵⢽⣽⢿⢽⢝⢝⢵⢕⠝⠕⠅⢅⠅⠅⠁⠅⠁⠄⠁⠀⠁⠅⢕⢕⠝⢕⠝⠝⠝⠕⠝⢅⢕⢕⢕⢕⢝⢕⢝⢕⢝⢕⢝⢕⢝⢅⠁⠄⠁⠄⡪⡊⡂⠂⡀⡂⡢⡢⡊⡪⣢⣪⣺⡺⣺⣺⣾⣺⣾⣻⣾⣿⣾⣺⡪⡪⣢⡪⣢⣢⣢⣪⣢⡺⡪⡪⡪⡪⡢⡪⡢⡪⡢⡪⡢⡪⡢⡺⣾⣻⣾⡃
⢽⢽⢟⢝⢝⢵⢽⢝⢕⠅⠕⠅⠁⠅⠁⠄⠁⠄⠁⠄⠁⠄⠁⢄⠕⢕⢕⢵⢕⢵⢕⢵⢕⢵⢝⢵⢝⢵⢝⢵⢝⢕⢝⢕⢝⢕⢕⢕⢕⠄⠁⠄⡂⡂⡠⡢⡢⡊⡂⡢⡪⣺⣪⣺⣾⣺⣾⣻⣾⣻⣾⣻⣾⣻⣾⡻⣪⡪⡪⡊⡪⡊⡪⡊⡪⡊⡢⡊⡢⡊⡢⡊⡢⡪⡢⡪⡢⡪⡪⡪⡪⣻⣾⡃
⢝⢽⢝⢽⢟⢽⢝⢵⢕⠅⠁⠄⠅⠄⠁⠄⠁⠄⠁⠄⠁⠀⠁⠅⠕⢕⢝⢕⢝⢽⢝⢵⢝⢵⢽⢽⢽⢽⢝⢵⢝⢵⢝⢵⢝⢵⢝⢕⢝⢕⠅⠄⡢⡂⡢⡂⡠⡂⡢⡊⡪⣺⣾⣻⣺⣻⣾⣻⣾⣻⣾⣻⣾⣿⣾⣺⣪⡪⡢⡪⡢⡂⡢⡊⡢⡊⡂⡂⡂⡂⡢⡊⡢⡊⡢⡊⡢⡊⡢⡪⡢⡪⣺⡃
⠝⢽⢝⢽⢝⢽⠝⠕⠅⠅⠅⠅⠁⠄⠁⠄⠁⠅⠁⠄⠁⠀⠁⠄⢕⢵⢝⢵⢝⢽⢝⢽⢽⢽⢽⢽⢽⢵⢕⢽⢝⢽⢝⢵⢝⢵⢝⢵⢝⢕⢕⠅⣢⡂⡢⡂⡢⡂⣢⣪⣺⣺⣺⣺⣾⣻⣾⣻⣾⣺⣾⣻⣾⣿⣾⣻⡪⡊⡢⡊⡢⡂⡢⡂⡂⡂⡂⡂⡂⡊⡪⡂⡢⡂⡢⡊⡢⡊⡢⡊⡢⡪⡪⡂
⠝⠽⠝⠵⠝⠕⠕⠅⠕⠅⠁⠄⠁⠄⠁⠄⠁⠄⠁⠄⠁⠄⠁⠅⠕⠽⠝⠽⠝⠵⠝⠽⠽⠽⠿⠽⠽⠵⠝⠵⠝⠵⠝⠵⠝⠵⠝⠵⠝⠵⠝⠅⠢⠂⠢⠊⠢⠪⠪⠺⠪⠺⠾⠻⠾⠻⠾⠻⠾⠻⠾⠻⠾⠻⠾⠺⠪⠂⠢⠂⠢⠊⠢⠂⠂⠂⠀⠂⠂⠊⠢⠊⠢⠊⠢⠊⠢⠊⠢⠊⠢⠊⠢⠂
```

For a more in-depth introduction, [take a look at the docs](https://juliaimages.org/DitherPunk.jl/stable/generated/simple_example/).

## List of implemented algorithms
* Error diffusion:
  * `FloydSteinberg` (default)
  * `JarvisJudice`
  * `Atkinson`
  * `Stucki`
  * `Burkes`
  * `Sierra`
  * `TwoRowSierra`
  * `SierraLite`
  * `Fan93`
  * `ShiauFan`
  * `ShiauFan2`
  * `SimpleErrorDiffusion`
* Ordered dithering:
  * `Bayer` (default level = 1)
* Halftoning:
  * `ClusteredDots` 
  * `CentralWhitePoint` 
  * `BalancedCenteredPoint` 
  * `Rhombus`
  * Threshold maps from ImageMagick:
    * `IM_checks`
    * `IM_h4x4a`
    * `IM_h6x6a`
    * `IM_h8x8a`
    * `IM_h4x4o`
    * `IM_h6x6o`
    * `IM_h8x8o`
    * `IM_c5x5`
    * `IM_c6x6`
    * `IM_c7x7`
* Other:
  * `ClosestColor`
  * `ConstantThreshold`
  * `WhiteNoiseThreshold`

___

**Share your creations in the [discussions tab](https://github.com/JuliaImages/DitherPunk.jl/discussions/categories/show-and-tell) and leave a GitHub Issue if you know of any cool  algorithms you'd like to see implemented! 🔬🔧**

[docs-stab-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stab-url]: https://JuliaImages.github.io/DitherPunk.jl/stable

[docs-dev-img]: https://img.shields.io/badge/docs-main-blue.svg
[docs-dev-url]: https://JuliaImages.github.io/DitherPunk.jl/dev

[ci-img]: https://github.com/JuliaImages/DitherPunk.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/JuliaImages/DitherPunk.jl/actions

[codecov-img]: https://codecov.io/gh/JuliaImages/DitherPunk.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/JuliaImages/DitherPunk.jl

[alg-list-url]: https://github.com/JuliaImages/DitherPunk.jl#list-of-implemented-algorithms

[atkinson-bw]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/Atkinson.png
[atkinson-col]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/AtkinsonColor.png
[bayer-bw]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/Bayer.png
[bayer-col]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/BayerColor.png
[ordered-bw]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/Rhombus.png
[ordered-col]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/RhombusColor.png
[fs-bw]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/FloydSteinberg.png
[fs-col]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/FloydSteinbergColor.png

[cs_PuOr_6]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/FloydSteinberg_PuOr_6.png
[cs_flag_us]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/FloydSteinberg_flag_us.png
[websafe]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/FloydSteinberg_websafe.png

[clustering_2]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/FloydSteinberg_2.png
[clustering_8]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/FloydSteinberg_8.png
[clustering_32]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/FloydSteinberg_32.png