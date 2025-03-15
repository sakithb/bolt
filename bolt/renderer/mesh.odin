package renderer

import vk "vendored:vulkan"

Mesh :: struct {
    v_buf: Buffer,
    v_count: u32
}

mesh_create :: proc(vertices: []f32, count: u32) -> (mesh: Mesh, err: Renderer_Err) {
    mesh.v_buf = upload_buffer(
        raw_data(vertices),
        len(vertices) * size_of(f32)
    ) or_return

    mesh.v_count = count

    return
}

mesh_draw :: proc(mesh: ^Mesh) {
    vk.CmdBindPipeline(rndr.cmd_buf, .GRAPHICS, rndr.pipeline.hnd)
    vk.CmdBindVertexBuffers(rndr.cmd_buf, 0, 1, &mesh.v_buf.hnd, raw_data([]vk.DeviceSize{0}))
    vk.CmdDraw(rndr.cmd_buf, mesh.v_count, 1, 0, 0)
}

mesh_destroy :: proc(mesh: ^Mesh) {
    free_buffer(mesh.v_buf)
}
