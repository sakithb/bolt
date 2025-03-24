package platform

import "core:mem"
import "core:fmt"
import "core:strings"
import "core:sys/linux"
import "base:runtime"

import "bolt:input"

import wl "vendored:wayland_client"
import xkb "vendored:xkbcommon"
import linux_extra "vendored:linux_extra"

Input :: struct {
    seat: ^wl.Seat,
    keyboard: ^wl.Keyboard,
    pointer: ^wl.Pointer,

    xkb_state: ^xkb.State,
    xkb_context: ^xkb.Context,
    xkb_keymap: ^xkb.Keymap,

    pointer_ev: Pointer_Event
}

Pointer_Events :: enum {
    Enter,
    Leave,
    Motion,
    Button,
    Axis,
}

Pointer_Event_Flags :: bit_set[Pointer_Events]

Pointer_Event :: struct {
    event_flags: Pointer_Event_Flags,
    surface_x, surface_y: wl.Fixed,
    state: wl.Pointer_Button_State,
    button, time, serial: u32,
    axes: [wl.Pointer_Axis]Maybe(wl.Fixed),
}

inp: Input

keyboard_listener := wl.Keyboard_Listener{
    keymap = proc "c" (
        data: rawptr,
        keyboard: ^wl.Keyboard,
        format: wl.Keyboard_Keymap_Format,
        fd: i32,
        size: u32
    ) {
        context = runtime.default_context()

        assert(format == .Xkb_V1, "format should be xkb_v1")

        shm, shm_err := linux.mmap(
            0,
            uint(size),
            {.READ},
            {.PRIVATE},
            cast(linux.Fd)fd,
            0
        )

        assert(shm_err == .NONE, "mmap failed")

        keymap := xkb.keymap_new_from_string(
            inp.xkb_context,
            cstring(shm),
            .XKB_KEYMAP_FORMAT_TEXT_V1,
            .XKB_KEYMAP_COMPILE_NO_FLAGS
        )

        linux.munmap(shm, uint(size))
        linux.close(cast(linux.Fd)fd)

        state := xkb.state_new(keymap)

        xkb.keymap_unref(inp.xkb_keymap)
        xkb.state_unref(inp.xkb_state)

        inp.xkb_keymap = keymap
        inp.xkb_state = state
    },

    enter = proc "c" (
        data: rawptr,
        keyboard: ^wl.Keyboard,
        serial: u32,
        surface: ^wl.Surface,
        keys: ^wl.Array
    ) {
        // @TODO Ignore
        // for i: uint = 0; i < (keys.size / size_of(u32)); i += 1 {
        //     key := (cast([^]u32)keys.data)[i] + 8

        //     size := xkb.state_key_get_utf8(inp.xkb_state, key, nil, 0) + 1
        //     buf := make([]u8, size)
        //     str := cstring(&buf[0])
        //     xkb.state_key_get_utf8(inp.xkb_state, key, cstring(&buf[0]), uint(size))

        //     input.keybr_register(input.Keybr_Event{
        //         key = inp_wl_key_to_inp_key(key),
        //         modifiers = {},
        //         state = .Released,
        //         symbol = string(str)
        //     })
        // }
    },

    key = proc "c" (
        data: rawptr,
        keyboard: ^wl.Keyboard,
        serial: u32,
        time: u32,
        key: u32,
        state: wl.Keyboard_Key_State
    ) {
        context = runtime.default_context()

        mods: input.Keybr_Modifier_Flags

        if xkb.state_mod_name_is_active(
            inp.xkb_state,
            xkb.XKB_MOD_NAME_SHIFT,
            xkb.State_Component.MODS_EFFECTIVE
        ) == 1 {
            mods |= {.Shift}
        }

        if xkb.state_mod_name_is_active(
            inp.xkb_state,
            xkb.XKB_MOD_NAME_CTRL,
            xkb.State_Component.MODS_EFFECTIVE
        ) == 1 {
            mods |= {.Ctrl}
        }

        if xkb.state_mod_name_is_active(
            inp.xkb_state,
            xkb.XKB_MOD_NAME_ALT,
            xkb.State_Component.MODS_EFFECTIVE
        ) == 1 {
            mods |= {.Alt}
        }

        if xkb.state_mod_name_is_active(
            inp.xkb_state,
            xkb.XKB_MOD_NAME_CAPS,
            xkb.State_Component.MODS_EFFECTIVE
        ) == 1 {
            mods |= {.Capslock}
        }

        input.keybr_register(
            inp_wl_key_to_inp_key(key),
            mods,
            .Released if state == .Released else .Pressed,
        )
    },

    leave = proc "c" (
        data: rawptr,
        keyboard: ^wl.Keyboard,
        serial: u32,
        surface: ^wl.Surface
    ) {

    },

    modifiers = proc "c" (
        data: rawptr,
        keyboard: ^wl.Keyboard,
        serial: u32,
        mods_depressed: u32,
        mods_latched: u32,
        mods_locked: u32,
        group: u32
    ) {
        xkb.state_update_mask(inp.xkb_state, mods_depressed, mods_latched, mods_locked, 0, 0, group)
    },

    repeat_info = proc "c" (
        data: rawptr,
        keyboard: ^wl.Keyboard,
        rate: i32,
        delay: i32
    ) {

    }
}

