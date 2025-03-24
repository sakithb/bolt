package events

Event_Types :: enum {
    INP_MOUSE_ENTER,
    INP_MOUSE_LEAVE,
    INP_MOUSE_MOVE,
    INP_MOUSE_PRESS,
    INP_MOUSE_RELEASE,
    INP_MOUSE_CLICK,
    INP_MOUSE_SCROLL,

    INP_KEYBR_KEY_PRESS,
    INP_KEYBR_KEY_RELEASE,
}

Event_Handler_Data :: proc(type: Event_Types, $T: typeid, data: T) -> bool
Event_Handler_No_Data :: proc(type: Event_Types) -> bool
Event_Handler :: union { Event_Handler_Data, Event_Handler_No_Data }

listen :: proc(type: Event_Types, cb: Event_Handler) {
    append(&event_map[type], cb)
}

emit_data :: proc(type: Event_Types, $T: typeid, data: T) {
    for cb in event_map[type] {
        if cb.(Event_Handler_Data)(type, T, data) {
            break
        }
    }
}

emit_no_data :: proc(type: Event_Types) {
    for cb in event_map[type] {
        if cb.(Event_Handler_No_Data)(type) {
            break
        }
    }
}

emit :: proc{emit_data, emit_no_data}
