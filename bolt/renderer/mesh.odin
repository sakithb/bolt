package renderer

import "core:math/linalg"
import "core:mem"

import vk "vendored:vulkan"

Vertex :: struct {
    pos: [3]f32,
    col: [3]f32
}

Push_Consts :: struct {
	model: matrix[4, 4]f32,
}

Mesh :: struct {
    vert_buf: Buffer,
    idx_buf: Buffer,
    idx_count: u32,
}

meshes: [dynamic]^Mesh

mesh_create :: proc(vertices: []Vertex, indices: []u32) -> (mesh: ^Mesh, err: Renderer_Err) {
    if meshes == nil {
        meshes = make([dynamic]^Mesh) or_return //TODO: proper pooling
    }

    mesh = new(Mesh) or_return
    _ = append(&meshes, mesh) or_return

    mesh.vert_buf = upload_buffer(
        raw_data(vertices),
        len(vertices) * size_of(Vertex),
        {.VERTEX_BUFFER}
    ) or_return

    mesh.idx_buf = upload_buffer(
        raw_data(indices),
        len(indices) * size_of(u32),
        {.INDEX_BUFFER}
    ) or_return

    mesh.idx_count = u32(len(indices))

    return
}

mesh_draw :: proc(mesh: ^Mesh, push_consts: Push_Consts) {
    push_consts := push_consts

    vk.CmdBindPipeline(rndr.cmd_buf, .GRAPHICS, rndr.pipeline.hnd)
    vk.CmdBindVertexBuffers(rndr.cmd_buf, 0, 1, &mesh.vert_buf.hnd, raw_data([]vk.DeviceSize{0}))
    vk.CmdBindIndexBuffer(rndr.cmd_buf, mesh.idx_buf.hnd, 0, .UINT32)
    vk.CmdPushConstants(rndr.cmd_buf, rndr.pipeline.layout, {.VERTEX}, 0, size_of(Push_Consts), &push_consts)
    vk.CmdDrawIndexed(rndr.cmd_buf, mesh.idx_count, 1, 0, 0, 0)
}

// mesh_destroy :: proc(mesh_ref: ^Mesh) {
//     free_buffer(mesh.vbuf)
//     free_buffer(mesh.ibuf)
// }
