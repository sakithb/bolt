package input

import "core:fmt"

import "bolt:events"

Mouse_Event_Button :: enum {
    Unknown,
    Left,
    Right,
    Middle
}

Mouse_Event_Button_State :: enum {
    Released,
    Pressed
}

Mouse_Event_Type :: enum {
    Enter,
    Leave,
    Move,
    Button,
    Scroll
}

Mouse_State :: struct {
    x: i32,
    y: i32,
    state: Mouse_Event_Button_State
}

mouse_state: Mouse_State

Mouse_Input_Event_Data_Vec2 :: struct {
    x: i32,
    y: i32
}

Mouse_Input_Event_Data_Vec2_Btn :: struct {
    using pos: Mouse_Input_Event_Data_Vec2,
    btn: Mouse_Event_Button
}

mouse_register :: proc(
    ev: Mouse_Event_Type,
    x: Maybe(i32) = nil,
    y: Maybe(i32) = nil,
    btn: Maybe(Mouse_Event_Button) = nil,
    state: Maybe(Mouse_Event_Button_State) = nil,
) {
    switch ev {
    case .Enter:
        events.emit(.INP_MOUSE_ENTER)
    case .Leave:
        events.emit(.INP_MOUSE_LEAVE)
    case .Move:
        events.emit(
            .INP_MOUSE_MOVE,
            Mouse_Input_Event_Data_Vec2,
            Mouse_Input_Event_Data_Vec2{
                x = x.? - mouse_state.x,
                y = y.? - mouse_state.y
            }
        )
        mouse_state.x = x.?
        mouse_state.y = y.?
    case .Button:
        if state == .Pressed {
            events.emit(
                .INP_MOUSE_PRESS,
                Mouse_Input_Event_Data_Vec2_Btn,
                Mouse_Input_Event_Data_Vec2_Btn{
                    x = mouse_state.x,
                    y = mouse_state.y,
                    btn = btn.?
                }
            )
        } else if state == .Released {
            events.emit(
                .INP_MOUSE_RELEASE,
                Mouse_Input_Event_Data_Vec2_Btn,
                Mouse_Input_Event_Data_Vec2_Btn{
                    x = mouse_state.x,
                    y = mouse_state.y,
                    btn = btn.?
                }
            )

            if mouse_state.state == .Pressed {
                events.emit(
                    .INP_MOUSE_CLICK,
                    Mouse_Input_Event_Data_Vec2_Btn,
                    Mouse_Input_Event_Data_Vec2_Btn{
                        x = mouse_state.x,
                        y = mouse_state.y,
                        btn = btn.?
                    }
                )
            }
        }

        mouse_state.state = state.?
    case .Scroll:
        events.emit(
            .INP_MOUSE_SCROLL,
            Mouse_Input_Event_Data_Vec2,
            Mouse_Input_Event_Data_Vec2{
                x = x.? or_else 0.0,
                y = y.? or_else 0.0,
            }
        )
    }
}