pointer_listener := wl.Pointer_Listener{
    enter = proc "c" (
        data: rawptr,
        pointer: ^wl.Pointer,
        serial: u32,
        surface: ^wl.Surface,
        surface_x: wl.Fixed,
        surface_y: wl.Fixed
    ) {
        inp.pointer_ev.event_flags |= {.Enter}
        inp.pointer_ev.serial = serial
        inp.pointer_ev.surface_x = surface_x
        inp.pointer_ev.surface_y = surface_y
    },

    leave = proc "c" (
        data: rawptr,
        pointer: ^wl.Pointer,
        serial: u32,
        surface: ^wl.Surface,
    ) {
        inp.pointer_ev.event_flags |= {.Leave}
        inp.pointer_ev.serial = serial
    },

    motion = proc "c" (
        data: rawptr,
        pointer: ^wl.Pointer,
        time: u32,
        surface_x: wl.Fixed,
        surface_y: wl.Fixed
    ) {
        inp.pointer_ev.event_flags |= {.Motion}
        inp.pointer_ev.time = time
        inp.pointer_ev.surface_x = surface_x
        inp.pointer_ev.surface_y = surface_y
    },

    button = proc "c" (
        data: rawptr,
        pointer: ^wl.Pointer,
        serial: u32,
        time: u32,
        button: u32,
        state: wl.Pointer_Button_State
    ) {
        inp.pointer_ev.event_flags |= {.Button}
        inp.pointer_ev.serial = serial
        inp.pointer_ev.time = time
        inp.pointer_ev.button = button
        inp.pointer_ev.state = state
    },

    axis = proc "c" (
        data: rawptr,
        pointer: ^wl.Pointer,
        time: u32,
        axis: wl.Pointer_Axis,
        value: wl.Fixed
    ) {
        inp.pointer_ev.event_flags |= {.Axis}
        inp.pointer_ev.time = time
        inp.pointer_ev.axes[axis] = value
    },

    axis_discrete = proc "c" (
        data: rawptr,
        pointer: ^wl.Pointer,
        axis: wl.Pointer_Axis,
        discrete: i32
    ) {
    },

    axis_stop = proc "c" (
        data: rawptr,
        pointer: ^wl.Pointer,
        time: u32,
        axis: wl.Pointer_Axis,
    ) {
    },

    axis_source = proc "c" (
        data: rawptr,
        pointer: ^wl.Pointer,
        axis_source: wl.Pointer_Axis_Source,
    ) {
    },

    axis_value120 = proc "c" (
        data: rawptr,
        pointer: ^wl.Pointer,
        axis: wl.Pointer_Axis,
        value120: i32
    ) {
    },

    axis_relative_direction = proc "c" (
        data: rawptr,
        pointer: ^wl.Pointer,
        axis: wl.Pointer_Axis,
        direction: wl.Pointer_Axis_Relative_Direction
    ) {
    },

    frame = proc "c" (
        data: rawptr,
        pointer: ^wl.Pointer,
    ) {
        context = runtime.default_context()

        for event in inp.pointer_ev.event_flags {
            switch event {
            case .Enter:
                input.mouse_register(
                    .Enter,
                    x = wl.fixed_to_int(inp.pointer_ev.surface_x),
                    y = wl.fixed_to_int(inp.pointer_ev.surface_y),
                )
            case .Leave:
                input.mouse_register(
                    .Leave
                )
            case .Motion:
                input.mouse_register(
                    .Move,
                    x = wl.fixed_to_int(inp.pointer_ev.surface_x),
                    y = wl.fixed_to_int(inp.pointer_ev.surface_y),
                )
            case .Button:
                btn: input.Mouse_Event_Button
                if inp.pointer_ev.button == linux_extra.BTN_LEFT {
                    btn = .Left
                } else if inp.pointer_ev.button == linux_extra.BTN_RIGHT {
                    btn = .Right
                } else if inp.pointer_ev.button == linux_extra.BTN_MIDDLE {
                    btn = .Middle
                } else {
                    btn = .Unknown
                }

                state: input.Mouse_Event_Button_State
                if inp.pointer_ev.state == .Pressed {
                    state = .Pressed
                } else {
                    state = .Released
                }

                input.mouse_register(
                    .Button,
                    btn = btn,
                    state = state
                )
            case .Axis:
                if y, ok := inp.pointer_ev.axes[.Vertical_Scroll].?; ok {
                    input.mouse_register(
                        .Scroll,
                        y = wl.fixed_to_int(y),
                    )
                } else if x, ok := inp.pointer_ev.axes[.Horizontal_Scroll].?; ok {
                    input.mouse_register(
                        .Scroll,
                        x = wl.fixed_to_int(x),
                    )
                }
            }
        }

        mem.zero_item(&inp.pointer_ev)
    }
}

