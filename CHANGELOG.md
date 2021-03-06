# DitherPunk
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

[badge-breaking]: https://img.shields.io/badge/BREAKING-red.svg
[badge-deprecation]: https://img.shields.io/badge/deprecation-orange.svg
[badge-feature]: https://img.shields.io/badge/feature-green.svg
[badge-enhancement]: https://img.shields.io/badge/enhancement-blue.svg
[badge-bugfix]: https://img.shields.io/badge/bugfix-purple.svg
[badge-security]: https://img.shields.io/badge/security-black.svg
[badge-experimental]: https://img.shields.io/badge/experimental-lightgrey.svg
[badge-maintenance]: https://img.shields.io/badge/maintenance-gray.svg
[badge-docs]: https://img.shields.io/badge/docs-orange.svg
