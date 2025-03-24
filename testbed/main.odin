package testbed

import "core:fmt"
import "core:log"
import "core:time"
import "core:math/linalg"

import "bolt:."
import "bolt:renderer"
import "bolt:events"

tmp_vertex_data := []renderer.Vertex{
    // v0: back-bottom-left
    {{-0.5, -0.5, -0.5}, {1.0, 0.0, 0.0}},
    // v1: back-bottom-right
    {{ 0.5, -0.5, -0.5}, {1.0, 1.0, 0.0}},
    // v2: back-top-right
    {{ 0.5,  0.5, -0.5}, {0.0, 1.0, 1.0}},
    // v3: back-top-left
    {{-0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}},
    // v4: front-bottom-left
    {{-0.5, -0.5,  0.5}, {1.0, 0.0, 0.0}},
    // v5: front-bottom-right
    {{ 0.5, -0.5,  0.5}, {1.0, 1.0, 0.0}},
    // v6: front-top-right
    {{ 0.5,  0.5,  0.5}, {0.0, 1.0, 1.0}},
    // v7: front-top-left
    {{-0.5,  0.5,  0.5}, {0.0, 0.0, 1.0}},
}

tmp_index_data := []u32{
    // Front face (z = +0.5), clockwise when viewed from the front
    4, 7, 6,
    4, 6, 5,

    // Back face (z = -0.5), clockwise when viewed from the back
    0, 3, 2,
    0, 2, 1,

    // Right face (x = +0.5), clockwise when viewed from the right
    1, 5, 6,
    1, 6, 2,

    // Left face (x = -0.5), clockwise when viewed from the left
    0, 4, 7,
    0, 7, 3,

    // Top face (y = +0.5), clockwise when viewed from above
    3, 7, 6,
    3, 6, 2,

    // Bottom face (y = -0.5), clockwise when viewed from below
    0, 4, 5,
    0, 5, 1,
}

cube1: ^bolt.Entity
cube2: ^bolt.Entity

init :: proc() {
    cube_mesh := renderer.mesh_create(tmp_vertex_data[:], tmp_index_data[:]) or_else log.panic("Could not create mesh")

    cube1 = bolt.entity_create(cube_mesh) or_else log.panic("Could not create entity")
    cube1.position.x = 2.0

    cube2 = bolt.entity_create(cube_mesh) or_else log.panic("Could not create entity")
    cube2.position.x = -2.0

    events.listen(.INP_MOUSE_ENTER, proc(ev: events.Event) -> bool {
        fmt.println("entered")
        return false
    })

    events.listen(.INP_MOUSE_LEAVE, proc(ev: events.Event) -> bool {
        fmt.println("left")
        return false
    })

    events.listen(.INP_MOUSE_MOVE, proc(ev: events.Event) -> bool {
        fmt.printfln("move: %v", ev.data)
        return false
    })

    events.listen(.INP_MOUSE_PRESS, proc(ev: events.Event) -> bool {
        fmt.printfln("press: %v", ev.data)
        return false
    })

    events.listen(.INP_MOUSE_RELEASE, proc(ev: events.Event) -> bool {
        fmt.printfln("release: %v", ev.data)
        return false
    })

    events.listen(.INP_MOUSE_CLICK, proc(ev: events.Event) -> bool {
        fmt.printfln("click: %v", ev.data)
        return false
    })

    events.listen(.INP_MOUSE_SCROLL, proc(ev: events.Event) -> bool {
        fmt.printfln("scroll: %v", ev.data)
        return false
    })
}

update :: proc(delta_time: f32, elapsed_time: time.Duration) {
    cube1.position.y = linalg.sin(5.0 * (f32(elapsed_time) / f32(time.Second)))
    cube2.position.y = linalg.sin(5.0 * (f32(elapsed_time) / f32(time.Second)))
}

deinit :: proc() {
}

main:: proc() {
    bolt.start(bolt.Game_Api{
        init = init,
        update = update,
        deinit = deinit
    })
}
