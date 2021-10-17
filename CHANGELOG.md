# DitherPunk
## Version `v2.0.0`

This release introduces some breaking changes due to an API overhaul and adds new functionality through conditional dependencies:
- ![BREAKING][badge-breaking] Dithering color images without specifying a color palette will now automatically apply per-channel binary dithering. ([#45][github-45])
- ![BREAKING][badge-breaking] Because of the previously mentioned change, `SeparateSpace` and its type `AbstractFixedColorDither` are not needed anymore and were removed. ([#45][github-45])
- ![Enhancement][badge-enhancement] Enhanced error message when trying to use color palettes on methods that don't support them (Julia >=1.5). ([#45][github-45])
- ![Feature][badge-feature] Support for ColorSchemes.jl. ([#45][github-45])
- ![Feature][badge-feature] Support for Clustering.jl: automatically generate color palettes via K-means clustering. ([#45][github-45])
- ![Feature][badge-feature] Support for UnicodePlots.jl: print binary images using Unicode Braille patterns with `braille` . ([#45][github-45])
- ![Bugfix][badge-bugfix] Error diffusion kwargs are now accessible. ([#45][github-45])


[github-45]: https://github.com/JuliaImages/DitherPunk.jl/pull/45

[badge-breaking]: https://img.shields.io/badge/BREAKING-red.svg
[badge-deprecation]: https://img.shields.io/badge/deprecation-orange.svg
[badge-feature]: https://img.shields.io/badge/feature-green.svg
[badge-enhancement]: https://img.shields.io/badge/enhancement-blue.svg
[badge-bugfix]: https://img.shields.io/badge/bugfix-purple.svg
[badge-security]: https://img.shields.io/badge/security-black.svg
[badge-experimental]: https://img.shields.io/badge/experimental-lightgrey.svg
[badge-maintenance]: https://img.shields.io/badge/maintenance-gray.svg

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
-->