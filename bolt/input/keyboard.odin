package input

import "core:fmt"

import "bolt:events"

Keybr_Key :: enum {
    Unknown,
    Escape,
    F1,
    F2,
    F3,
    F4,
    F5,
    F6,
    F7,
    F8,
    F9,
    F10,
    F11,
    F12,
    Print_Screen,
    Delete,
    Home,
    End,
    Page_Up,
    Page_Down,
    Grave,
    _1,
    _2,
    _3,
    _4,
    _5,
    _6,
    _7,
    _8,
    _9,
    _0,
    Minus,
    Equal,
    Backspace,
    Numpad_Lock,
    Numpad_Slash,
    Numpad_Asterisk,
    Numpad_Minus,
    Tab,
    Q,
    W,
    E,
    R,
    T,
    Y,
    U,
    I,
    O,
    P,
    Bracket_Left,
    Bracket_Right,
    Backslash,
    Numpad_7,
    Numpad_8,
    Numpad_9,
    Numpad_Plus,
    Capslock,
    A,
    S,
    D,
    F,
    G,
    H,
    J,
    K,
    L,
    Semicolon,
    Apostrophe,
    Enter,
    Numpad_4,
    Numpad_5,
    Numpad_6,
    Left_Shift,
    Z,
    X,
    C,
    V,
    B,
    N,
    M,
    Comma,
    Period,
    Slash,
    Right_Shift,
    Numpad_1,
    Numpad_2,
    Numpad_3,
    Numpad_Enter,
    Left_Ctrl,
    Left_Alt,
    Space,
    Right_Alt,
    Right_Ctrl,
    Left_Arrow,
    Up_Arrow,
    Down_Arrow,
    Right_Arrow,
    Numpad_0,
    Numpad_Period,
}

Keybr_Key_State :: enum {
    Pressed,
    Released
}

Keybr_Modifier :: enum {
    Shift,
    Ctrl,
    Alt,
    Capslock,
}

Keybr_Modifier_Flags :: bit_set[Keybr_Modifier]

Keybr_Input_Event_Data :: struct {
    key: Keybr_Key,
    mods: Keybr_Modifier_Flags
}

keybr_register :: proc(key: Keybr_Key, mods: Keybr_Modifier_Flags, state: Keybr_Key_State) {
    switch state {
    case .Pressed:
    events.emit(
        .INP_KEYBR_KEY_PRESS,
        Keybr_Input_Event_Data,
        Keybr_Input_Event_Data{
            key = key,
            mods = mods
        }
    )
    case .Released:
    events.emit(
        .INP_KEYBR_KEY_RELEASE,
        Keybr_Input_Event_Data,
        Keybr_Input_Event_Data{
            key = key,
            mods = mods
        }
    )
    }
}
