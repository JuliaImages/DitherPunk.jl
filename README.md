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

and all error diffusion methods support custom color palettes:
```julia
using ColorSchemes

dither(img, FloydSteinberg(), ColorSchemes.PuOr_7)
```
![][fs-pal]

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
[fs-pal]: https://raw.githubusercontent.com/JuliaImages/DitherPunk.jl/gh-pages/assets/FloydSteinbergPuOr7.png
