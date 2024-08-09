# Line-like things
function draw_plot(screen, scene, primitive::Makie.Lines)
end

function draw_plot(screen, scene, primitive::Makie.LineSegments)
end


# Mesh-like things

function draw_plot(screen, scene, primitive::Makie.Mesh)

    io = screen.io

    mesh = primitive.mesh[]
    color = primitive.color[]
    material = if haskey(primitive.attributes, :material)
        primitive.attributes[:material][]
    else
        nothing# scene.material
    end


    println(io)
    println(io, "AttributeBegin")
    # First, write the transformation matrix.
    print(io, "ConcatTransform ") # completely reset transformation matrix
    print(io, "[ ")
    for element in (Makie.transformationmatrix(primitive)) # TODO: is this correct?
        print(io, element)
        print(io, " ")
    end
    print(io, "]")
    println(io)

    # Then, write the material and texture specifications.

    if isnothing(material)
        println(io, """Material "diffuse" "reflectance" [ "Texture" "constant"] """)
    end
    # Finally, write the mesh as a `.ply` file, and reference it via a `plymesh` shape.

    # Apply a nonlinear transformation to the mesh, if necessary.
    new_mesh = if plot.space[] == :data && !(Makie.is_identity_transform(Makie.transform_func(primitive)))
        points = Makie.apply_transform(Makie.transform_func(primitive), (GeometryBasics.metafree(GeometryBasics.coordinates(mesh))))
        GeometryBasics.mesh(points, GeometryBasics.faces(mesh); uv = get(GeometryBasics.attributes(mesh), :uv, nothing), normaltype = Vec3f)
    else
        mesh
    end

    current_mesh_uuid = uuid4()
    
    PlyIO.save_ply(PlyIO.Ply(transformed_mesh), "mesh_$(current_mesh_uuid).ply") # this is NOT correct syntax
    
    println(io, "Shape plymesh")
    println(io, "\"string filename\" \"mesh_$(current_mesh_uuid).ply\"")
    println(io)


    println(io, "AttributeEnd")

end

function draw_plot(screen, scene, primitive::Makie.MeshScatter)
    @warn "PBRTMakie.jl doesn't support plotting mesh scatters yet.  Please open an issue on GitHub if you need this feature." 

    #=
    Object Instancing
    If a complex object is used repeatedly in a scene, object instancing may be worthwhile; this lets the system store a single instance of the object in memory and just record multiple transformations to place it in the scene. Object instances are created via named objects.

    To create a named object, its definition should be placed within an ObjectBegin/ObjectEnd pair:

    ObjectBegin "name"
    Shape ...
    Shape ...
    ObjectEnd

    When a named object is defined, the current transformation matrix defines the transformation from object space to the instance's coordinate space.

    After a named object has been defined, it can be instantiated with the ObjectInstance directive. The current transformation matrix then defines the world from instance space transformation; thus, the final transformation for a shape in an object instance definition is the composition of the CTM when the instance was defined and the CTM when the instance was instantiated.

    Thus, two instances of an object named "foo" are instantiated in the following:

    ObjectInstance "foo"
    Translate 1 0 0
    ObjectInstance "foo"

    Note that the materials that are active when a shape is specified in an instance definition are used when the instance is used; it is not possibility specify different materials for different uses of the same instance.
    =#



end

function draw_plot(screen, scene, primitive::Makie.Surface)
    @warn "PBRTMakie.jl doesn't support plotting surfaces yet.  Please open an issue on GitHub if you need this feature." 
end

# Medium-like things (volumes)

function draw_plot(screen, scene, primitive::Makie.Volume)
    x, y, z = primitive.x[], primitive.y[], primitive.z[]
    volume = primitive.volume[]
    color = primitive.color[]



end


# Things that need extra processing beyond coordinate, material and attribute handling

function draw_plot(screen, scene, primitive::Makie.Scatter)

    io = screen.io

    positions = if primitive.space[] == :data && !Makie.is_identity_transform(Makie.transform_func(primitive))
        Makie.apply_transform(Makie.transform_func(primitive), primitive.positions[])
    else
        primitive.positions[]
    end

    Makie.@get_attribute primitive (color, markersize, strokecolor, strokewidth, marker, marker_offset, rotation)

    broadcast_foreach(positions, colors, markersize, strokecolor,
    strokewidth, marker, marker_offset, remove_billboard(rotation)) do point, col,
    markersize, strokecolor, strokewidth, m, mo, rotation

        scale = project_scale(scene, markerspace, markersize, size_model)
        offset = project_scale(scene, markerspace, mo, size_model)

        pos = project_position(scene, transfunc, space, point, model)
        isnan(pos) && return

        Cairo.set_source_rgba(ctx, rgbatuple(col)...)

        Cairo.save(ctx)
        # Setting a markersize of 0.0 somehow seems to break Cairos global state?
        # At least it stops drawing any marker afterwards
        # TODO, maybe there's something wrong somewhere else?
        if !(norm(scale) ≈ 0.0)
            if m isa Char
                draw_marker(ctx, m, best_font(m, font), pos, scale, strokecolor, strokewidth, offset, rotation)
            else
                draw_marker(ctx, m, pos, scale, strokecolor, strokewidth, offset, rotation)
            end
        end
        Cairo.restore(ctx)
    end
    println(io, "AttributeBegin")
    println(io, "Shape sphere")
    println(io)
    println(io, "AttributeEnd")
end

function draw_plot(screen, scene, primitive::Makie.Image)
    @warn "PBRTMakie.jl doesn't support plotting images yet.  Please open an issue on GitHub if you need this feature." 
end

function draw_plot(screen, scene, primitive::Makie.Heatmap)
    @warn "PBRTMakie.jl doesn't support plotting heatmaps yet.  Please open an issue on GitHub if you need this feature." 
end

function draw_plot(screen, scene, primitive::Makie.Text)
    @warn "PBRTMakie.jl doesn't support plotting text yet.  Please open an issue on GitHub if you need this feature." 
end
