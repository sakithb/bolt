package platform

import "core:log"

import wl "vendored:wayland_client"
import vk "vendored:vulkan"

Window :: struct {
    wm_base: ^wl.Xdg_Wm_Base,
    surface: ^wl.Surface,
    shell_surface: ^wl.Xdg_Surface,
    toplevel: ^wl.Xdg_Toplevel,

    resize: bool,
    ready_to_resize: bool,
    width: i32,
    height: i32,

    quit: bool
}

win: Window

toplevel_listener := wl.Xdg_Toplevel_Listener{
    configure = proc "c" (data: rawptr, toplevel: ^wl.Xdg_Toplevel, width: i32, height: i32, states: ^wl.Array) {
        if width != 0 && height != 0 {
            win.resize = true
            win.width = width
            win.height = height
        }
    },

    close = proc "c" (data: rawptr, toplevel: ^wl.Xdg_Toplevel) {
        win.quit = true
    }
}

shell_surface_listener := wl.Xdg_Surface_Listener{
    configure = proc "c" (data: rawptr, shell_surface: ^wl.Xdg_Surface, serial: u32) {
        wl.xdg_surface_ack_configure(win.shell_surface, serial)
        win.ready_to_resize = win.resize
    }
}

wm_base_listener := wl.Xdg_Wm_Base_Listener{
    ping = proc "c" (data: rawptr, xdg_wm_base: ^wl.Xdg_Wm_Base, serial: u32) {
        wl.xdg_wm_base_pong(xdg_wm_base, serial)
    }
}

win_init :: proc(width, height: i32) -> bool {
    win.surface = wl.compositor_create_surface(state.compositor)
    if win.surface == nil {
        log.error("could not create surface")
        return false
    }

    win.shell_surface = wl.xdg_wm_base_get_xdg_surface(win.wm_base, win.surface)
    if win.shell_surface == nil {
        log.error("could not create shell surface")
        return false
    }

    wl.xdg_surface_add_listener(win.shell_surface, &shell_surface_listener, nil)

    win.toplevel = wl.xdg_surface_get_toplevel(win.shell_surface)
    if win.toplevel == nil {
        log.error("could not create toplevel surface")
        return false
    }

    wl.xdg_toplevel_add_listener(win.toplevel, &toplevel_listener, nil)

    wl.xdg_toplevel_set_title(win.toplevel, "TODO") // TODO
    wl.xdg_toplevel_set_app_id(win.toplevel, "TODO") // TODO
    wl.xdg_toplevel_set_min_size(win.toplevel, width, height)

    win.width = width
    win.height = height

    wl.surface_commit(win.surface)
    wl.display_roundtrip(state.display)
    wl.surface_commit(win.surface)

    return true
}

win_create_surface :: proc(instance: vk.Instance) -> (vk.SurfaceKHR, vk.Result) {
    create_info := vk.WaylandSurfaceCreateInfoKHR{
        sType = .WAYLAND_SURFACE_CREATE_INFO_KHR,
        display = cast(^vk.wl_display)state.display,
        surface = cast(^vk.wl_surface)win.surface
    }

    surface: vk.SurfaceKHR
    result := vk.CreateWaylandSurfaceKHR(instance, &create_info, nil, &surface)

    return surface, result
}

win_poll_events :: proc() {
    if win.resize && win.ready_to_resize {
    }

    wl.display_roundtrip(state.display)
}

win_should_close :: proc() -> bool {
    return win.quit
}

win_get_dimensions :: proc() -> (i32, i32) {
    return win.width, win.height
}

win_deinit :: proc() {
    wl.xdg_toplevel_destroy(win.toplevel)
    wl.xdg_surface_destroy(win.shell_surface)
    wl.surface_destroy(win.surface)
    wl.xdg_wm_base_destroy(win.wm_base)
}
