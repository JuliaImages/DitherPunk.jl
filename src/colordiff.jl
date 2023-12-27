if VERSION >= v"1.7"
    _closest_color_idx(px, cs, metr) = argmin(colordiff(px, c; metric=metr) for c in cs)
else
    _closest_color_idx(px, cs, metr) = argmin([colordiff(px, c; metric=metr) for c in cs])
end

