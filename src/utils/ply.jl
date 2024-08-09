# This file encodes utilities to convert back and forth from GeometryBasics meshes to PLY files.

function GeometryBasics.triangle_mesh(ply::PlyIO.Ply)
    # load domain
    v = ply["vertex"]
    e = ply["face"]

    vertex_props = Set(PlyIO.plyname(prop) for prop in v.properties)

    points = Point.(v["x"], v["y"], v["z"])
    faces = [(GeometryBasics.TriangleFace(c .+ 1)) for c in e["vertex_indices"]]

    if in("nx", vertex_props)
        nx = v["nx"]
        ny = v["ny"]
        nz = v["nz"]
        normals = Vec3.(nx, ny, nz)
        points = GeometryBasics.meta(points; normals)
    end

    if in("u", vertex_props) && in("v", vertex_props)
        u = v["u"]
        v = v["v"]
        uv = Vec2.(u, v)
        if in("nx", vertex_props)
            points = GeometryBasics.meta(points.position; uv, normals = points.normals)
        else
            points = GeometryBasics.meta(points; uv)
        end
    end

    return GeometryBasics.Mesh(points, faces)
end

function PlyIO.Ply(mesh::GeometryBasics.Mesh; vertex_attrs = (;))
    vertices = GeometryBasics.coordinates(mesh)
    faces = GeometryBasics.faces(mesh)

    points = GeometryBasics.metafree(vertices)
    if eltype(points) <: Makie.VecTypes{2} # 2d points
        points = Makie.to_ndim.(Point3{Float64}, points, 0.0)
    end

    vertex_vecs = PlyIO.ArrayProperty[PlyIO.ArrayProperty(name, getindex.(points, i)) for (i, name) in enumerate(("x", "y", "z"))]

    if :normals in propertynames(vertices)
        normals = vertices.normals
        push!(vertex_vecs, PlyIO.ArrayProperty("nx", getindex.(normals, 1)))
        push!(vertex_vecs, PlyIO.ArrayProperty("ny", getindex.(normals, 2)))
        push!(vertex_vecs, PlyIO.ArrayProperty("nz", getindex.(normals, 3)))
    end

    if :uv in propertynames(vertices)
        uv = vertices.uv
        push!(vertex_vecs, PlyIO.ArrayProperty("u", getindex.(uv, 1)))
        push!(vertex_vecs, PlyIO.ArrayProperty("v", getindex.(uv, 2)))
    end

    for name, values in pairs(vertex_attrs)
        push!(vertex_vecs, PlyIO.ArrayProperty(string(name), values))
    end

    ply_verts = PlyElement("vertex", vertex_vecs...)

    faceprop = PlyIO.ListProperty("vertex_index", map(faces) do face; GeometryBasics.value.(GeometryBasics.GLTriangleFace(face)); end)

    ply_faces = PlyElement("face", faceprop)

    ply = Ply()
    push!(ply, ply_verts)
    push!(ply, ply_faces)
    return ply
end