seat_listener := wl.Seat_Listener{
    name = proc "c" (data: rawptr, seat: ^wl.Seat, name: cstring) {
        // @TODO
    },

    capabilities = proc "c" (data: rawptr, seat: ^wl.Seat, capabilities: wl.Seat_Capability_Flags) {
        if .Pointer in capabilities && inp.pointer == nil {
            inp.pointer = wl.seat_get_pointer(seat)
            wl.pointer_add_listener(inp.pointer, &pointer_listener, nil)
        } else if .Pointer not_in capabilities && inp.pointer != nil {
            wl.pointer_release(inp.pointer)
            inp.pointer = nil
        }

        if .Keyboard in capabilities && inp.keyboard == nil {
            inp.keyboard = wl.seat_get_keyboard(inp.seat)
            wl.keyboard_add_listener(inp.keyboard, &keyboard_listener, nil)
        } else if .Keyboard not_in capabilities && inp.keyboard != nil {
            wl.keyboard_release(inp.keyboard)
            inp.keyboard = nil
        }
    }
}

inp_init :: proc() -> bool {
    inp.xkb_context = xkb.context_new(.NO_FLAGS)
    if inp.xkb_context == nil do return false

    return true
}

inp_deinit :: proc() {
    xkb.keymap_unref(inp.xkb_keymap)
    xkb.state_unref(inp.xkb_state)
    xkb.context_unref(inp.xkb_context)
}

