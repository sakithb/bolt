package events

Events :: enum {
    Wsi_Resize
}

Event_Listener :: proc(ev: Events) -> any

add_listener :: proc(ev: Events, cb: Event_Listener) {
    append(&event_map[ev], cb)
}
