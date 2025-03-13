package platform

import "core:log"

import wl "vendored:wayland_client"
import vk "vendored:vulkan"

Wsi_Wl :: struct {
    display: ^wl.Display,
    registry: ^wl.Registry,
    compositor: ^wl.Compositor,

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

wsi: Wsi_Wl

toplevel_listener := wl.Xdg_Toplevel_Listener{
    configure = proc(data: rawptr, toplevel: ^wl.Xdg_Toplevel, width: i32, height: i32, states: ^wl.Array) {
        if width != 0 && height != 0 {
            wsi.resize = true
            wsi.width = width
            wsi.height = height
        }
    },

    close = proc(data: rawptr, toplevel: ^wl.Xdg_Toplevel) {
        wsi.quit = true
    }
}

shell_surface_listener := wl.Xdg_Surface_Listener{
    configure = proc(data: rawptr, shell_surface: ^wl.Xdg_Surface, serial: u32) {
        wl.xdg_surface_ack_configure(wsi.shell_surface, serial)
        wsi.ready_to_resize = wsi.resize
    }
}

wm_base_listener := wl.Xdg_Wm_Base_Listener{
    ping = proc(data: rawptr, xdg_wm_base: ^wl.Xdg_Wm_Base, serial: u32) {
        wl.xdg_wm_base_pong(xdg_wm_base, serial)
    }
}

registry_listener := wl.Registry_Listener{
    global = proc(data: rawptr, registry: ^wl.Registry, name: u32, interface: cstring, version: u32) {
        switch interface {
        case wl.compositor_interface.name:
            wsi.compositor = cast(^wl.Compositor)wl.registry_bind(
                registry,
                name,
                &wl.compositor_interface,
                version
            )
        case wl.xdg_wm_base_interface.name:
            wsi.wm_base = cast(^wl.Xdg_Wm_Base)wl.registry_bind(
                registry,
                name,
                &wl.xdg_wm_base_interface,
                version
            )

            wl.xdg_wm_base_add_listener(wsi.wm_base, &wm_base_listener, nil)
        }
    }
}
wsi_init :: proc(width, height: i32) -> bool {
    wsi.display = wl.display_connect(nil)
    if wsi.display == nil {
        log.error("could not connect to wayland server")
        return false
    }

    wsi.registry = wl.display_get_registry(wsi.display)
    if wsi.registry == nil {
        log.error("could not get registry from wayland server")
        return false
    }

    wl.registry_add_listener(wsi.registry, &registry_listener, nil)
    wl.display_roundtrip(wsi.display)

    if wsi.compositor == nil {
        log.error("did not get compositor from registry")
        return false
    }

    wsi.surface = wl.compositor_create_surface(wsi.compositor)
    if wsi.surface == nil {
        log.error("could not create surface")
        return false
    }

    wsi.shell_surface = wl.xdg_wm_base_get_xdg_surface(wsi.wm_base, wsi.surface)
    if wsi.shell_surface == nil {
        log.error("could not create shell surface")
        return false
    }

    wl.xdg_surface_add_listener(wsi.shell_surface, &shell_surface_listener, nil)

    wsi.toplevel = wl.xdg_surface_get_toplevel(wsi.shell_surface)
    if wsi.toplevel == nil {
        log.error("could not create toplevel surface")
        return false
    }

    wl.xdg_toplevel_add_listener(wsi.toplevel, &toplevel_listener, nil)

    wl.xdg_toplevel_set_title(wsi.toplevel, "TODO") // TODO
    wl.xdg_toplevel_set_app_id(wsi.toplevel, "TODO") // TODO
    wl.xdg_toplevel_set_min_size(wsi.toplevel, width, height)

    wsi.width = width
    wsi.height = height

    wl.surface_commit(wsi.surface)
    wl.display_roundtrip(wsi.display)
    wl.surface_commit(wsi.surface)

    return true
}

wsi_create_surface :: proc(instance: vk.Instance) -> (vk.SurfaceKHR, vk.Result) {
    create_info := vk.WaylandSurfaceCreateInfoKHR{
        sType = .WAYLAND_SURFACE_CREATE_INFO_KHR,
        display = cast(^vk.wl_display)wsi.display,
        surface = cast(^vk.wl_surface)wsi.surface
    }

    surface: vk.SurfaceKHR
    result := vk.CreateWaylandSurfaceKHR(instance, &create_info, nil, &surface)

    return surface, result
}

wsi_poll_events :: proc() {
    if wsi.resize && wsi.ready_to_resize {
    }

    wl.display_roundtrip(wsi.display)
}

wsi_should_close :: proc() -> bool {
    return wsi.quit
}

wsi_get_dimensions :: proc() -> (i32, i32) {
    return wsi.width, wsi.height
}

wsi_deinit :: proc() {
    wl.xdg_toplevel_destroy(wsi.toplevel)
    wl.xdg_surface_destroy(wsi.shell_surface)
    wl.surface_destroy(wsi.surface)
    wl.xdg_wm_base_destroy(wsi.wm_base)
    wl.display_disconnect(wsi.display)
}
