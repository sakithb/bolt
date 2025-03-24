package platform

import "core:log"

import wl "vendored:wayland_client"

State :: struct {
    display: ^wl.Display,
    registry: ^wl.Registry,
    compositor: ^wl.Compositor,

    resize: bool,
    ready_to_resize: bool,
    width: i32,
    height: i32,

    quit: bool
}

state: State

registry_listener := wl.Registry_Listener{
    global = proc "c" (data: rawptr, registry: ^wl.Registry, name: u32, interface: cstring, version: u32) {
        switch interface {
        case wl.compositor_interface.name:
            state.compositor = cast(^wl.Compositor)wl.registry_bind(
                registry,
                name,
                &wl.compositor_interface,
                version
            )
        case wl.xdg_wm_base_interface.name:
            win.wm_base = cast(^wl.Xdg_Wm_Base)wl.registry_bind(
                registry,
                name,
                &wl.xdg_wm_base_interface,
                version
            )

            wl.xdg_wm_base_add_listener(win.wm_base, &wm_base_listener, nil)
        case wl.seat_interface.name:
            inp.seat = cast(^wl.Seat)wl.registry_bind(
                registry,
                name,
                &wl.seat_interface,
                version
            )

            wl.seat_add_listener(inp.seat, &seat_listener, nil)
        }
    }
}

init :: proc(width, height: i32) -> bool {
    state.display = wl.display_connect(nil)
    if state.display == nil {
        log.error("could not connect to wayland server")
        return false
    }

    state.registry = wl.display_get_registry(state.display)
    if state.registry == nil {
        log.error("could not get registry from wayland server")
        return false
    }

    wl.registry_add_listener(state.registry, &registry_listener, nil)
    wl.display_roundtrip(state.display)

    if state.compositor == nil {
        log.error("did not get compositor from registry")
        return false
    }

    inp_init() or_return
    win_init(width, height) or_return

    return true
}

deinit :: proc() {
    wl.display_disconnect(state.display)
    inp_deinit()
    win_deinit()
}
