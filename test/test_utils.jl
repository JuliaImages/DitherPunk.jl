using DitherPunk

A = [1 2; 3 4]

@test upscale(A, 3) == [
    1 1 1 2 2 2
    1 1 1 2 2 2
    1 1 1 2 2 2
    3 3 3 4 4 4
    3 3 3 4 4 4
    3 3 3 4 4 4
]
