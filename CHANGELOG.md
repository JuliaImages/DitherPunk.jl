# DitherPunk
## Version `v3.0.3`
- ![Enhancement][badge-enhancement] Replace UnicodePlots.jl dependency with custom `braille` implementation ([#91][pr-91])
- ![Enhancement][badge-enhancement] Revert default metric to `DE_2000` for higher image quality ([#92][pr-92])

## Version `v3.0.2`
- ![Documentation][badge-docs] Update documentation to show off new functionality ([#88][pr-88])

## Version `v3.0.1`
- ![Enhancement][badge-enhancement] Use faster default color difference metric `DE_AB` ([#87][pr-87])

*Note*: this was reverted in PR [#92][pr-92], released in DitherPunk `v3.0.3`.

## Version `v3.0.0`
This breaking release of DitherPunk raises the minimum Julia version requirement from 1.0 to 1.6 ([#82][pr-82]).
- ![Feature][badge-feature] Add default method `FloydSteinberg`, such that `dither` can be called without passing an algorithm ([477c98e][commit-477c98e])
- ![Feature][badge-feature] Add default method for `braille` ([#85][pr-85])
- ![Feature][badge-feature] Add option to invert `braille` output ([#85][pr-85])
- ![Enhancement][badge-enhancement] Lazily load Clustering.jl and UnicodePlots.jl ([#77][pr-77])
- ![Documentation][badge-docs] Updated docs ([#73][pr-73])

Refactored `ErrorDiffusion` algorithms: 
- ![BREAKING][badge-breaking] Deprecate keyword `color_space` ([#73][pr-73])
- ![BREAKING][badge-breaking] Remove `colorspace` argument ([#84][pr-84])
- ![BREAKING][badge-breaking] Turn `clamp_error` into a keyword argument ([#86][pr-86])
- ![Enhancement][badge-enhancement] Performance improvements ([#73][pr-73])
- ![Enhancement][badge-enhancement] Drop OffsetArrays.jl dependency ([#73][pr-73])
- ![Enhancement][badge-enhancement] Column-first iteration ([#80][pr-80])
- ![Bugfix][badge-bugfix] Fix bug where kwargs were not accessible in `SimpleErrorDiffusion` ([#73][pr-73])

## Version `v2.4.1`
- ![Bugfix][badge-bugfix] Fix colormap index overflow bug ([#78][pr-78])

## Version `v2.4.0`
- ![Enhancement][badge-enhancement] Downsample image before clustering ([#71][pr-71])

## Version `v2.3.1`
- ![Enhancement][badge-enhancement] Type stability fixes ([#66][pr-66])
- ![Bugfix][badge-bugfix] Fix doc build ([#65][pr-65])

## Version `v2.3.0`
- ![Feature][badge-feature] Color space for error diffusion can now be selected. Defaults to `XYZ`, a change from previous `RGB` color space. Changes outputs and speeds up color error diffusion. ([#63][pr-63])
- ![Enhancement][badge-enhancement] Speed up color ordered dithering. ([#62][pr-62])
- ![Documentation][badge-docs] Better docstrings for error diffusion algorithms. ([#63][pr-63])
- ![Documentation][badge-docs] Added ASCII dithering example to docs. ([#64][pr-64])

## Version `v2.2.0`
- ![Feature][badge-feature] Ordered dithering algorithms now support custom color palettes. ([#53][pr-53])
- ![Enhancement][badge-enhancement] Color palette generation with Clustering.jl has been made accessible as `DitherPunk.get_colorscheme`. ([#58][pr-58])
- ![Bugfix][badge-bugfix] Fixed docstring warnings. ([#56][pr-56])
- ![Documentation][badge-docs] Added three advanced examples to docs. ([#58][pr-58])

## Version `v2.1.0`
- ![Feature][badge-feature] Color dithering methods now return IndirectArrays. ([#47][pr-47])
- ![Enhancement][badge-enhancement] Performance enhancements. Most noticeable for color methods. ([#47][pr-47])
- Dropped dependency on TiledIteration. ([#47][pr-47])
- `invert_map` is now a keyword argument of ordered dithering constructors. ([#50][pr-50])

## Version `v2.0.0`
This release introduces some breaking changes due to an API overhaul and adds new functionality through conditional dependencies:
- ![BREAKING][badge-breaking] Dithering color images without specifying a color palette will now automatically apply per-channel binary dithering. ([#45][pr-45])
- ![BREAKING][badge-breaking] Because of the previously mentioned change, `SeparateSpace` and its type `AbstractFixedColorDither` are not needed anymore and were removed. ([#45][pr-45])
- ![Enhancement][badge-enhancement] Enhanced error message when trying to use color palettes on methods that don't support them (Julia >=1.5). ([#45][pr-45])
- ![Feature][badge-feature] Support for ColorSchemes.jl. ([#45][pr-45])
- ![Feature][badge-feature] Support for Clustering.jl: automatically generate color palettes via K-means clustering. ([#45][pr-45])
- ![Feature][badge-feature] Support for UnicodePlots.jl: print binary images using Unicode Braille patterns with `braille` . ([#45][pr-45])
- ![Bugfix][badge-bugfix] Error diffusion kwargs are now accessible. ([#45][pr-45])

<!--
# Badges
![BREAKING][badge-breaking]
![Deprecation][badge-deprecation]
![Feature][badge-feature]
![Enhancement][badge-enhancement]
![Bugfix][badge-bugfix]
![Security][badge-security]
![Experimental][badge-experimental]
![Maintenance][badge-maintenance]
![Documentation][badge-docs]
-->

[pr-45]: https://github.com/JuliaImages/DitherPunk.jl/pull/45
[pr-47]: https://github.com/JuliaImages/DitherPunk.jl/pull/47
[pr-50]: https://github.com/JuliaImages/DitherPunk.jl/pull/50
[pr-53]: https://github.com/JuliaImages/DitherPunk.jl/pull/53
[pr-56]: https://github.com/JuliaImages/DitherPunk.jl/pull/56
[pr-58]: https://github.com/JuliaImages/DitherPunk.jl/pull/58
[pr-62]: https://github.com/JuliaImages/DitherPunk.jl/pull/62
[pr-63]: https://github.com/JuliaImages/DitherPunk.jl/pull/63
[pr-64]: https://github.com/JuliaImages/DitherPunk.jl/pull/64
[pr-65]: https://github.com/JuliaImages/DitherPunk.jl/pull/65
[pr-66]: https://github.com/JuliaImages/DitherPunk.jl/pull/66
[pr-71]: https://github.com/JuliaImages/DitherPunk.jl/pull/71
[pr-73]: https://github.com/JuliaImages/DitherPunk.jl/pull/73
[pr-77]: https://github.com/JuliaImages/DitherPunk.jl/pull/77
[pr-78]: https://github.com/JuliaImages/DitherPunk.jl/pull/78
[pr-80]: https://github.com/JuliaImages/DitherPunk.jl/pull/80
[pr-82]: https://github.com/JuliaImages/DitherPunk.jl/pull/82
[pr-84]: https://github.com/JuliaImages/DitherPunk.jl/pull/84
[pr-85]: https://github.com/JuliaImages/DitherPunk.jl/pull/85
[pr-86]: https://github.com/JuliaImages/DitherPunk.jl/pull/86
[pr-87]: https://github.com/JuliaImages/DitherPunk.jl/pull/87
[pr-88]: https://github.com/JuliaImages/DitherPunk.jl/pull/88
[pr-90]: https://github.com/JuliaImages/DitherPunk.jl/pull/90
[pr-91]: https://github.com/JuliaImages/DitherPunk.jl/pull/91
[pr-92]: https://github.com/JuliaImages/DitherPunk.jl/pull/92

[commit-477c98e]: https://github.com/JuliaImages/DitherPunk.jl/commit/477c98ed37b81fed7f6292a364b08a6b516bfb07

[badge-breaking]: https://img.shields.io/badge/BREAKING-red.svg
[badge-deprecation]: https://img.shields.io/badge/deprecation-orange.svg
[badge-feature]: https://img.shields.io/badge/feature-green.svg
[badge-enhancement]: https://img.shields.io/badge/enhancement-blue.svg
[badge-bugfix]: https://img.shields.io/badge/bugfix-purple.svg
[badge-security]: https://img.shields.io/badge/security-black.svg
[badge-experimental]: https://img.shields.io/badge/experimental-lightgrey.svg
[badge-maintenance]: https://img.shields.io/badge/maintenance-gray.svg
[badge-docs]: https://img.shields.io/badge/docs-orange.svg
