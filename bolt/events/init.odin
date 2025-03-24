package events

import "base:runtime"

event_map: [Event_Types][dynamic]Event_Handler

init :: proc() -> runtime.Allocator_Error {
    for ev in Event_Types {
        event_map[ev]= make([dynamic]Event_Handler) or_return
    }

    return nil
}

deinit :: proc() -> runtime.Allocator_Error {
    for ev in Event_Types {
        delete(event_map[ev]) or_return
    }

    return nil
}
