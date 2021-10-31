using DitherPunk
using ColorSchemes
using Clustering
using Images
using TestImages

imgg = testimage("fabio_gray_256.png")
imgc = testimage("fabio_color_256")

for alg in [FloydSteinberg, Atkinson, Bayer, Rhombus]
    # Binary dither
    save("assets/$(alg).png", dither(imgg, alg()))
    # Per channel dither
    save("assets/$(alg)Color.png", dither(imgc, alg()))
end

# ColorSchemes
for cs in [:PuOr_6, :RdBu_10, :websafe, :flag_us]
    save("assets/FloydSteinberg_$(cs).png", dither(imgc, FloydSteinberg(), cs))
end

# Clustering
imgc = imresize(testimage("lake_color"), ratio=1//2)
for ncols in 2 .^ (1:5)
    save("assets/FloydSteinberg_$(ncols).png", dither(imgc, FloydSteinberg(), ncols))
end
