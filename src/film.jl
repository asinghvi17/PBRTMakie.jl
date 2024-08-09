
abstract type AbstractFilm end

@kwdef struct ImageParams 
    "Film sensitivity to light; final pixel values are scaled by the `iso` value divided by 100."
    iso::Float64 = 100.
    "If non-zero, this gives a temperature in degrees kelvin that is used as the reference color temperature used for whitebalancing."
    whitebalance::Float64 = 0.
    "Characterizes the sensor's response for red, green, and blue colors. The default corresponds to using the CIE 1931 spectral response curves. Alternatively, the measured response curves are available for some other cameras.  Check the PBRT website's file format spec for more info."
    sensor::String = "cie1931"
    # "Image sample values with luminance greater than this value are clamped to have this luminance. (This is a hack, but can be useful for eliminating large variance spikes in scenes with difficult light transport.)"
    # maxcomponentvalue::Float64 = Inf
end

@kwdef struct CommonFilmParams 
    "The number of pixels in the x direction."
    xresolution::Int = 1280
    "The number of pixels in the y direction."
    yresolution::Int = 760
    "The sub-region of the image to render. The four values specified should be fractions in the range [0,1], and they represent x_min, x_max, y_min, and y_max, respectively. These values are in normalized device coordinates, with (0,0) in the upper-left corner of the image."
    cropwindow::NTuple{4, Float64} = (0.0, 1.0, 0.0, 1.0)
    "A sub-region of the image to render, specified using pixel coordinates."
    pixelbounds::NTuple{4, Int} = (0, xresolution, 0, yresolution)
    "Diagonal length of the film, in mm. (This value is only used when the RealisticCamera is used.)"
    diagonal::Float64 = 35.
    "The output filename."
    filename::String = "output.png"
    "Whether 16-bit floating point values (as opposed to 32-bit floating point values) should be used when saving images in OpenEXR format."
    savefp16::Bool = true
end


struct RGBFilm <: AbstractFilm
    common::CommonFilmParams
    image::ImageParams
end

struct GBufferFilm <: AbstractFilm
    common::CommonFilmParams
    image::ImageParams
    coordinatesystem::String = "camera" # "camera" or "world"
end

struct SpectralFilm <: AbstractFilm
    common::CommonFilmParams
    image::ImageParams
    nbuckets::Int = 16
    lambdamin::Float64 = 360.
    lambdamax::Float64 = 830.
end


type_string(::Type{AbstractFloat}) = "float"
type_string(::Type{AbstractInt}) = "integer"
type_string(::Type{AbstractString}) = "string"
type_string(::Type{AbstractBool}) = "boolean"

type_string(::NTuple{N, T}) where {N, T} = type_string(T) # in PBRT, there's no difference between tuples and vectors.


function render(io, film::CommonFilmParams)
    for property in propertynames(film)
        type = typeof(getproperty(film, property))
        if type isa VecTypes
            type_string = 
    end
end