inp_wl_key_to_inp_key :: proc(wl_key: u32) -> input.Keybr_Key {
    switch wl_key {
    case linux_extra.KEY_ESC: return .Escape
    case linux_extra.KEY_F1: return .F1
    case linux_extra.KEY_F2: return .F2
    case linux_extra.KEY_F3: return .F3
    case linux_extra.KEY_F4: return .F4
    case linux_extra.KEY_F5: return .F5
    case linux_extra.KEY_F6: return .F6
    case linux_extra.KEY_F7: return .F7
    case linux_extra.KEY_F8: return .F8
    case linux_extra.KEY_F9: return .F9
    case linux_extra.KEY_F10: return .F10
    case linux_extra.KEY_F11: return .F11
    case linux_extra.KEY_F12: return .F12
    case linux_extra.KEY_PRINT: return .Print_Screen
    case linux_extra.KEY_DELETE: return .Delete
    case linux_extra.KEY_HOME: return .Home
    case linux_extra.KEY_END: return .End
    case linux_extra.KEY_PAGEUP: return .Page_Up
    case linux_extra.KEY_PAGEDOWN: return .Page_Down
    case linux_extra.KEY_GRAVE: return .Grave
    case linux_extra.KEY_1: return ._1
    case linux_extra.KEY_2: return ._2
    case linux_extra.KEY_3: return ._3
    case linux_extra.KEY_4: return ._4
    case linux_extra.KEY_5: return ._5
    case linux_extra.KEY_6: return ._6
    case linux_extra.KEY_7: return ._7
    case linux_extra.KEY_8: return ._8
    case linux_extra.KEY_9: return ._9
    case linux_extra.KEY_0: return ._0
    case linux_extra.KEY_MINUS: return .Minus
    case linux_extra.KEY_EQUAL: return .Equal
    case linux_extra.KEY_BACKSPACE: return .Backspace
    case linux_extra.KEY_NUMLOCK: return .Numpad_Lock
    case linux_extra.KEY_KPSLASH: return .Numpad_Slash
    case linux_extra.KEY_KPASTERISK: return .Numpad_Asterisk
    case linux_extra.KEY_KPMINUS: return .Numpad_Minus
    case linux_extra.KEY_TAB: return .Tab
    case linux_extra.KEY_Q: return .Q
    case linux_extra.KEY_W: return .W
    case linux_extra.KEY_E: return .E
    case linux_extra.KEY_R: return .R
    case linux_extra.KEY_T: return .T
    case linux_extra.KEY_Y: return .Y
    case linux_extra.KEY_U: return .U
    case linux_extra.KEY_I: return .I
    case linux_extra.KEY_O: return .O
    case linux_extra.KEY_P: return .P
    case linux_extra.KEY_LEFTBRACE: return .Bracket_Left
    case linux_extra.KEY_RIGHTBRACE: return .Bracket_Right
    case linux_extra.KEY_BACKSLASH: return .Backslash
    case linux_extra.KEY_KP7: return .Numpad_7
    case linux_extra.KEY_KP8: return .Numpad_8
    case linux_extra.KEY_KP9: return .Numpad_9
    case linux_extra.KEY_KPPLUS: return .Numpad_Plus
    case linux_extra.KEY_CAPSLOCK: return .Capslock
    case linux_extra.KEY_A: return .A
    case linux_extra.KEY_S: return .S
    case linux_extra.KEY_D: return .D
    case linux_extra.KEY_F: return .F
    case linux_extra.KEY_G: return .G
    case linux_extra.KEY_H: return .H
    case linux_extra.KEY_J: return .J
    case linux_extra.KEY_K: return .K
    case linux_extra.KEY_L: return .L
    case linux_extra.KEY_SEMICOLON: return .Semicolon
    case linux_extra.KEY_APOSTROPHE: return .Apostrophe
    case linux_extra.KEY_ENTER: return .Enter
    case linux_extra.KEY_KP4: return .Numpad_4
    case linux_extra.KEY_KP5: return .Numpad_5
    case linux_extra.KEY_KP6: return .Numpad_6
    case linux_extra.KEY_LEFTSHIFT: return .Left_Shift
    case linux_extra.KEY_Z: return .Z
    case linux_extra.KEY_X: return .X
    case linux_extra.KEY_C: return .C
    case linux_extra.KEY_V: return .V
    case linux_extra.KEY_B: return .B
    case linux_extra.KEY_N: return .N
    case linux_extra.KEY_M: return .M
    case linux_extra.KEY_COMMA: return .Comma
    case linux_extra.KEY_DOT: return .Period
    case linux_extra.KEY_SLASH: return .Slash
    case linux_extra.KEY_RIGHTSHIFT: return .Right_Shift
    case linux_extra.KEY_KP1: return .Numpad_1
    case linux_extra.KEY_KP2: return .Numpad_2
    case linux_extra.KEY_KP3: return .Numpad_3
    case linux_extra.KEY_KPENTER: return .Numpad_Enter
    case linux_extra.KEY_LEFTCTRL: return .Left_Ctrl
    case linux_extra.KEY_LEFTALT: return .Left_Alt
    case linux_extra.KEY_SPACE: return .Space
    case linux_extra.KEY_RIGHTALT: return .Right_Alt
    case linux_extra.KEY_RIGHTCTRL: return .Right_Ctrl
    case linux_extra.KEY_LEFT: return .Left_Arrow
    case linux_extra.KEY_UP: return .Up_Arrow
    case linux_extra.KEY_DOWN: return .Down_Arrow
    case linux_extra.KEY_RIGHT: return .Right_Arrow
    case linux_extra.KEY_KP0: return .Numpad_0
    case linux_extra.KEY_KPDOT: return .Numpad_Period
    case: return .Unknown
    }
}
