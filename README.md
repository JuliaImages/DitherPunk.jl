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

img = testimage("fabio_gray_256") # load an image
d = dither(img, FloydSteinberg()) # apply algorithm of your choice

dither!(img, FloydSteinberg())    # or in-place modify image
```

All algorithms can be used for binary or channel-wise dithering:
| **Error diffusion** | **Ordered dithering** | **Digital halftoning** |
|:-------------------:|:---------------------:|:----------------------:|
| ![][atkinson-bw]    | ![][bayer-bw]         | ![][ordered-bw]        |
| ![][atkinson-col]   | ![][bayer-col]        | ![][ordered-col]       |

All error diffusion, ordered dithering and halftoning methods support custom color palettes. Define your own palette or use the symbols from the [ColorSchemes.jl catalogue](https://juliagraphics.github.io/ColorSchemes.jl/stable/catalogue) directly:
```julia
using DitherPunk
using ColorSchemes

dither(img, FloydSteinberg(), :flag_us)
```
| `:flag_us`      | `:PuOr_6`      | `:websafe`   |
|:---------------:|:--------------:|:------------:|
| ![][cs_flag_us] | ![][cs_PuOr_6] | ![][websafe] |

DitherPunk also works with [Clustering.jl](https://github.com/JuliaStats/Clustering.jl) to let you generate optimized color palettes for each input image:
```julia
using DitherPunk
using Clustering

ncolors = 8
dither(img, FloydSteinberg(), ncolors)
```
| 2 colors          | 8 colors          | 32 colors          |
|:-----------------:|:-----------------:|:------------------:|
| ![][clustering_2] | ![][clustering_8] | ![][clustering_32] |

For a more in-depth introduction, [take a look at the docs](https://juliaimages.org/DitherPunk.jl/stable/generated/simple_example/).
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