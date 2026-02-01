# Branch `ah/lut` - Color Picker Abstraction

## What's Been Implemented

### New Abstractions
- `AbstractColorPicker{C}` - abstract type parameterized by colorspace ([src/color_picker.jl:1](src/color_picker.jl:1))
- `RuntimeColorPicker` - selects closest color at runtime using a difference metric ([src/color_picker.jl:20](src/color_picker.jl:20))
- `LookupColorPicker` - precomputes a 256³ lookup table for RGB{N0f8} ([src/color_picker.jl:62](src/color_picker.jl:62))

### New Color Utilities
- `FastEuclideanMetric` - faster Euclidean distance for RGB{N0f8} ([src/colordiff.jl:11](src/colordiff.jl:11))
- `colorspace()` - returns the optimal colorspace for each metric ([src/colordiff.jl:33](src/colordiff.jl:33))

### API Changes
- Renamed `colordither` → `colordither!` (now mutates output) ([src/api/color.jl:42](src/api/color.jl:42))
- Changed kwarg from `metric` → `colorpicker`
- Added `select_colorpicker()` for algorithm-specific defaults ([src/api/color.jl:1](src/api/color.jl:1))

### Algorithm Updates
- `ErrorDiffusion` refactored to use `colorpicker` ([src/error_diffusion.jl:95](src/error_diffusion.jl:95))
- `OrderedDither` refactored to use `colorpicker` ([src/ordered.jl:55](src/ordered.jl:55))
- `ClosestColor` refactored to use `colorpicker` ([src/closest_color.jl:12](src/closest_color.jl:12))

---

## Current Test Failures (6 failed, 15 errored)

| Issue | Cause |
|-------|-------|
| `no method matching -(::Lab{Float32}, ::Lab{Float32})` | Error diffusion tries arithmetic on Lab colors which don't support `-`, `+`, `*` |
| `BoundsError: index [0, ...]` in LookupColorPicker | Off-by-one bug in LUT indexing when colors map outside 1-256 range |
| `IndirectArray` type mismatch | Conversion fails for indexed input images |
| `DomainError` with `log10` in DE_BFD | Clamping needed before color difference with XYZ |

---

## What's Missing

1. **Arithmetic support for Lab/XYZ in error diffusion** - The old code converted to XYZ for arithmetic. Need to either:
   - Use ColorVectorSpace.jl for arithmetic on color types
   - Keep a separate "error colorspace" for diffusion

2. **Fix LUT bounds checking** - Need to clamp RGB values to valid range before indexing ([src/color_picker.jl:97](src/color_picker.jl:97))

3. **Handle input type edge cases** - Fix IndirectArray/OffsetArray inputs

4. **Marked TODOs in code:**
   - [src/colordiff.jl:26](src/colordiff.jl:26) - safe conversion to RGB{N0f8} using clamp01
   - [src/colordiff.jl:28](src/colordiff.jl:28) - add fast metric for numeric inputs
   - [src/api/color.jl:69](src/api/color.jl:69) - deprecate grayscale→color fallback
   - [src/ordered.jl:119](src/ordered.jl:119) - deprecate optional argument for Bayer

5. **Documentation** - New public types need docstrings:
   - `AbstractColorPicker`
   - `RuntimeColorPicker`
   - `LookupColorPicker`
   - `FastEuclideanMetric`
