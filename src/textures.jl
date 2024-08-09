#=
## Textures for meshes
- If the mesh's color is specified as numbers per vertex, then we make the colormap a deeply sampled texture,
  and mutate the mesh UVs (or add UVs) such that the `v`s are 0 and the `u`s are the values normalized to [0, 1].
- If the mesh's color is specified as colors per vertex, then we actually need to write out the colors as vertex attributes
  in the ply mesh.  This is supported by the standard, and the attribute names are "red", "green", and "blue".
- If the mesh's color is specified as a texture, then we just use that texture, and assert that the mesh must have UVs.

## Textures for surfaces
The same principles as those for meshes apply also to surfaces.  Ideally we would be able to control interpolation but we'll have to see.
PBRT may need to be patched to support this.

## Textures for image/heatmap
With interpolation enabled this is just a quad face with a texture.  Without interpolation, though, is probably not currently supported in PBRT.

I guess we can use the CairoMakie approach of generating a bunch of rectangles or quad faces with constant color, but that will fail very quickly
if the image is large.  We'll have to see.

TODO: check the PBRT google group to see if anyone responded to my (@asinghvi17) question about this.
=#

function plottable_mesh_files(mesh::GeometryBasics.Mesh, color, colormap, colorrange, lowclip, highclip, nan_color, colorscale)

end

function plottable_mesh_files(mesh::GeometryBasics.Mesh, color::AbstractVector{<: Colors.Colorant}, colormap, colorrange, lowclip, highclip, nan_color, colorscale)
    @assert length(color) == length(GeometryBasics.coordinates(mesh))
    red = Colors.red.(color)
    green = Colors.green.(color)
    blue = Colors.blue.(color)

    ply = PlyIO.Ply(mesh; vertex_attributes = (; red, green, blue))
end

function plottable_mesh_files(mesh::GeometryBasics.Mesh, color::AbstractMatrix{<: Colors.Colorant}, colormap, colorrange, lowclip, highclip, nan_color, colorscale)
    current_uuid = uuid4()
    texture_file = "texture_$current_uuid.exr"
    OpenEXR.save(texture_file, color)
    mesh_file = "mesh_$current_uuid.ply"
    PlyIO.save_ply(mesh_file, PlyIO.Ply(mesh))
    return texture_file, mesh_file
end

function plottable_mesh_files(mesh::GeometryBasics.Mesh, color::AbstractVector{<: Number}, colormap, colorrange, lowclip, highclip, nan_color, colorscale)
    @assert length(color) == length(GeometryBasics.coordinates(mesh))
    current_uuid = uuid4()
    texture_file = "texture_$current_uuid.exr"
    color_matrix = reshape(Makie.resample_cmap(colormap, 256), (256, 1))
    OpenEXR.save(texture_file, color)

    # set mesh UVs

    uvs = map(color) do c
        if isnan(c) || ismissing(c)
            return Vec2f(1, 1) # missing color will live here
        end
        u = clamp((c - cmin) / cdiff, 0, 1)
        return Vec2f(u, 0)
    end

end