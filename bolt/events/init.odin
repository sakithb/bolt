package events

import "base:runtime"

event_map: [Events][dynamic]Event_Listener

init :: proc() -> runtime.Allocator_Error {
    for ev in Events {
        event_map[ev]= make([dynamic]Event_Listener) or_return
    }

    return nil
}

deinit :: proc() -> runtime.Allocator_Error {
    for ev in Events {
        delete(event_map[ev]) or_return
    }

    return nil
}
