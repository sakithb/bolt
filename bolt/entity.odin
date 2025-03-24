package bolt

import "core:math/linalg"

import "bolt:renderer"

Entity :: struct {
    mesh: ^renderer.Mesh,

    position: [3]f32,
    rotation: f32,
}

entities: [dynamic]^Entity

entity_create :: proc(mesh: ^renderer.Mesh) -> (entity: ^Entity, err: Bolt_Err)  {
    if entities == nil {
        entities = make([dynamic]^Entity) or_return // TODO: proper pooling
    }

    entity = new(Entity) or_return
    _ = append(&entities, entity) or_return

    entity.mesh = mesh

    return
}
