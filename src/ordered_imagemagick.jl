# Copyright 2021 Adrian Hill
#
# Licensed under the ImageMagick License (the "License"); you may not use
# this file except in compliance with the License.  You may obtain a copy
# of the License at
#
#   https://imagemagick.org/script/license.php
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

## Ordered dithering matrices from ImageMagic
"""
    IM_checks()

ImageMagick's Checkerboard 2x2 dither
"""
IM_checks(; kwargs...) = OrderedDither(CHECKS; kwargs...)
const CHECKS = [
    1 2
    2 1
]//3

## ImageMagic's Halftones - Angled 45 degrees
# Initially added to ImageMagick by Glenn Randers-Pehrson, IM v6.2.8-6,
# modified to be more symmetrical with intensity by Anthony, IM v6.2.9-7

"""
    IM_h4x4a()

ImageMagick's Halftone 4x4 - Angled 45 degrees
"""
IM_h4x4a(; kwargs...) = OrderedDither(H4X4A; kwargs...)
const H4X4A = [
    4 2 7 5
    3 1 8 6
    7 5 4 2
    8 6 3 1
]//9

"""
    IM_h6x6a()

ImageMagick's Halftone 6x6 - Angled 45 degrees
"""
IM_h6x6a(; kwargs...) = OrderedDither(H6X6A; kwargs...)
const H6X6A =
    [
        14 13 10 8 2 3
        16 18 12 7 1 4
        15 17 11 9 6 5
        8 2 3 14 13 10
        7 1 4 16 18 12
        9 6 5 15 17 11
    ]//19

"""
    IM_h8x8a()

ImageMagick's Halftone 8x8 - Angled 45 degrees
"""
IM_h8x8a(; kwargs...) = OrderedDither(H8X8A; kwargs...)
const H8X8A =
    [
        13 7 8 14 17 21 22 18
        6 1 3 9 28 31 29 23
        5 2 4 10 27 32 30 24
        16 12 11 15 20 26 25 19
        17 21 22 18 13 7 8 14
        28 31 29 23 6 1 3 9
        27 32 30 24 5 2 4 10
        20 26 25 19 16 12 11 15
    ]//33

# ImageMagic's Halftones - Orthogonally Aligned, or Un-angled
# Initially added by Anthony Thyssen, IM v6.2.9-5 using techniques from
# "Dithering & Halftoning" by Gernot Haffmann
# http://www.fho-emden.de/~hoffmann/hilb010101.pdf

"""
    IM_h4x4o()

ImageMagick's Halftone 4x4 - Orthogonally Aligned
"""
IM_h4x4o(; kwargs...) = OrderedDither(H4X4O; kwargs...)
const H4X4O = [
    7 13 11 4
    12 16 14 8
    10 15 6 2
    5 9 3 1
]//17

"""
    IM_h6x6o()

ImageMagick's Halftone 6x6 - Orthogonally Aligned
"""
IM_h6x6o(; kwargs...) = OrderedDither(H6X6O; kwargs...)
const H6X6O =
    [
        7 17 27 14 9 4
        21 29 33 31 18 11
        24 32 36 34 25 22
        19 30 35 28 20 10
        8 15 26 16 6 2
        5 13 23 12 3 1
    ]//37

"""
    IM_h8x8o()

ImageMagick's Halftone 8x8 - Orthogonally Aligned
"""
IM_h8x8o(; kwargs...) = OrderedDither(H8X8O; kwargs...)
const H8X8O =
    [
        7 21 33 43 36 19 9 4
        16 27 51 55 49 29 14 11
        31 47 57 61 59 45 35 23
        41 53 60 64 62 52 40 38
        37 44 58 63 56 46 30 22
        15 28 48 54 50 26 17 10
        8 18 34 42 32 20 6 2
        5 13 25 39 24 12 3 1
    ]//65

## ImageMagic's Halftones - Orthogonally Expanding Circle Patterns
# Added by Glenn Randers-Pehrson, 4 Nov 2010, ImageMagick 6.6.5-6
"""
    IM_c5x5()

ImageMagick's Halftone 5x5 - Orthogonally Expanding Circle Patterns
"""
IM_c5x5(; kwargs...) = OrderedDither(C5X5; kwargs...)
const C5X5 = [
    1 21 16 15 4
    5 17 20 19 14
    6 21 25 24 12
    7 18 22 23 11
    2 8 9 10 3
]//26

"""
    IM_c6x6()

ImageMagick's Halftone 6x6 - Orthogonally Expanding Circle Patterns
"""
IM_c6x6(; kwargs...) = OrderedDither(C6X6; kwargs...)
const C6X6 =
    [
        1 5 14 13 12 4
        6 22 28 27 21 11
        15 29 35 34 26 20
        16 30 36 33 25 19
        7 23 31 32 24 10
        2 8 17 18 9 3
    ]//37

"""
    IM_c7x7()

ImageMagick's Halftone 7x7 - Orthogonally Expanding Circle Patterns
"""
IM_c7x7(; kwargs...) = OrderedDither(C7X7; kwargs...)
const C7X7 =
    [
        3 9 18 28 17 8 2
        10 24 33 39 32 23 7
        19 34 44 48 43 31 16
        25 40 45 49 47 38 27
        20 35 41 46 42 29 15
        11 21 36 37 28 22 6
        4 12 13 26 14 5 1
    ]//50
