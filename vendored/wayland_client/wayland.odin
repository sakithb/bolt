package wayland_client

Display :: struct{}
Registry :: struct{}
Callback :: struct{}
Compositor :: struct{}
Shm_Pool :: struct{}
Shm :: struct{}
Buffer :: struct{}
Data_Offer :: struct{}
Data_Source :: struct{}
Data_Device :: struct{}
Data_Device_Manager :: struct{}
Shell :: struct{}
Shell_Surface :: struct{}
Surface :: struct{}
Seat :: struct{}
Pointer :: struct{}
Keyboard :: struct{}
Touch :: struct{}
Output :: struct{}
Region :: struct{}
Subcompositor :: struct{}
Subsurface :: struct{}
Fixes :: struct{}

display_interfaces := [?]^Interface{
    &callback_interface,
    &registry_interface,
    nil,
    nil,
    nil,
    nil,
}

display_requests := [?]Message{
    { "sync", "n", &display_interfaces[0] },
    { "get_registry", "n", &display_interfaces[1] },
}

display_events := [?]Message{
    { "error", "ous", &display_interfaces[2] },
    { "delete_id", "u", &display_interfaces[5] },
}

/*
 * core global object
 * The core global object.  This is a special singleton object.  It
 * is used for internal Wayland protocol features.
 */
display_interface := Interface{
    "wl_display",
    1,
    0,
    nil,
    0,
    nil,
}

@(init)
display_interface_init :: proc() {
    display_interface.method_count = len(display_requests)
    display_interface.methods = &display_requests[0]
    display_interface.event_count = len(display_events)
    display_interface.events = &display_events[0]
}

registry_interfaces := [?]^Interface{
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}

registry_requests := [?]Message{
    { "bind", "usun", &registry_interfaces[0] },
}

registry_events := [?]Message{
    { "global", "usu", &registry_interfaces[2] },
    { "global_remove", "u", &registry_interfaces[5] },
}

/*
 * global registry object
 * The singleton global registry object.  The server has a number of
 * global objects that are available to all clients.  These objects
 * typically represent an actual object in the server (for example,
 * an input device) or they are singleton objects that provide
 * extension functionality.
 * 
 * When a client creates a registry object, the registry object
 * will emit a global event for each global currently in the
 * registry.  Globals come and go as a result of device or
 * monitor hotplugs, reconfiguration or other events, and the
 * registry will send out global and global_remove events to
 * keep the client up to date with the changes.  To mark the end
 * of the initial burst of events, the client can use the
 * wl_display.sync request immediately after calling
 * wl_display.get_registry.
 * 
 * A client can bind to a global object by using the bind
 * request.  This creates a client-side handle that lets the object
 * emit events to the client and lets the client invoke requests on
 * the object.
 */
registry_interface := Interface{
    "wl_registry",
    1,
    0,
    nil,
    0,
    nil,
}

@(init)
registry_interface_init :: proc() {
    registry_interface.method_count = len(registry_requests)
    registry_interface.methods = &registry_requests[0]
    registry_interface.event_count = len(registry_events)
    registry_interface.events = &registry_events[0]
}

callback_interfaces := [?]^Interface{
    nil,
}


callback_events := [?]Message{
    { "done", "u", &callback_interfaces[0] },
}

/*
 * callback object
 * Clients can handle the 'done' event to get notified when
 * the related request is done.
 * 
 * Note, because wl_callback objects are created from multiple independent
 * factory interfaces, the wl_callback interface is frozen at version 1.
 */
callback_interface := Interface{
    "wl_callback",
    1,
    0,
    nil,
    0,
    nil,
}

@(init)
callback_interface_init :: proc() {
    callback_interface.event_count = len(callback_events)
    callback_interface.events = &callback_events[0]
}

compositor_interfaces := [?]^Interface{
    &surface_interface,
    &region_interface,
}

compositor_requests := [?]Message{
    { "create_surface", "n", &compositor_interfaces[0] },
    { "create_region", "n", &compositor_interfaces[1] },
}


/*
 * the compositor singleton
 * A compositor.  This object is a singleton global.  The
 * compositor is in charge of combining the contents of multiple
 * surfaces into one displayable output.
 */
compositor_interface := Interface{
    "wl_compositor",
    6,
    0,
    nil,
    0,
    nil,
}

@(init)
compositor_interface_init :: proc() {
    compositor_interface.method_count = len(compositor_requests)
    compositor_interface.methods = &compositor_requests[0]
}

shm_pool_interfaces := [?]^Interface{
    &buffer_interface,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}

shm_pool_requests := [?]Message{
    { "create_buffer", "niiiiu", &shm_pool_interfaces[0] },
    { "destroy", "", nil },
    { "resize", "i", &shm_pool_interfaces[6] },
}


/*
 * a shared memory pool
 * The wl_shm_pool object encapsulates a piece of memory shared
 * between the compositor and client.  Through the wl_shm_pool
 * object, the client can allocate shared memory wl_buffer objects.
 * All objects created through the same pool share the same
 * underlying mapped memory. Reusing the mapped memory avoids the
 * setup/teardown overhead and is useful when interactively resizing
 * a surface or for many small buffers.
 */
shm_pool_interface := Interface{
    "wl_shm_pool",
    2,
    0,
    nil,
    0,
    nil,
}

@(init)
shm_pool_interface_init :: proc() {
    shm_pool_interface.method_count = len(shm_pool_requests)
    shm_pool_interface.methods = &shm_pool_requests[0]
}

shm_interfaces := [?]^Interface{
    &shm_pool_interface,
    nil,
    nil,
    nil,
}

shm_requests := [?]Message{
    { "create_pool", "nhi", &shm_interfaces[0] },
    { "release", "", nil },
}

shm_events := [?]Message{
    { "format", "u", &shm_interfaces[3] },
}

/*
 * shared memory support
 * A singleton global object that provides support for shared
 * memory.
 * 
 * Clients can create wl_shm_pool objects using the create_pool
 * request.
 * 
 * On binding the wl_shm object one or more format events
 * are emitted to inform clients about the valid pixel formats
 * that can be used for buffers.
 */
shm_interface := Interface{
    "wl_shm",
    2,
    0,
    nil,
    0,
    nil,
}

@(init)
shm_interface_init :: proc() {
    shm_interface.method_count = len(shm_requests)
    shm_interface.methods = &shm_requests[0]
    shm_interface.event_count = len(shm_events)
    shm_interface.events = &shm_events[0]
}

buffer_interfaces := [?]^Interface{
}

buffer_requests := [?]Message{
    { "destroy", "", nil },
}

buffer_events := [?]Message{
    { "release", "", nil },
}

/*
 * content for a wl_surface
 * A buffer provides the content for a wl_surface. Buffers are
 * created through factory interfaces such as wl_shm, wp_linux_buffer_params
 * (from the linux-dmabuf protocol extension) or similar. It has a width and
 * a height and can be attached to a wl_surface, but the mechanism by which a
 * client provides and updates the contents is defined by the buffer factory
 * interface.
 * 
 * Color channels are assumed to be electrical rather than optical (in other
 * words, encoded with a transfer function) unless otherwise specified. If
 * the buffer uses a format that has an alpha channel, the alpha channel is
 * assumed to be premultiplied into the electrical color channel values
 * (after transfer function encoding) unless otherwise specified.
 * 
 * Note, because wl_buffer objects are created from multiple independent
 * factory interfaces, the wl_buffer interface is frozen at version 1.
 */
buffer_interface := Interface{
    "wl_buffer",
    1,
    0,
    nil,
    0,
    nil,
}

@(init)
buffer_interface_init :: proc() {
    buffer_interface.method_count = len(buffer_requests)
    buffer_interface.methods = &buffer_requests[0]
    buffer_interface.event_count = len(buffer_events)
    buffer_interface.events = &buffer_events[0]
}

data_offer_interfaces := [?]^Interface{
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}

data_offer_requests := [?]Message{
    { "accept", "u?s", &data_offer_interfaces[0] },
    { "receive", "sh", &data_offer_interfaces[2] },
    { "destroy", "", nil },
    { "finish", "", nil },
    { "set_actions", "uu", &data_offer_interfaces[4] },
}

data_offer_events := [?]Message{
    { "offer", "s", &data_offer_interfaces[6] },
    { "source_actions", "u", &data_offer_interfaces[7] },
    { "action", "u", &data_offer_interfaces[8] },
}

/*
 * offer to transfer data
 * A wl_data_offer represents a piece of data offered for transfer
 * by another client (the source client).  It is used by the
 * copy-and-paste and drag-and-drop mechanisms.  The offer
 * describes the different mime types that the data can be
 * converted to and provides the mechanism for transferring the
 * data directly from the source client.
 */
data_offer_interface := Interface{
    "wl_data_offer",
    3,
    0,
    nil,
    0,
    nil,
}

@(init)
data_offer_interface_init :: proc() {
    data_offer_interface.method_count = len(data_offer_requests)
    data_offer_interface.methods = &data_offer_requests[0]
    data_offer_interface.event_count = len(data_offer_events)
    data_offer_interface.events = &data_offer_events[0]
}

data_source_interfaces := [?]^Interface{
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}

data_source_requests := [?]Message{
    { "offer", "s", &data_source_interfaces[0] },
    { "destroy", "", nil },
    { "set_actions", "u", &data_source_interfaces[1] },
}

data_source_events := [?]Message{
    { "target", "?s", &data_source_interfaces[2] },
    { "send", "sh", &data_source_interfaces[3] },
    { "cancelled", "", nil },
    { "dnd_drop_performed", "", nil },
    { "dnd_finished", "", nil },
    { "action", "u", &data_source_interfaces[5] },
}

/*
 * offer to transfer data
 * The wl_data_source object is the source side of a wl_data_offer.
 * It is created by the source client in a data transfer and
 * provides a way to describe the offered data and a way to respond
 * to requests to transfer the data.
 */
data_source_interface := Interface{
    "wl_data_source",
    3,
    0,
    nil,
    0,
    nil,
}

@(init)
data_source_interface_init :: proc() {
    data_source_interface.method_count = len(data_source_requests)
    data_source_interface.methods = &data_source_requests[0]
    data_source_interface.event_count = len(data_source_events)
    data_source_interface.events = &data_source_events[0]
}

data_device_interfaces := [?]^Interface{
    &data_source_interface,
    &surface_interface,
    &surface_interface,
    nil,
    &data_source_interface,
    nil,
    &data_offer_interface,
    nil,
    &surface_interface,
    nil,
    nil,
    &data_offer_interface,
    nil,
    nil,
    nil,
    &data_offer_interface,
}

data_device_requests := [?]Message{
    { "start_drag", "?oo?ou", &data_device_interfaces[0] },
    { "set_selection", "?ou", &data_device_interfaces[4] },
    { "release", "", nil },
}

data_device_events := [?]Message{
    { "data_offer", "n", &data_device_interfaces[6] },
    { "enter", "uoff?o", &data_device_interfaces[7] },
    { "leave", "", nil },
    { "motion", "uff", &data_device_interfaces[12] },
    { "drop", "", nil },
    { "selection", "?o", &data_device_interfaces[15] },
}

/*
 * data transfer device
 * There is one wl_data_device per seat which can be obtained
 * from the global wl_data_device_manager singleton.
 * 
 * A wl_data_device provides access to inter-client data transfer
 * mechanisms such as copy-and-paste and drag-and-drop.
 */
data_device_interface := Interface{
    "wl_data_device",
    3,
    0,
    nil,
    0,
    nil,
}

@(init)
data_device_interface_init :: proc() {
    data_device_interface.method_count = len(data_device_requests)
    data_device_interface.methods = &data_device_requests[0]
    data_device_interface.event_count = len(data_device_events)
    data_device_interface.events = &data_device_events[0]
}

data_device_manager_interfaces := [?]^Interface{
    &data_source_interface,
    &data_device_interface,
    &seat_interface,
}

data_device_manager_requests := [?]Message{
    { "create_data_source", "n", &data_device_manager_interfaces[0] },
    { "get_data_device", "no", &data_device_manager_interfaces[1] },
}


/*
 * data transfer interface
 * The wl_data_device_manager is a singleton global object that
 * provides access to inter-client data transfer mechanisms such as
 * copy-and-paste and drag-and-drop.  These mechanisms are tied to
 * a wl_seat and this interface lets a client get a wl_data_device
 * corresponding to a wl_seat.
 * 
 * Depending on the version bound, the objects created from the bound
 * wl_data_device_manager object will have different requirements for
 * functioning properly. See wl_data_source.set_actions,
 * wl_data_offer.accept and wl_data_offer.finish for details.
 */
data_device_manager_interface := Interface{
    "wl_data_device_manager",
    3,
    0,
    nil,
    0,
    nil,
}

@(init)
data_device_manager_interface_init :: proc() {
    data_device_manager_interface.method_count = len(data_device_manager_requests)
    data_device_manager_interface.methods = &data_device_manager_requests[0]
}

shell_interfaces := [?]^Interface{
    &shell_surface_interface,
    &surface_interface,
}

shell_requests := [?]Message{
    { "get_shell_surface", "no", &shell_interfaces[0] },
}


/*
 * create desktop-style surfaces
 * This interface is implemented by servers that provide
 * desktop-style user interfaces.
 * 
 * It allows clients to associate a wl_shell_surface with
 * a basic surface.
 * 
 * Note! This protocol is deprecated and not intended for production use.
 * For desktop-style user interfaces, use xdg_shell. Compositors and clients
 * should not implement this interface.
 */
shell_interface := Interface{
    "wl_shell",
    1,
    0,
    nil,
    0,
    nil,
}

@(init)
shell_interface_init :: proc() {
    shell_interface.method_count = len(shell_requests)
    shell_interface.methods = &shell_requests[0]
}

shell_surface_interfaces := [?]^Interface{
    nil,
    &seat_interface,
    nil,
    &seat_interface,
    nil,
    nil,
    &surface_interface,
    nil,
    nil,
    nil,
    nil,
    nil,
    &output_interface,
    &seat_interface,
    nil,
    &surface_interface,
    nil,
    nil,
    nil,
    &output_interface,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}

shell_surface_requests := [?]Message{
    { "pong", "u", &shell_surface_interfaces[0] },
    { "move", "ou", &shell_surface_interfaces[1] },
    { "resize", "ouu", &shell_surface_interfaces[3] },
    { "set_toplevel", "", nil },
    { "set_transient", "oiiu", &shell_surface_interfaces[6] },
    { "set_fullscreen", "uu?o", &shell_surface_interfaces[10] },
    { "set_popup", "ouoiiu", &shell_surface_interfaces[13] },
    { "set_maximized", "?o", &shell_surface_interfaces[19] },
    { "set_title", "s", &shell_surface_interfaces[20] },
    { "set_class", "s", &shell_surface_interfaces[21] },
}

shell_surface_events := [?]Message{
    { "ping", "u", &shell_surface_interfaces[22] },
    { "configure", "uii", &shell_surface_interfaces[23] },
    { "popup_done", "", nil },
}

/*
 * desktop-style metadata interface
 * An interface that may be implemented by a wl_surface, for
 * implementations that provide a desktop-style user interface.
 * 
 * It provides requests to treat surfaces like toplevel, fullscreen
 * or popup windows, move, resize or maximize them, associate
 * metadata like title and class, etc.
 * 
 * On the server side the object is automatically destroyed when
 * the related wl_surface is destroyed. On the client side,
 * wl_shell_surface_destroy() must be called before destroying
 * the wl_surface object.
 */
shell_surface_interface := Interface{
    "wl_shell_surface",
    1,
    0,
    nil,
    0,
    nil,
}

@(init)
shell_surface_interface_init :: proc() {
    shell_surface_interface.method_count = len(shell_surface_requests)
    shell_surface_interface.methods = &shell_surface_requests[0]
    shell_surface_interface.event_count = len(shell_surface_events)
    shell_surface_interface.events = &shell_surface_events[0]
}

surface_interfaces := [?]^Interface{
    &buffer_interface,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    &callback_interface,
    &region_interface,
    &region_interface,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    &output_interface,
    &output_interface,
    nil,
    nil,
}

surface_requests := [?]Message{
    { "destroy", "", nil },
    { "attach", "?oii", &surface_interfaces[0] },
    { "damage", "iiii", &surface_interfaces[3] },
    { "frame", "n", &surface_interfaces[7] },
    { "set_opaque_region", "?o", &surface_interfaces[8] },
    { "set_input_region", "?o", &surface_interfaces[9] },
    { "commit", "", nil },
    { "set_buffer_transform", "i", &surface_interfaces[10] },
    { "set_buffer_scale", "i", &surface_interfaces[11] },
    { "damage_buffer", "iiii", &surface_interfaces[12] },
    { "offset", "ii", &surface_interfaces[16] },
}

surface_events := [?]Message{
    { "enter", "o", &surface_interfaces[18] },
    { "leave", "o", &surface_interfaces[19] },
    { "preferred_buffer_scale", "i", &surface_interfaces[20] },
    { "preferred_buffer_transform", "u", &surface_interfaces[21] },
}

/*
 * an onscreen surface
 * A surface is a rectangular area that may be displayed on zero
 * or more outputs, and shown any number of times at the compositor's
 * discretion. They can present wl_buffers, receive user input, and
 * define a local coordinate system.
 * 
 * The size of a surface (and relative positions on it) is described
 * in surface-local coordinates, which may differ from the buffer
 * coordinates of the pixel content, in case a buffer_transform
 * or a buffer_scale is used.
 * 
 * A surface without a "role" is fairly useless: a compositor does
 * not know where, when or how to present it. The role is the
 * purpose of a wl_surface. Examples of roles are a cursor for a
 * pointer (as set by wl_pointer.set_cursor), a drag icon
 * (wl_data_device.start_drag), a sub-surface
 * (wl_subcompositor.get_subsurface), and a window as defined by a
 * shell protocol (e.g. wl_shell.get_shell_surface).
 * 
 * A surface can have only one role at a time. Initially a
 * wl_surface does not have a role. Once a wl_surface is given a
 * role, it is set permanently for the whole lifetime of the
 * wl_surface object. Giving the current role again is allowed,
 * unless explicitly forbidden by the relevant interface
 * specification.
 * 
 * Surface roles are given by requests in other interfaces such as
 * wl_pointer.set_cursor. The request should explicitly mention
 * that this request gives a role to a wl_surface. Often, this
 * request also creates a new protocol object that represents the
 * role and adds additional functionality to wl_surface. When a
 * client wants to destroy a wl_surface, they must destroy this role
 * object before the wl_surface, otherwise a defunct_role_object error is
 * sent.
 * 
 * Destroying the role object does not remove the role from the
 * wl_surface, but it may stop the wl_surface from "playing the role".
 * For instance, if a wl_subsurface object is destroyed, the wl_surface
 * it was created for will be unmapped and forget its position and
 * z-order. It is allowed to create a wl_subsurface for the same
 * wl_surface again, but it is not allowed to use the wl_surface as
 * a cursor (cursor is a different role than sub-surface, and role
 * switching is not allowed).
 */
surface_interface := Interface{
    "wl_surface",
    6,
    0,
    nil,
    0,
    nil,
}

@(init)
surface_interface_init :: proc() {
    surface_interface.method_count = len(surface_requests)
    surface_interface.methods = &surface_requests[0]
    surface_interface.event_count = len(surface_events)
    surface_interface.events = &surface_events[0]
}

seat_interfaces := [?]^Interface{
    &pointer_interface,
    &keyboard_interface,
    &touch_interface,
    nil,
    nil,
}

seat_requests := [?]Message{
    { "get_pointer", "n", &seat_interfaces[0] },
    { "get_keyboard", "n", &seat_interfaces[1] },
    { "get_touch", "n", &seat_interfaces[2] },
    { "release", "", nil },
}

seat_events := [?]Message{
    { "capabilities", "u", &seat_interfaces[3] },
    { "name", "s", &seat_interfaces[4] },
}

/*
 * group of input devices
 * A seat is a group of keyboards, pointer and touch devices. This
 * object is published as a global during start up, or when such a
 * device is hot plugged.  A seat typically has a pointer and
 * maintains a keyboard focus and a pointer focus.
 */
seat_interface := Interface{
    "wl_seat",
    10,
    0,
    nil,
    0,
    nil,
}

@(init)
seat_interface_init :: proc() {
    seat_interface.method_count = len(seat_requests)
    seat_interface.methods = &seat_requests[0]
    seat_interface.event_count = len(seat_events)
    seat_interface.events = &seat_events[0]
}

pointer_interfaces := [?]^Interface{
    nil,
    &surface_interface,
    nil,
    nil,
    nil,
    &surface_interface,
    nil,
    nil,
    nil,
    &surface_interface,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}

pointer_requests := [?]Message{
    { "set_cursor", "u?oii", &pointer_interfaces[0] },
    { "release", "", nil },
}

pointer_events := [?]Message{
    { "enter", "uoff", &pointer_interfaces[4] },
    { "leave", "uo", &pointer_interfaces[8] },
    { "motion", "uff", &pointer_interfaces[10] },
    { "button", "uuuu", &pointer_interfaces[13] },
    { "axis", "uuf", &pointer_interfaces[17] },
    { "frame", "", nil },
    { "axis_source", "u", &pointer_interfaces[20] },
    { "axis_stop", "uu", &pointer_interfaces[21] },
    { "axis_discrete", "ui", &pointer_interfaces[23] },
    { "axis_value120", "ui", &pointer_interfaces[25] },
    { "axis_relative_direction", "uu", &pointer_interfaces[27] },
}

/*
 * pointer input device
 * The wl_pointer interface represents one or more input devices,
 * such as mice, which control the pointer location and pointer_focus
 * of a seat.
 * 
 * The wl_pointer interface generates motion, enter and leave
 * events for the surfaces that the pointer is located over,
 * and button and axis events for button presses, button releases
 * and scrolling.
 */
pointer_interface := Interface{
    "wl_pointer",
    10,
    0,
    nil,
    0,
    nil,
}

@(init)
pointer_interface_init :: proc() {
    pointer_interface.method_count = len(pointer_requests)
    pointer_interface.methods = &pointer_requests[0]
    pointer_interface.event_count = len(pointer_events)
    pointer_interface.events = &pointer_events[0]
}

keyboard_interfaces := [?]^Interface{
    nil,
    nil,
    nil,
    nil,
    &surface_interface,
    nil,
    nil,
    &surface_interface,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}

keyboard_requests := [?]Message{
    { "release", "", nil },
}

keyboard_events := [?]Message{
    { "keymap", "uhu", &keyboard_interfaces[0] },
    { "enter", "uoa", &keyboard_interfaces[3] },
    { "leave", "uo", &keyboard_interfaces[6] },
    { "key", "uuuu", &keyboard_interfaces[8] },
    { "modifiers", "uuuuu", &keyboard_interfaces[12] },
    { "repeat_info", "ii", &keyboard_interfaces[17] },
}

/*
 * keyboard input device
 * The wl_keyboard interface represents one or more keyboards
 * associated with a seat.
 * 
 * Each wl_keyboard has the following logical state:
 * 
 * - an active surface (possibly null),
 * - the keys currently logically down,
 * - the active modifiers,
 * - the active group.
 * 
 * By default, the active surface is null, the keys currently logically down
 * are empty, the active modifiers and the active group are 0.
 */
keyboard_interface := Interface{
    "wl_keyboard",
    10,
    0,
    nil,
    0,
    nil,
}

@(init)
keyboard_interface_init :: proc() {
    keyboard_interface.method_count = len(keyboard_requests)
    keyboard_interface.methods = &keyboard_requests[0]
    keyboard_interface.event_count = len(keyboard_events)
    keyboard_interface.events = &keyboard_events[0]
}

touch_interfaces := [?]^Interface{
    nil,
    nil,
    &surface_interface,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}

touch_requests := [?]Message{
    { "release", "", nil },
}

touch_events := [?]Message{
    { "down", "uuoiff", &touch_interfaces[0] },
    { "up", "uui", &touch_interfaces[6] },
    { "motion", "uiff", &touch_interfaces[9] },
    { "frame", "", nil },
    { "cancel", "", nil },
    { "shape", "iff", &touch_interfaces[13] },
    { "orientation", "if", &touch_interfaces[16] },
}

/*
 * touchscreen input device
 * The wl_touch interface represents a touchscreen
 * associated with a seat.
 * 
 * Touch interactions can consist of one or more contacts.
 * For each contact, a series of events is generated, starting
 * with a down event, followed by zero or more motion events,
 * and ending with an up event. Events relating to the same
 * contact point can be identified by the ID of the sequence.
 */
touch_interface := Interface{
    "wl_touch",
    10,
    0,
    nil,
    0,
    nil,
}

@(init)
touch_interface_init :: proc() {
    touch_interface.method_count = len(touch_requests)
    touch_interface.methods = &touch_requests[0]
    touch_interface.event_count = len(touch_events)
    touch_interface.events = &touch_events[0]
}

output_interfaces := [?]^Interface{
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}

output_requests := [?]Message{
    { "release", "", nil },
}

output_events := [?]Message{
    { "geometry", "iiiiissi", &output_interfaces[0] },
    { "mode", "uiii", &output_interfaces[8] },
    { "done", "", nil },
    { "scale", "i", &output_interfaces[12] },
    { "name", "s", &output_interfaces[13] },
    { "description", "s", &output_interfaces[14] },
}

/*
 * compositor output region
 * An output describes part of the compositor geometry.  The
 * compositor works in the 'compositor coordinate system' and an
 * output corresponds to a rectangular area in that space that is
 * actually visible.  This typically corresponds to a monitor that
 * displays part of the compositor space.  This object is published
 * as global during start up, or when a monitor is hotplugged.
 */
output_interface := Interface{
    "wl_output",
    4,
    0,
    nil,
    0,
    nil,
}

@(init)
output_interface_init :: proc() {
    output_interface.method_count = len(output_requests)
    output_interface.methods = &output_requests[0]
    output_interface.event_count = len(output_events)
    output_interface.events = &output_events[0]
}

region_interfaces := [?]^Interface{
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}

region_requests := [?]Message{
    { "destroy", "", nil },
    { "add", "iiii", &region_interfaces[0] },
    { "subtract", "iiii", &region_interfaces[4] },
}


/*
 * region interface
 * A region object describes an area.
 * 
 * Region objects are used to describe the opaque and input
 * regions of a surface.
 */
region_interface := Interface{
    "wl_region",
    1,
    0,
    nil,
    0,
    nil,
}

@(init)
region_interface_init :: proc() {
    region_interface.method_count = len(region_requests)
    region_interface.methods = &region_requests[0]
}

subcompositor_interfaces := [?]^Interface{
    &subsurface_interface,
    &surface_interface,
    &surface_interface,
}

subcompositor_requests := [?]Message{
    { "destroy", "", nil },
    { "get_subsurface", "noo", &subcompositor_interfaces[0] },
}


/*
 * sub-surface compositing
 * The global interface exposing sub-surface compositing capabilities.
 * A wl_surface, that has sub-surfaces associated, is called the
 * parent surface. Sub-surfaces can be arbitrarily nested and create
 * a tree of sub-surfaces.
 * 
 * The root surface in a tree of sub-surfaces is the main
 * surface. The main surface cannot be a sub-surface, because
 * sub-surfaces must always have a parent.
 * 
 * A main surface with its sub-surfaces forms a (compound) window.
 * For window management purposes, this set of wl_surface objects is
 * to be considered as a single window, and it should also behave as
 * such.
 * 
 * The aim of sub-surfaces is to offload some of the compositing work
 * within a window from clients to the compositor. A prime example is
 * a video player with decorations and video in separate wl_surface
 * objects. This should allow the compositor to pass YUV video buffer
 * processing to dedicated overlay hardware when possible.
 */
subcompositor_interface := Interface{
    "wl_subcompositor",
    1,
    0,
    nil,
    0,
    nil,
}

@(init)
subcompositor_interface_init :: proc() {
    subcompositor_interface.method_count = len(subcompositor_requests)
    subcompositor_interface.methods = &subcompositor_requests[0]
}

subsurface_interfaces := [?]^Interface{
    nil,
    nil,
    &surface_interface,
    &surface_interface,
}

subsurface_requests := [?]Message{
    { "destroy", "", nil },
    { "set_position", "ii", &subsurface_interfaces[0] },
    { "place_above", "o", &subsurface_interfaces[2] },
    { "place_below", "o", &subsurface_interfaces[3] },
    { "set_sync", "", nil },
    { "set_desync", "", nil },
}


/*
 * sub-surface interface to a wl_surface
 * An additional interface to a wl_surface object, which has been
 * made a sub-surface. A sub-surface has one parent surface. A
 * sub-surface's size and position are not limited to that of the parent.
 * Particularly, a sub-surface is not automatically clipped to its
 * parent's area.
 * 
 * A sub-surface becomes mapped, when a non-NULL wl_buffer is applied
 * and the parent surface is mapped. The order of which one happens
 * first is irrelevant. A sub-surface is hidden if the parent becomes
 * hidden, or if a NULL wl_buffer is applied. These rules apply
 * recursively through the tree of surfaces.
 * 
 * The behaviour of a wl_surface.commit request on a sub-surface
 * depends on the sub-surface's mode. The possible modes are
 * synchronized and desynchronized, see methods
 * wl_subsurface.set_sync and wl_subsurface.set_desync. Synchronized
 * mode caches the wl_surface state to be applied when the parent's
 * state gets applied, and desynchronized mode applies the pending
 * wl_surface state directly. A sub-surface is initially in the
 * synchronized mode.
 * 
 * Sub-surfaces also have another kind of state, which is managed by
 * wl_subsurface requests, as opposed to wl_surface requests. This
 * state includes the sub-surface position relative to the parent
 * surface (wl_subsurface.set_position), and the stacking order of
 * the parent and its sub-surfaces (wl_subsurface.place_above and
 * .place_below). This state is applied when the parent surface's
 * wl_surface state is applied, regardless of the sub-surface's mode.
 * As the exception, set_sync and set_desync are effective immediately.
 * 
 * The main surface can be thought to be always in desynchronized mode,
 * since it does not have a parent in the sub-surfaces sense.
 * 
 * Even if a sub-surface is in desynchronized mode, it will behave as
 * in synchronized mode, if its parent surface behaves as in
 * synchronized mode. This rule is applied recursively throughout the
 * tree of surfaces. This means, that one can set a sub-surface into
 * synchronized mode, and then assume that all its child and grand-child
 * sub-surfaces are synchronized, too, without explicitly setting them.
 * 
 * Destroying a sub-surface takes effect immediately. If you need to
 * synchronize the removal of a sub-surface to the parent surface update,
 * unmap the sub-surface first by attaching a NULL wl_buffer, update parent,
 * and then destroy the sub-surface.
 * 
 * If the parent wl_surface object is destroyed, the sub-surface is
 * unmapped.
 * 
 * A sub-surface never has the keyboard focus of any seat.
 * 
 * The wl_surface.offset request is ignored: clients must use set_position
 * instead to move the sub-surface.
 */
subsurface_interface := Interface{
    "wl_subsurface",
    1,
    0,
    nil,
    0,
    nil,
}

@(init)
subsurface_interface_init :: proc() {
    subsurface_interface.method_count = len(subsurface_requests)
    subsurface_interface.methods = &subsurface_requests[0]
}

fixes_interfaces := [?]^Interface{
    &registry_interface,
}

fixes_requests := [?]Message{
    { "destroy", "", nil },
    { "destroy_registry", "o", &fixes_interfaces[0] },
}


/*
 * wayland protocol fixes
 * This global fixes problems with other core-protocol interfaces that
 * cannot be fixed in these interfaces themselves.
 */
fixes_interface := Interface{
    "wl_fixes",
    1,
    0,
    nil,
    0,
    nil,
}

@(init)
fixes_interface_init :: proc() {
    fixes_interface.method_count = len(fixes_requests)
    fixes_interface.methods = &fixes_requests[0]
}


/*
 * global error values
 * These errors are global and can be emitted in response to any
 * server request.
 */
Display_Error :: enum {
    /*
     * server couldn't find object
     */
    Invalid_Object = 0,
    /*
     * method doesn't exist on the specified interface or malformed request
     */
    Invalid_Method = 1,
    /*
     * server is out of memory
     */
    No_Memory = 2,
    /*
     * implementation error in compositor
     */
    Implementation = 3,
}

Display_Listener :: struct{
    /*
     * fatal error event
     * The error event is sent out when a fatal (non-recoverable)
     * error has occurred.  The object_id argument is the object
     * where the error occurred, most often in response to a request
     * to that object.  The code identifies the error and is defined
     * by the object interface.  As such, each interface defines its
     * own set of error codes.  The message is a brief description
     * of the error, for (debugging) convenience.
     */
    error: proc(
        data: rawptr,
        display: ^Display,
        /*
         * object where the error occurred
         */
        object_id: ^Object,
        /*
         * error code
         */
        code: u32,
        /*
         * error description
         */
        message: cstring,
    ),

    /*
     * acknowledge object ID deletion
     * This event is used internally by the object ID management
     * logic. When a client deletes an object that it had created,
     * the server will send this event to acknowledge that it has
     * seen the delete request. When the client receives this event,
     * it will know that it can safely reuse the object ID.
     */
    delete_id: proc(
        data: rawptr,
        display: ^Display,
        /*
         * deleted object ID
         */
        id: u32,
    ),

}

display_add_listener :: #force_inline proc(display: ^Display, listener: ^Display_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)display,
        rawptr(listener),
        data
    )
}
display_set_user_data :: #force_inline proc(display: ^Display, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)display,
        user_data
    )
}
display_get_user_data :: #force_inline proc(display: ^Display) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)display)
}
display_get_version :: #force_inline proc(display: ^Display) -> u32 {
    return proxy_get_version(cast(^Proxy)display);
}

DISPLAY_SYNC :: 0
DISPLAY_GET_REGISTRY :: 1

/*
 * asynchronous roundtrip
 * The sync request asks the server to emit the 'done' event
 * on the returned wl_callback object.  Since requests are
 * handled in-order and events are delivered in-order, this can
 * be used as a barrier to ensure all previous requests and the
 * resulting events have been handled.
 * 
 * The object returned by this request will be destroyed by the
 * compositor after the callback is fired and as such the client must not
 * attempt to use it after that point.
 * 
 * The callback_data passed in the callback is undefined and should be ignored.
 */
display_sync :: #force_inline proc(
    display: ^Display,
) -> ^Callback {
    return cast(^Callback)proxy_marshal_flags(
        cast(^Proxy)display,
        DISPLAY_SYNC,
        &callback_interface,
        proxy_get_version(cast(^Proxy)display),
        {},
        nil,
    )
}

/*
 * get global registry object
 * This request creates a registry object that allows the client
 * to list and bind the global objects available from the
 * compositor.
 * 
 * It should be noted that the server side resources consumed in
 * response to a get_registry request can only be released when the
 * client disconnects, not when the client side proxy is destroyed.
 * Therefore, clients should invoke get_registry as infrequently as
 * possible to avoid wasting memory.
 */
display_get_registry :: #force_inline proc(
    display: ^Display,
) -> ^Registry {
    return cast(^Registry)proxy_marshal_flags(
        cast(^Proxy)display,
        DISPLAY_GET_REGISTRY,
        &registry_interface,
        proxy_get_version(cast(^Proxy)display),
        {},
        nil,
    )
}


Registry_Listener :: struct{
    /*
     * announce global object
     * Notify the client of global objects.
     * 
     * The event notifies the client that a global object with
     * the given name is now available, and it implements the
     * given version of the given interface.
     */
    global: proc(
        data: rawptr,
        registry: ^Registry,
        /*
         * numeric name of the global object
         */
        name: u32,
        /*
         * interface implemented by the object
         */
        interface: cstring,
        /*
         * interface version
         */
        version: u32,
    ),

    /*
     * announce removal of global object
     * Notify the client of removed global objects.
     * 
     * This event notifies the client that the global identified
     * by name is no longer available.  If the client bound to
     * the global using the bind request, the client should now
     * destroy that object.
     * 
     * The object remains valid and requests to the object will be
     * ignored until the client destroys it, to avoid races between
     * the global going away and a client sending a request to it.
     */
    global_remove: proc(
        data: rawptr,
        registry: ^Registry,
        /*
         * numeric name of the global object
         */
        name: u32,
    ),

}

registry_add_listener :: #force_inline proc(registry: ^Registry, listener: ^Registry_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)registry,
        rawptr(listener),
        data
    )
}
registry_set_user_data :: #force_inline proc(registry: ^Registry, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)registry,
        user_data
    )
}
registry_get_user_data :: #force_inline proc(registry: ^Registry) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)registry)
}
registry_get_version :: #force_inline proc(registry: ^Registry) -> u32 {
    return proxy_get_version(cast(^Proxy)registry);
}

REGISTRY_BIND :: 0

/*
 * bind an object to the display
 * Binds a new, client-created object to the server using the
 * specified name as the identifier.
 */
registry_bind :: #force_inline proc(
    registry: ^Registry,
    /*
     * unique numeric name of the object
     */
    name: u32,
    interface: ^Interface,
    version: u32,
) -> rawptr {
    return cast(rawptr)proxy_marshal_flags(
        cast(^Proxy)registry,
        REGISTRY_BIND,
        interface,
        version,
        {},
        name,
        interface.name,
        version,
        nil,
    )
}


Callback_Listener :: struct{
    /*
     * done event
     * Notify the client when the related request is done.
     */
    done: proc(
        data: rawptr,
        callback: ^Callback,
        /*
         * request-specific data for the callback
         */
        callback_data: u32,
    ),

}

callback_add_listener :: #force_inline proc(callback: ^Callback, listener: ^Callback_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)callback,
        rawptr(listener),
        data
    )
}
callback_set_user_data :: #force_inline proc(callback: ^Callback, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)callback,
        user_data
    )
}
callback_get_user_data :: #force_inline proc(callback: ^Callback) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)callback)
}
callback_get_version :: #force_inline proc(callback: ^Callback) -> u32 {
    return proxy_get_version(cast(^Proxy)callback);
}




compositor_set_user_data :: #force_inline proc(compositor: ^Compositor, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)compositor,
        user_data
    )
}
compositor_get_user_data :: #force_inline proc(compositor: ^Compositor) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)compositor)
}
compositor_get_version :: #force_inline proc(compositor: ^Compositor) -> u32 {
    return proxy_get_version(cast(^Proxy)compositor);
}

COMPOSITOR_CREATE_SURFACE :: 0
COMPOSITOR_CREATE_REGION :: 1

/*
 * create new surface
 * Ask the compositor to create a new surface.
 */
compositor_create_surface :: #force_inline proc(
    compositor: ^Compositor,
) -> ^Surface {
    return cast(^Surface)proxy_marshal_flags(
        cast(^Proxy)compositor,
        COMPOSITOR_CREATE_SURFACE,
        &surface_interface,
        proxy_get_version(cast(^Proxy)compositor),
        {},
        nil,
    )
}

/*
 * create new region
 * Ask the compositor to create a new region.
 */
compositor_create_region :: #force_inline proc(
    compositor: ^Compositor,
) -> ^Region {
    return cast(^Region)proxy_marshal_flags(
        cast(^Proxy)compositor,
        COMPOSITOR_CREATE_REGION,
        &region_interface,
        proxy_get_version(cast(^Proxy)compositor),
        {},
        nil,
    )
}



shm_pool_set_user_data :: #force_inline proc(shm_pool: ^Shm_Pool, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)shm_pool,
        user_data
    )
}
shm_pool_get_user_data :: #force_inline proc(shm_pool: ^Shm_Pool) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)shm_pool)
}
shm_pool_get_version :: #force_inline proc(shm_pool: ^Shm_Pool) -> u32 {
    return proxy_get_version(cast(^Proxy)shm_pool);
}

SHM_POOL_CREATE_BUFFER :: 0
SHM_POOL_DESTROY :: 1
SHM_POOL_RESIZE :: 2

/*
 * create a buffer from the pool
 * Create a wl_buffer object from the pool.
 * 
 * The buffer is created offset bytes into the pool and has
 * width and height as specified.  The stride argument specifies
 * the number of bytes from the beginning of one row to the beginning
 * of the next.  The format is the pixel format of the buffer and
 * must be one of those advertised through the wl_shm.format event.
 * 
 * A buffer will keep a reference to the pool it was created from
 * so it is valid to destroy the pool immediately after creating
 * a buffer from it.
 */
shm_pool_create_buffer :: #force_inline proc(
    shm_pool: ^Shm_Pool,
    /*
     * buffer byte offset within the pool
     */
    offset: i32,
    /*
     * buffer width, in pixels
     */
    width: i32,
    /*
     * buffer height, in pixels
     */
    height: i32,
    /*
     * number of bytes from the beginning of one row to the beginning of the next row
     */
    stride: i32,
    /*
     * buffer pixel format
     */
    format: Shm_Format,
) -> ^Buffer {
    return cast(^Buffer)proxy_marshal_flags(
        cast(^Proxy)shm_pool,
        SHM_POOL_CREATE_BUFFER,
        &buffer_interface,
        proxy_get_version(cast(^Proxy)shm_pool),
        {},
        nil,
        offset,
        width,
        height,
        stride,
        format,
    )
}

/*
 * destroy the pool
 * Destroy the shared memory pool.
 * 
 * The mmapped memory will be released when all
 * buffers that have been created from this pool
 * are gone.
 */
shm_pool_destroy :: #force_inline proc(
    shm_pool: ^Shm_Pool,
) {
    proxy_marshal_flags(
        cast(^Proxy)shm_pool,
        SHM_POOL_DESTROY,
        nil,
        1,
        {},
    )
}

/*
 * change the size of the pool mapping
 * This request will cause the server to remap the backing memory
 * for the pool from the file descriptor passed when the pool was
 * created, but using the new size.  This request can only be
 * used to make the pool bigger.
 * 
 * This request only changes the amount of bytes that are mmapped
 * by the server and does not touch the file corresponding to the
 * file descriptor passed at creation time. It is the client's
 * responsibility to ensure that the file is at least as big as
 * the new pool size.
 */
shm_pool_resize :: #force_inline proc(
    shm_pool: ^Shm_Pool,
    /*
     * new size of the pool, in bytes
     */
    size: i32,
) {
    proxy_marshal_flags(
        cast(^Proxy)shm_pool,
        SHM_POOL_RESIZE,
        nil,
        1,
        {},
        size,
    )
}


/*
 * wl_shm error values
 * These errors can be emitted in response to wl_shm requests.
 */
Shm_Error :: enum {
    /*
     * buffer format is not known
     */
    Invalid_Format = 0,
    /*
     * invalid size or stride during pool or buffer creation
     */
    Invalid_Stride = 1,
    /*
     * mmapping the file descriptor failed
     */
    Invalid_Fd = 2,
}

/*
 * pixel formats
 * This describes the memory layout of an individual pixel.
 * 
 * All renderers should support argb8888 and xrgb8888 but any other
 * formats are optional and may not be supported by the particular
 * renderer in use.
 * 
 * The drm format codes match the macros defined in drm_fourcc.h, except
 * argb8888 and xrgb8888. The formats actually supported by the compositor
 * will be reported by the format event.
 * 
 * For all wl_shm formats and unless specified in another protocol
 * extension, pre-multiplied alpha is used for pixel values.
 */
Shm_Format :: enum {
    /*
     * 32-bit ARGB format, [31:0] A:R:G:B 8:8:8:8 little endian
     */
    Argb8888 = 0,
    /*
     * 32-bit RGB format, [31:0] x:R:G:B 8:8:8:8 little endian
     */
    Xrgb8888 = 1,
    /*
     * 8-bit color index format, [7:0] C
     */
    C8 = 538982467,
    /*
     * 8-bit RGB format, [7:0] R:G:B 3:3:2
     */
    Rgb332 = 943867730,
    /*
     * 8-bit BGR format, [7:0] B:G:R 2:3:3
     */
    Bgr233 = 944916290,
    /*
     * 16-bit xRGB format, [15:0] x:R:G:B 4:4:4:4 little endian
     */
    Xrgb4444 = 842093144,
    /*
     * 16-bit xBGR format, [15:0] x:B:G:R 4:4:4:4 little endian
     */
    Xbgr4444 = 842089048,
    /*
     * 16-bit RGBx format, [15:0] R:G:B:x 4:4:4:4 little endian
     */
    Rgbx4444 = 842094674,
    /*
     * 16-bit BGRx format, [15:0] B:G:R:x 4:4:4:4 little endian
     */
    Bgrx4444 = 842094658,
    /*
     * 16-bit ARGB format, [15:0] A:R:G:B 4:4:4:4 little endian
     */
    Argb4444 = 842093121,
    /*
     * 16-bit ABGR format, [15:0] A:B:G:R 4:4:4:4 little endian
     */
    Abgr4444 = 842089025,
    /*
     * 16-bit RBGA format, [15:0] R:G:B:A 4:4:4:4 little endian
     */
    Rgba4444 = 842088786,
    /*
     * 16-bit BGRA format, [15:0] B:G:R:A 4:4:4:4 little endian
     */
    Bgra4444 = 842088770,
    /*
     * 16-bit xRGB format, [15:0] x:R:G:B 1:5:5:5 little endian
     */
    Xrgb1555 = 892424792,
    /*
     * 16-bit xBGR 1555 format, [15:0] x:B:G:R 1:5:5:5 little endian
     */
    Xbgr1555 = 892420696,
    /*
     * 16-bit RGBx 5551 format, [15:0] R:G:B:x 5:5:5:1 little endian
     */
    Rgbx5551 = 892426322,
    /*
     * 16-bit BGRx 5551 format, [15:0] B:G:R:x 5:5:5:1 little endian
     */
    Bgrx5551 = 892426306,
    /*
     * 16-bit ARGB 1555 format, [15:0] A:R:G:B 1:5:5:5 little endian
     */
    Argb1555 = 892424769,
    /*
     * 16-bit ABGR 1555 format, [15:0] A:B:G:R 1:5:5:5 little endian
     */
    Abgr1555 = 892420673,
    /*
     * 16-bit RGBA 5551 format, [15:0] R:G:B:A 5:5:5:1 little endian
     */
    Rgba5551 = 892420434,
    /*
     * 16-bit BGRA 5551 format, [15:0] B:G:R:A 5:5:5:1 little endian
     */
    Bgra5551 = 892420418,
    /*
     * 16-bit RGB 565 format, [15:0] R:G:B 5:6:5 little endian
     */
    Rgb565 = 909199186,
    /*
     * 16-bit BGR 565 format, [15:0] B:G:R 5:6:5 little endian
     */
    Bgr565 = 909199170,
    /*
     * 24-bit RGB format, [23:0] R:G:B little endian
     */
    Rgb888 = 875710290,
    /*
     * 24-bit BGR format, [23:0] B:G:R little endian
     */
    Bgr888 = 875710274,
    /*
     * 32-bit xBGR format, [31:0] x:B:G:R 8:8:8:8 little endian
     */
    Xbgr8888 = 875709016,
    /*
     * 32-bit RGBx format, [31:0] R:G:B:x 8:8:8:8 little endian
     */
    Rgbx8888 = 875714642,
    /*
     * 32-bit BGRx format, [31:0] B:G:R:x 8:8:8:8 little endian
     */
    Bgrx8888 = 875714626,
    /*
     * 32-bit ABGR format, [31:0] A:B:G:R 8:8:8:8 little endian
     */
    Abgr8888 = 875708993,
    /*
     * 32-bit RGBA format, [31:0] R:G:B:A 8:8:8:8 little endian
     */
    Rgba8888 = 875708754,
    /*
     * 32-bit BGRA format, [31:0] B:G:R:A 8:8:8:8 little endian
     */
    Bgra8888 = 875708738,
    /*
     * 32-bit xRGB format, [31:0] x:R:G:B 2:10:10:10 little endian
     */
    Xrgb2101010 = 808669784,
    /*
     * 32-bit xBGR format, [31:0] x:B:G:R 2:10:10:10 little endian
     */
    Xbgr2101010 = 808665688,
    /*
     * 32-bit RGBx format, [31:0] R:G:B:x 10:10:10:2 little endian
     */
    Rgbx1010102 = 808671314,
    /*
     * 32-bit BGRx format, [31:0] B:G:R:x 10:10:10:2 little endian
     */
    Bgrx1010102 = 808671298,
    /*
     * 32-bit ARGB format, [31:0] A:R:G:B 2:10:10:10 little endian
     */
    Argb2101010 = 808669761,
    /*
     * 32-bit ABGR format, [31:0] A:B:G:R 2:10:10:10 little endian
     */
    Abgr2101010 = 808665665,
    /*
     * 32-bit RGBA format, [31:0] R:G:B:A 10:10:10:2 little endian
     */
    Rgba1010102 = 808665426,
    /*
     * 32-bit BGRA format, [31:0] B:G:R:A 10:10:10:2 little endian
     */
    Bgra1010102 = 808665410,
    /*
     * packed YCbCr format, [31:0] Cr0:Y1:Cb0:Y0 8:8:8:8 little endian
     */
    Yuyv = 1448695129,
    /*
     * packed YCbCr format, [31:0] Cb0:Y1:Cr0:Y0 8:8:8:8 little endian
     */
    Yvyu = 1431918169,
    /*
     * packed YCbCr format, [31:0] Y1:Cr0:Y0:Cb0 8:8:8:8 little endian
     */
    Uyvy = 1498831189,
    /*
     * packed YCbCr format, [31:0] Y1:Cb0:Y0:Cr0 8:8:8:8 little endian
     */
    Vyuy = 1498765654,
    /*
     * packed AYCbCr format, [31:0] A:Y:Cb:Cr 8:8:8:8 little endian
     */
    Ayuv = 1448433985,
    /*
     * 2 plane YCbCr Cr:Cb format, 2x2 subsampled Cr:Cb plane
     */
    Nv12 = 842094158,
    /*
     * 2 plane YCbCr Cb:Cr format, 2x2 subsampled Cb:Cr plane
     */
    Nv21 = 825382478,
    /*
     * 2 plane YCbCr Cr:Cb format, 2x1 subsampled Cr:Cb plane
     */
    Nv16 = 909203022,
    /*
     * 2 plane YCbCr Cb:Cr format, 2x1 subsampled Cb:Cr plane
     */
    Nv61 = 825644622,
    /*
     * 3 plane YCbCr format, 4x4 subsampled Cb (1) and Cr (2) planes
     */
    Yuv410 = 961959257,
    /*
     * 3 plane YCbCr format, 4x4 subsampled Cr (1) and Cb (2) planes
     */
    Yvu410 = 961893977,
    /*
     * 3 plane YCbCr format, 4x1 subsampled Cb (1) and Cr (2) planes
     */
    Yuv411 = 825316697,
    /*
     * 3 plane YCbCr format, 4x1 subsampled Cr (1) and Cb (2) planes
     */
    Yvu411 = 825316953,
    /*
     * 3 plane YCbCr format, 2x2 subsampled Cb (1) and Cr (2) planes
     */
    Yuv420 = 842093913,
    /*
     * 3 plane YCbCr format, 2x2 subsampled Cr (1) and Cb (2) planes
     */
    Yvu420 = 842094169,
    /*
     * 3 plane YCbCr format, 2x1 subsampled Cb (1) and Cr (2) planes
     */
    Yuv422 = 909202777,
    /*
     * 3 plane YCbCr format, 2x1 subsampled Cr (1) and Cb (2) planes
     */
    Yvu422 = 909203033,
    /*
     * 3 plane YCbCr format, non-subsampled Cb (1) and Cr (2) planes
     */
    Yuv444 = 875713881,
    /*
     * 3 plane YCbCr format, non-subsampled Cr (1) and Cb (2) planes
     */
    Yvu444 = 875714137,
    /*
     * [7:0] R
     */
    R8 = 538982482,
    /*
     * [15:0] R little endian
     */
    R16 = 540422482,
    /*
     * [15:0] R:G 8:8 little endian
     */
    Rg88 = 943212370,
    /*
     * [15:0] G:R 8:8 little endian
     */
    Gr88 = 943215175,
    /*
     * [31:0] R:G 16:16 little endian
     */
    Rg1616 = 842221394,
    /*
     * [31:0] G:R 16:16 little endian
     */
    Gr1616 = 842224199,
    /*
     * [63:0] x:R:G:B 16:16:16:16 little endian
     */
    Xrgb16161616f = 1211388504,
    /*
     * [63:0] x:B:G:R 16:16:16:16 little endian
     */
    Xbgr16161616f = 1211384408,
    /*
     * [63:0] A:R:G:B 16:16:16:16 little endian
     */
    Argb16161616f = 1211388481,
    /*
     * [63:0] A:B:G:R 16:16:16:16 little endian
     */
    Abgr16161616f = 1211384385,
    /*
     * [31:0] X:Y:Cb:Cr 8:8:8:8 little endian
     */
    Xyuv8888 = 1448434008,
    /*
     * [23:0] Cr:Cb:Y 8:8:8 little endian
     */
    Vuy888 = 875713878,
    /*
     * Y followed by U then V, 10:10:10. Non-linear modifier only
     */
    Vuy101010 = 808670550,
    /*
     * [63:0] Cr0:0:Y1:0:Cb0:0:Y0:0 10:6:10:6:10:6:10:6 little endian per 2 Y pixels
     */
    Y210 = 808530521,
    /*
     * [63:0] Cr0:0:Y1:0:Cb0:0:Y0:0 12:4:12:4:12:4:12:4 little endian per 2 Y pixels
     */
    Y212 = 842084953,
    /*
     * [63:0] Cr0:Y1:Cb0:Y0 16:16:16:16 little endian per 2 Y pixels
     */
    Y216 = 909193817,
    /*
     * [31:0] A:Cr:Y:Cb 2:10:10:10 little endian
     */
    Y410 = 808531033,
    /*
     * [63:0] A:0:Cr:0:Y:0:Cb:0 12:4:12:4:12:4:12:4 little endian
     */
    Y412 = 842085465,
    /*
     * [63:0] A:Cr:Y:Cb 16:16:16:16 little endian
     */
    Y416 = 909194329,
    /*
     * [31:0] X:Cr:Y:Cb 2:10:10:10 little endian
     */
    Xvyu2101010 = 808670808,
    /*
     * [63:0] X:0:Cr:0:Y:0:Cb:0 12:4:12:4:12:4:12:4 little endian
     */
    Xvyu12_16161616 = 909334104,
    /*
     * [63:0] X:Cr:Y:Cb 16:16:16:16 little endian
     */
    Xvyu16161616 = 942954072,
    /*
     * [63:0] A3:A2:Y3:0:Cr0:0:Y2:0:A1:A0:Y1:0:Cb0:0:Y0:0 1:1:8:2:8:2:8:2:1:1:8:2:8:2:8:2 little endian
     */
    Y0l0 = 810299481,
    /*
     * [63:0] X3:X2:Y3:0:Cr0:0:Y2:0:X1:X0:Y1:0:Cb0:0:Y0:0 1:1:8:2:8:2:8:2:1:1:8:2:8:2:8:2 little endian
     */
    X0l0 = 810299480,
    /*
     * [63:0] A3:A2:Y3:Cr0:Y2:A1:A0:Y1:Cb0:Y0 1:1:10:10:10:1:1:10:10:10 little endian
     */
    Y0l2 = 843853913,
    /*
     * [63:0] X3:X2:Y3:Cr0:Y2:X1:X0:Y1:Cb0:Y0 1:1:10:10:10:1:1:10:10:10 little endian
     */
    X0l2 = 843853912,
    Yuv420_8bit = 942691673,
    Yuv420_10bit = 808539481,
    Xrgb8888_A8 = 943805016,
    Xbgr8888_A8 = 943800920,
    Rgbx8888_A8 = 943806546,
    Bgrx8888_A8 = 943806530,
    Rgb888_A8 = 943798354,
    Bgr888_A8 = 943798338,
    Rgb565_A8 = 943797586,
    Bgr565_A8 = 943797570,
    /*
     * non-subsampled Cr:Cb plane
     */
    Nv24 = 875714126,
    /*
     * non-subsampled Cb:Cr plane
     */
    Nv42 = 842290766,
    /*
     * 2x1 subsampled Cr:Cb plane, 10 bit per channel
     */
    P210 = 808530512,
    /*
     * 2x2 subsampled Cr:Cb plane 10 bits per channel
     */
    P010 = 808530000,
    /*
     * 2x2 subsampled Cr:Cb plane 12 bits per channel
     */
    P012 = 842084432,
    /*
     * 2x2 subsampled Cr:Cb plane 16 bits per channel
     */
    P016 = 909193296,
    /*
     * [63:0] A:x:B:x:G:x:R:x 10:6:10:6:10:6:10:6 little endian
     */
    Axbxgxrx106106106106 = 808534593,
    /*
     * 2x2 subsampled Cr:Cb plane
     */
    Nv15 = 892425806,
    Q410 = 808531025,
    Q401 = 825242705,
    /*
     * [63:0] x:R:G:B 16:16:16:16 little endian
     */
    Xrgb16161616 = 942953048,
    /*
     * [63:0] x:B:G:R 16:16:16:16 little endian
     */
    Xbgr16161616 = 942948952,
    /*
     * [63:0] A:R:G:B 16:16:16:16 little endian
     */
    Argb16161616 = 942953025,
    /*
     * [63:0] A:B:G:R 16:16:16:16 little endian
     */
    Abgr16161616 = 942948929,
    /*
     * [7:0] C0:C1:C2:C3:C4:C5:C6:C7 1:1:1:1:1:1:1:1 eight pixels/byte
     */
    C1 = 538980675,
    /*
     * [7:0] C0:C1:C2:C3 2:2:2:2 four pixels/byte
     */
    C2 = 538980931,
    /*
     * [7:0] C0:C1 4:4 two pixels/byte
     */
    C4 = 538981443,
    /*
     * [7:0] D0:D1:D2:D3:D4:D5:D6:D7 1:1:1:1:1:1:1:1 eight pixels/byte
     */
    D1 = 538980676,
    /*
     * [7:0] D0:D1:D2:D3 2:2:2:2 four pixels/byte
     */
    D2 = 538980932,
    /*
     * [7:0] D0:D1 4:4 two pixels/byte
     */
    D4 = 538981444,
    /*
     * [7:0] D
     */
    D8 = 538982468,
    /*
     * [7:0] R0:R1:R2:R3:R4:R5:R6:R7 1:1:1:1:1:1:1:1 eight pixels/byte
     */
    R1 = 538980690,
    /*
     * [7:0] R0:R1:R2:R3 2:2:2:2 four pixels/byte
     */
    R2 = 538980946,
    /*
     * [7:0] R0:R1 4:4 two pixels/byte
     */
    R4 = 538981458,
    /*
     * [15:0] x:R 6:10 little endian
     */
    R10 = 540029266,
    /*
     * [15:0] x:R 4:12 little endian
     */
    R12 = 540160338,
    /*
     * [31:0] A:Cr:Cb:Y 8:8:8:8 little endian
     */
    Avuy8888 = 1498764865,
    /*
     * [31:0] X:Cr:Cb:Y 8:8:8:8 little endian
     */
    Xvuy8888 = 1498764888,
    /*
     * 2x2 subsampled Cr:Cb plane 10 bits per channel packed
     */
    P030 = 808661072,
}

Shm_Listener :: struct{
    /*
     * pixel format description
     * Informs the client about a valid pixel format that
     * can be used for buffers. Known formats include
     * argb8888 and xrgb8888.
     */
    format: proc(
        data: rawptr,
        shm: ^Shm,
        /*
         * buffer pixel format
         */
        format: Shm_Format,
    ),

}

shm_add_listener :: #force_inline proc(shm: ^Shm, listener: ^Shm_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)shm,
        rawptr(listener),
        data
    )
}
shm_set_user_data :: #force_inline proc(shm: ^Shm, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)shm,
        user_data
    )
}
shm_get_user_data :: #force_inline proc(shm: ^Shm) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)shm)
}
shm_get_version :: #force_inline proc(shm: ^Shm) -> u32 {
    return proxy_get_version(cast(^Proxy)shm);
}

SHM_CREATE_POOL :: 0
SHM_RELEASE :: 1

/*
 * create a shm pool
 * Create a new wl_shm_pool object.
 * 
 * The pool can be used to create shared memory based buffer
 * objects.  The server will mmap size bytes of the passed file
 * descriptor, to use as backing memory for the pool.
 */
shm_create_pool :: #force_inline proc(
    shm: ^Shm,
    /*
     * file descriptor for the pool
     */
    fd: i32,
    /*
     * pool size, in bytes
     */
    size: i32,
) -> ^Shm_Pool {
    return cast(^Shm_Pool)proxy_marshal_flags(
        cast(^Proxy)shm,
        SHM_CREATE_POOL,
        &shm_pool_interface,
        proxy_get_version(cast(^Proxy)shm),
        {},
        nil,
        fd,
        size,
    )
}

/*
 * release the shm object
 * Using this request a client can tell the server that it is not going to
 * use the shm object anymore.
 * 
 * Objects created via this interface remain unaffected.
 */
shm_release :: #force_inline proc(
    shm: ^Shm,
) {
    proxy_marshal_flags(
        cast(^Proxy)shm,
        SHM_RELEASE,
        nil,
        1,
        {},
    )
}


Buffer_Listener :: struct{
    /*
     * compositor releases buffer
     * Sent when this wl_buffer is no longer used by the compositor.
     * The client is now free to reuse or destroy this buffer and its
     * backing storage.
     * 
     * If a client receives a release event before the frame callback
     * requested in the same wl_surface.commit that attaches this
     * wl_buffer to a surface, then the client is immediately free to
     * reuse the buffer and its backing storage, and does not need a
     * second buffer for the next surface content update. Typically
     * this is possible, when the compositor maintains a copy of the
     * wl_surface contents, e.g. as a GL texture. This is an important
     * optimization for GL(ES) compositors with wl_shm clients.
     */
    release: proc(
        data: rawptr,
        buffer: ^Buffer,
    ),

}

buffer_add_listener :: #force_inline proc(buffer: ^Buffer, listener: ^Buffer_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)buffer,
        rawptr(listener),
        data
    )
}
buffer_set_user_data :: #force_inline proc(buffer: ^Buffer, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)buffer,
        user_data
    )
}
buffer_get_user_data :: #force_inline proc(buffer: ^Buffer) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)buffer)
}
buffer_get_version :: #force_inline proc(buffer: ^Buffer) -> u32 {
    return proxy_get_version(cast(^Proxy)buffer);
}

BUFFER_DESTROY :: 0

/*
 * destroy a buffer
 * Destroy a buffer. If and how you need to release the backing
 * storage is defined by the buffer factory interface.
 * 
 * For possible side-effects to a surface, see wl_surface.attach.
 */
buffer_destroy :: #force_inline proc(
    buffer: ^Buffer,
) {
    proxy_marshal_flags(
        cast(^Proxy)buffer,
        BUFFER_DESTROY,
        nil,
        1,
        {},
    )
}


Data_Offer_Error :: enum {
    /*
     * finish request was called untimely
     */
    Invalid_Finish = 0,
    /*
     * action mask contains invalid values
     */
    Invalid_Action_Mask = 1,
    /*
     * action argument has an invalid value
     */
    Invalid_Action = 2,
    /*
     * offer doesn't accept this request
     */
    Invalid_Offer = 3,
}

Data_Offer_Listener :: struct{
    /*
     * advertise offered mime type
     * Sent immediately after creating the wl_data_offer object.  One
     * event per offered mime type.
     */
    offer: proc(
        data: rawptr,
        data_offer: ^Data_Offer,
        /*
         * offered mime type
         */
        mime_type: cstring,
    ),

    /*
     * notify the source-side available actions
     * This event indicates the actions offered by the data source. It
     * will be sent immediately after creating the wl_data_offer object,
     * or anytime the source side changes its offered actions through
     * wl_data_source.set_actions.
     */
    source_actions: proc(
        data: rawptr,
        data_offer: ^Data_Offer,
        /*
         * actions offered by the data source
         */
        source_actions: Data_Device_Manager_Dnd_Action_Flags,
    ),

    /*
     * notify the selected action
     * This event indicates the action selected by the compositor after
     * matching the source/destination side actions. Only one action (or
     * none) will be offered here.
     * 
     * This event can be emitted multiple times during the drag-and-drop
     * operation in response to destination side action changes through
     * wl_data_offer.set_actions.
     * 
     * This event will no longer be emitted after wl_data_device.drop
     * happened on the drag-and-drop destination, the client must
     * honor the last action received, or the last preferred one set
     * through wl_data_offer.set_actions when handling an "ask" action.
     * 
     * Compositors may also change the selected action on the fly, mainly
     * in response to keyboard modifier changes during the drag-and-drop
     * operation.
     * 
     * The most recent action received is always the valid one. Prior to
     * receiving wl_data_device.drop, the chosen action may change (e.g.
     * due to keyboard modifiers being pressed). At the time of receiving
     * wl_data_device.drop the drag-and-drop destination must honor the
     * last action received.
     * 
     * Action changes may still happen after wl_data_device.drop,
     * especially on "ask" actions, where the drag-and-drop destination
     * may choose another action afterwards. Action changes happening
     * at this stage are always the result of inter-client negotiation, the
     * compositor shall no longer be able to induce a different action.
     * 
     * Upon "ask" actions, it is expected that the drag-and-drop destination
     * may potentially choose a different action and/or mime type,
     * based on wl_data_offer.source_actions and finally chosen by the
     * user (e.g. popping up a menu with the available options). The
     * final wl_data_offer.set_actions and wl_data_offer.accept requests
     * must happen before the call to wl_data_offer.finish.
     */
    action: proc(
        data: rawptr,
        data_offer: ^Data_Offer,
        /*
         * action selected by the compositor
         */
        dnd_action: Data_Device_Manager_Dnd_Action_Flags,
    ),

}

data_offer_add_listener :: #force_inline proc(data_offer: ^Data_Offer, listener: ^Data_Offer_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)data_offer,
        rawptr(listener),
        data
    )
}
data_offer_set_user_data :: #force_inline proc(data_offer: ^Data_Offer, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)data_offer,
        user_data
    )
}
data_offer_get_user_data :: #force_inline proc(data_offer: ^Data_Offer) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)data_offer)
}
data_offer_get_version :: #force_inline proc(data_offer: ^Data_Offer) -> u32 {
    return proxy_get_version(cast(^Proxy)data_offer);
}

DATA_OFFER_ACCEPT :: 0
DATA_OFFER_RECEIVE :: 1
DATA_OFFER_DESTROY :: 2
DATA_OFFER_FINISH :: 3
DATA_OFFER_SET_ACTIONS :: 4

/*
 * accept one of the offered mime types
 * Indicate that the client can accept the given mime type, or
 * NULL for not accepted.
 * 
 * For objects of version 2 or older, this request is used by the
 * client to give feedback whether the client can receive the given
 * mime type, or NULL if none is accepted; the feedback does not
 * determine whether the drag-and-drop operation succeeds or not.
 * 
 * For objects of version 3 or newer, this request determines the
 * final result of the drag-and-drop operation. If the end result
 * is that no mime types were accepted, the drag-and-drop operation
 * will be cancelled and the corresponding drag source will receive
 * wl_data_source.cancelled. Clients may still use this event in
 * conjunction with wl_data_source.action for feedback.
 */
data_offer_accept :: #force_inline proc(
    data_offer: ^Data_Offer,
    /*
     * serial number of the accept request
     */
    serial: u32,
    /*
     * mime type accepted by the client
     */
    mime_type: cstring,
) {
    proxy_marshal_flags(
        cast(^Proxy)data_offer,
        DATA_OFFER_ACCEPT,
        nil,
        1,
        {},
        serial,
        mime_type,
    )
}

/*
 * request that the data is transferred
 * To transfer the offered data, the client issues this request
 * and indicates the mime type it wants to receive.  The transfer
 * happens through the passed file descriptor (typically created
 * with the pipe system call).  The source client writes the data
 * in the mime type representation requested and then closes the
 * file descriptor.
 * 
 * The receiving client reads from the read end of the pipe until
 * EOF and then closes its end, at which point the transfer is
 * complete.
 * 
 * This request may happen multiple times for different mime types,
 * both before and after wl_data_device.drop. Drag-and-drop destination
 * clients may preemptively fetch data or examine it more closely to
 * determine acceptance.
 */
data_offer_receive :: #force_inline proc(
    data_offer: ^Data_Offer,
    /*
     * mime type desired by receiver
     */
    mime_type: cstring,
    /*
     * file descriptor for data transfer
     */
    fd: i32,
) {
    proxy_marshal_flags(
        cast(^Proxy)data_offer,
        DATA_OFFER_RECEIVE,
        nil,
        1,
        {},
        mime_type,
        fd,
    )
}

/*
 * destroy data offer
 * Destroy the data offer.
 */
data_offer_destroy :: #force_inline proc(
    data_offer: ^Data_Offer,
) {
    proxy_marshal_flags(
        cast(^Proxy)data_offer,
        DATA_OFFER_DESTROY,
        nil,
        1,
        {},
    )
}

/*
 * the offer will no longer be used
 * Notifies the compositor that the drag destination successfully
 * finished the drag-and-drop operation.
 * 
 * Upon receiving this request, the compositor will emit
 * wl_data_source.dnd_finished on the drag source client.
 * 
 * It is a client error to perform other requests than
 * wl_data_offer.destroy after this one. It is also an error to perform
 * this request after a NULL mime type has been set in
 * wl_data_offer.accept or no action was received through
 * wl_data_offer.action.
 * 
 * If wl_data_offer.finish request is received for a non drag and drop
 * operation, the invalid_finish protocol error is raised.
 */
data_offer_finish :: #force_inline proc(
    data_offer: ^Data_Offer,
) {
    proxy_marshal_flags(
        cast(^Proxy)data_offer,
        DATA_OFFER_FINISH,
        nil,
        1,
        {},
    )
}

/*
 * set the available/preferred drag-and-drop actions
 * Sets the actions that the destination side client supports for
 * this operation. This request may trigger the emission of
 * wl_data_source.action and wl_data_offer.action events if the compositor
 * needs to change the selected action.
 * 
 * This request can be called multiple times throughout the
 * drag-and-drop operation, typically in response to wl_data_device.enter
 * or wl_data_device.motion events.
 * 
 * This request determines the final result of the drag-and-drop
 * operation. If the end result is that no action is accepted,
 * the drag source will receive wl_data_source.cancelled.
 * 
 * The dnd_actions argument must contain only values expressed in the
 * wl_data_device_manager.dnd_actions enum, and the preferred_action
 * argument must only contain one of those values set, otherwise it
 * will result in a protocol error.
 * 
 * While managing an "ask" action, the destination drag-and-drop client
 * may perform further wl_data_offer.receive requests, and is expected
 * to perform one last wl_data_offer.set_actions request with a preferred
 * action other than "ask" (and optionally wl_data_offer.accept) before
 * requesting wl_data_offer.finish, in order to convey the action selected
 * by the user. If the preferred action is not in the
 * wl_data_offer.source_actions mask, an error will be raised.
 * 
 * If the "ask" action is dismissed (e.g. user cancellation), the client
 * is expected to perform wl_data_offer.destroy right away.
 * 
 * This request can only be made on drag-and-drop offers, a protocol error
 * will be raised otherwise.
 */
data_offer_set_actions :: #force_inline proc(
    data_offer: ^Data_Offer,
    /*
     * actions supported by the destination client
     */
    dnd_actions: Data_Device_Manager_Dnd_Action_Flags,
    /*
     * action preferred by the destination client
     */
    preferred_action: Data_Device_Manager_Dnd_Action_Flags,
) {
    proxy_marshal_flags(
        cast(^Proxy)data_offer,
        DATA_OFFER_SET_ACTIONS,
        nil,
        1,
        {},
        dnd_actions,
        preferred_action,
    )
}


Data_Source_Error :: enum {
    /*
     * action mask contains invalid values
     */
    Invalid_Action_Mask = 0,
    /*
     * source doesn't accept this request
     */
    Invalid_Source = 1,
}

Data_Source_Listener :: struct{
    /*
     * a target accepts an offered mime type
     * Sent when a target accepts pointer_focus or motion events.  If
     * a target does not accept any of the offered types, type is NULL.
     * 
     * Used for feedback during drag-and-drop.
     */
    target: proc(
        data: rawptr,
        data_source: ^Data_Source,
        /*
         * mime type accepted by the target
         */
        mime_type: cstring,
    ),

    /*
     * send the data
     * Request for data from the client.  Send the data as the
     * specified mime type over the passed file descriptor, then
     * close it.
     */
    send: proc(
        data: rawptr,
        data_source: ^Data_Source,
        /*
         * mime type for the data
         */
        mime_type: cstring,
        /*
         * file descriptor for the data
         */
        fd: i32,
    ),

    /*
     * selection was cancelled
     * This data source is no longer valid. There are several reasons why
     * this could happen:
     * 
     * - The data source has been replaced by another data source.
     * - The drag-and-drop operation was performed, but the drop destination
     * did not accept any of the mime types offered through
     * wl_data_source.target.
     * - The drag-and-drop operation was performed, but the drop destination
     * did not select any of the actions present in the mask offered through
     * wl_data_source.action.
     * - The drag-and-drop operation was performed but didn't happen over a
     * surface.
     * - The compositor cancelled the drag-and-drop operation (e.g. compositor
     * dependent timeouts to avoid stale drag-and-drop transfers).
     * 
     * The client should clean up and destroy this data source.
     * 
     * For objects of version 2 or older, wl_data_source.cancelled will
     * only be emitted if the data source was replaced by another data
     * source.
     */
    cancelled: proc(
        data: rawptr,
        data_source: ^Data_Source,
    ),

    /*
     * the drag-and-drop operation physically finished
     * The user performed the drop action. This event does not indicate
     * acceptance, wl_data_source.cancelled may still be emitted afterwards
     * if the drop destination does not accept any mime type.
     * 
     * However, this event might however not be received if the compositor
     * cancelled the drag-and-drop operation before this event could happen.
     * 
     * Note that the data_source may still be used in the future and should
     * not be destroyed here.
     */
    dnd_drop_performed: proc(
        data: rawptr,
        data_source: ^Data_Source,
    ),

    /*
     * the drag-and-drop operation concluded
     * The drop destination finished interoperating with this data
     * source, so the client is now free to destroy this data source and
     * free all associated data.
     * 
     * If the action used to perform the operation was "move", the
     * source can now delete the transferred data.
     */
    dnd_finished: proc(
        data: rawptr,
        data_source: ^Data_Source,
    ),

    /*
     * notify the selected action
     * This event indicates the action selected by the compositor after
     * matching the source/destination side actions. Only one action (or
     * none) will be offered here.
     * 
     * This event can be emitted multiple times during the drag-and-drop
     * operation, mainly in response to destination side changes through
     * wl_data_offer.set_actions, and as the data device enters/leaves
     * surfaces.
     * 
     * It is only possible to receive this event after
     * wl_data_source.dnd_drop_performed if the drag-and-drop operation
     * ended in an "ask" action, in which case the final wl_data_source.action
     * event will happen immediately before wl_data_source.dnd_finished.
     * 
     * Compositors may also change the selected action on the fly, mainly
     * in response to keyboard modifier changes during the drag-and-drop
     * operation.
     * 
     * The most recent action received is always the valid one. The chosen
     * action may change alongside negotiation (e.g. an "ask" action can turn
     * into a "move" operation), so the effects of the final action must
     * always be applied in wl_data_offer.dnd_finished.
     * 
     * Clients can trigger cursor surface changes from this point, so
     * they reflect the current action.
     */
    action: proc(
        data: rawptr,
        data_source: ^Data_Source,
        /*
         * action selected by the compositor
         */
        dnd_action: Data_Device_Manager_Dnd_Action_Flags,
    ),

}

data_source_add_listener :: #force_inline proc(data_source: ^Data_Source, listener: ^Data_Source_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)data_source,
        rawptr(listener),
        data
    )
}
data_source_set_user_data :: #force_inline proc(data_source: ^Data_Source, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)data_source,
        user_data
    )
}
data_source_get_user_data :: #force_inline proc(data_source: ^Data_Source) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)data_source)
}
data_source_get_version :: #force_inline proc(data_source: ^Data_Source) -> u32 {
    return proxy_get_version(cast(^Proxy)data_source);
}

DATA_SOURCE_OFFER :: 0
DATA_SOURCE_DESTROY :: 1
DATA_SOURCE_SET_ACTIONS :: 2

/*
 * add an offered mime type
 * This request adds a mime type to the set of mime types
 * advertised to targets.  Can be called several times to offer
 * multiple types.
 */
data_source_offer :: #force_inline proc(
    data_source: ^Data_Source,
    /*
     * mime type offered by the data source
     */
    mime_type: cstring,
) {
    proxy_marshal_flags(
        cast(^Proxy)data_source,
        DATA_SOURCE_OFFER,
        nil,
        1,
        {},
        mime_type,
    )
}

/*
 * destroy the data source
 * Destroy the data source.
 */
data_source_destroy :: #force_inline proc(
    data_source: ^Data_Source,
) {
    proxy_marshal_flags(
        cast(^Proxy)data_source,
        DATA_SOURCE_DESTROY,
        nil,
        1,
        {},
    )
}

/*
 * set the available drag-and-drop actions
 * Sets the actions that the source side client supports for this
 * operation. This request may trigger wl_data_source.action and
 * wl_data_offer.action events if the compositor needs to change the
 * selected action.
 * 
 * The dnd_actions argument must contain only values expressed in the
 * wl_data_device_manager.dnd_actions enum, otherwise it will result
 * in a protocol error.
 * 
 * This request must be made once only, and can only be made on sources
 * used in drag-and-drop, so it must be performed before
 * wl_data_device.start_drag. Attempting to use the source other than
 * for drag-and-drop will raise a protocol error.
 */
data_source_set_actions :: #force_inline proc(
    data_source: ^Data_Source,
    /*
     * actions supported by the data source
     */
    dnd_actions: Data_Device_Manager_Dnd_Action_Flags,
) {
    proxy_marshal_flags(
        cast(^Proxy)data_source,
        DATA_SOURCE_SET_ACTIONS,
        nil,
        1,
        {},
        dnd_actions,
    )
}


Data_Device_Error :: enum {
    /*
     * given wl_surface has another role
     */
    Role = 0,
    /*
     * source has already been used
     */
    Used_Source = 1,
}

Data_Device_Listener :: struct{
    /*
     * introduce a new wl_data_offer
     * The data_offer event introduces a new wl_data_offer object,
     * which will subsequently be used in either the
     * data_device.enter event (for drag-and-drop) or the
     * data_device.selection event (for selections).  Immediately
     * following the data_device.data_offer event, the new data_offer
     * object will send out data_offer.offer events to describe the
     * mime types it offers.
     */
    data_offer: proc(
        data: rawptr,
        data_device: ^Data_Device,
        /*
         * the new data_offer object
         */
        id: ^Data_Offer,
    ),

    /*
     * initiate drag-and-drop session
     * This event is sent when an active drag-and-drop pointer enters
     * a surface owned by the client.  The position of the pointer at
     * enter time is provided by the x and y arguments, in surface-local
     * coordinates.
     */
    enter: proc(
        data: rawptr,
        data_device: ^Data_Device,
        /*
         * serial number of the enter event
         */
        serial: u32,
        /*
         * client surface entered
         */
        surface: ^Surface,
        /*
         * surface-local x coordinate
         */
        x: Fixed,
        /*
         * surface-local y coordinate
         */
        y: Fixed,
        /*
         * source data_offer object
         */
        id: ^Data_Offer,
    ),

    /*
     * end drag-and-drop session
     * This event is sent when the drag-and-drop pointer leaves the
     * surface and the session ends.  The client must destroy the
     * wl_data_offer introduced at enter time at this point.
     */
    leave: proc(
        data: rawptr,
        data_device: ^Data_Device,
    ),

    /*
     * drag-and-drop session motion
     * This event is sent when the drag-and-drop pointer moves within
     * the currently focused surface. The new position of the pointer
     * is provided by the x and y arguments, in surface-local
     * coordinates.
     */
    motion: proc(
        data: rawptr,
        data_device: ^Data_Device,
        /*
         * timestamp with millisecond granularity
         */
        time: u32,
        /*
         * surface-local x coordinate
         */
        x: Fixed,
        /*
         * surface-local y coordinate
         */
        y: Fixed,
    ),

    /*
     * end drag-and-drop session successfully
     * The event is sent when a drag-and-drop operation is ended
     * because the implicit grab is removed.
     * 
     * The drag-and-drop destination is expected to honor the last action
     * received through wl_data_offer.action, if the resulting action is
     * "copy" or "move", the destination can still perform
     * wl_data_offer.receive requests, and is expected to end all
     * transfers with a wl_data_offer.finish request.
     * 
     * If the resulting action is "ask", the action will not be considered
     * final. The drag-and-drop destination is expected to perform one last
     * wl_data_offer.set_actions request, or wl_data_offer.destroy in order
     * to cancel the operation.
     */
    drop: proc(
        data: rawptr,
        data_device: ^Data_Device,
    ),

    /*
     * advertise new selection
     * The selection event is sent out to notify the client of a new
     * wl_data_offer for the selection for this device.  The
     * data_device.data_offer and the data_offer.offer events are
     * sent out immediately before this event to introduce the data
     * offer object.  The selection event is sent to a client
     * immediately before receiving keyboard focus and when a new
     * selection is set while the client has keyboard focus.  The
     * data_offer is valid until a new data_offer or NULL is received
     * or until the client loses keyboard focus.  Switching surface with
     * keyboard focus within the same client doesn't mean a new selection
     * will be sent.  The client must destroy the previous selection
     * data_offer, if any, upon receiving this event.
     */
    selection: proc(
        data: rawptr,
        data_device: ^Data_Device,
        /*
         * selection data_offer object
         */
        id: ^Data_Offer,
    ),

}

data_device_add_listener :: #force_inline proc(data_device: ^Data_Device, listener: ^Data_Device_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)data_device,
        rawptr(listener),
        data
    )
}
data_device_set_user_data :: #force_inline proc(data_device: ^Data_Device, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)data_device,
        user_data
    )
}
data_device_get_user_data :: #force_inline proc(data_device: ^Data_Device) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)data_device)
}
data_device_get_version :: #force_inline proc(data_device: ^Data_Device) -> u32 {
    return proxy_get_version(cast(^Proxy)data_device);
}

DATA_DEVICE_START_DRAG :: 0
DATA_DEVICE_SET_SELECTION :: 1
DATA_DEVICE_RELEASE :: 2

/*
 * start drag-and-drop operation
 * This request asks the compositor to start a drag-and-drop
 * operation on behalf of the client.
 * 
 * The source argument is the data source that provides the data
 * for the eventual data transfer. If source is NULL, enter, leave
 * and motion events are sent only to the client that initiated the
 * drag and the client is expected to handle the data passing
 * internally. If source is destroyed, the drag-and-drop session will be
 * cancelled.
 * 
 * The origin surface is the surface where the drag originates and
 * the client must have an active implicit grab that matches the
 * serial.
 * 
 * The icon surface is an optional (can be NULL) surface that
 * provides an icon to be moved around with the cursor.  Initially,
 * the top-left corner of the icon surface is placed at the cursor
 * hotspot, but subsequent wl_surface.offset requests can move the
 * relative position. Attach requests must be confirmed with
 * wl_surface.commit as usual. The icon surface is given the role of
 * a drag-and-drop icon. If the icon surface already has another role,
 * it raises a protocol error.
 * 
 * The input region is ignored for wl_surfaces with the role of a
 * drag-and-drop icon.
 * 
 * The given source may not be used in any further set_selection or
 * start_drag requests. Attempting to reuse a previously-used source
 * may send a used_source error.
 */
data_device_start_drag :: #force_inline proc(
    data_device: ^Data_Device,
    /*
     * data source for the eventual transfer
     */
    source: ^Data_Source,
    /*
     * surface where the drag originates
     */
    origin: ^Surface,
    /*
     * drag-and-drop icon surface
     */
    icon: ^Surface,
    /*
     * serial number of the implicit grab on the origin
     */
    serial: u32,
) {
    proxy_marshal_flags(
        cast(^Proxy)data_device,
        DATA_DEVICE_START_DRAG,
        nil,
        1,
        {},
        source,
        origin,
        icon,
        serial,
    )
}

/*
 * copy data to the selection
 * This request asks the compositor to set the selection
 * to the data from the source on behalf of the client.
 * 
 * To unset the selection, set the source to NULL.
 * 
 * The given source may not be used in any further set_selection or
 * start_drag requests. Attempting to reuse a previously-used source
 * may send a used_source error.
 */
data_device_set_selection :: #force_inline proc(
    data_device: ^Data_Device,
    /*
     * data source for the selection
     */
    source: ^Data_Source,
    /*
     * serial number of the event that triggered this request
     */
    serial: u32,
) {
    proxy_marshal_flags(
        cast(^Proxy)data_device,
        DATA_DEVICE_SET_SELECTION,
        nil,
        1,
        {},
        source,
        serial,
    )
}

/*
 * destroy data device
 * This request destroys the data device.
 */
data_device_release :: #force_inline proc(
    data_device: ^Data_Device,
) {
    proxy_marshal_flags(
        cast(^Proxy)data_device,
        DATA_DEVICE_RELEASE,
        nil,
        1,
        {},
    )
}


/*
 * drag and drop actions
 * This is a bitmask of the available/preferred actions in a
 * drag-and-drop operation.
 * 
 * In the compositor, the selected action is a result of matching the
 * actions offered by the source and destination sides.  "action" events
 * with a "none" action will be sent to both source and destination if
 * there is no match. All further checks will effectively happen on
 * (source actions ∩ destination actions).
 * 
 * In addition, compositors may also pick different actions in
 * reaction to key modifiers being pressed. One common design that
 * is used in major toolkits (and the behavior recommended for
 * compositors) is:
 * 
 * - If no modifiers are pressed, the first match (in bit order)
 * will be used.
 * - Pressing Shift selects "move", if enabled in the mask.
 * - Pressing Control selects "copy", if enabled in the mask.
 * 
 * Behavior beyond that is considered implementation-dependent.
 * Compositors may for example bind other modifiers (like Alt/Meta)
 * or drags initiated with other buttons than BTN_LEFT to specific
 * actions (e.g. "ask").
 */
Data_Device_Manager_Dnd_Action_Flag :: enum {
    /*
     * no action
     */
    None = 0,
    /*
     * copy action
     */
    Copy = 1,
    /*
     * move action
     */
    Move = 2,
    /*
     * ask action
     */
    Ask = 4,
}
Data_Device_Manager_Dnd_Action_Flags :: bit_set[Data_Device_Manager_Dnd_Action_Flag]


data_device_manager_set_user_data :: #force_inline proc(data_device_manager: ^Data_Device_Manager, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)data_device_manager,
        user_data
    )
}
data_device_manager_get_user_data :: #force_inline proc(data_device_manager: ^Data_Device_Manager) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)data_device_manager)
}
data_device_manager_get_version :: #force_inline proc(data_device_manager: ^Data_Device_Manager) -> u32 {
    return proxy_get_version(cast(^Proxy)data_device_manager);
}

DATA_DEVICE_MANAGER_CREATE_DATA_SOURCE :: 0
DATA_DEVICE_MANAGER_GET_DATA_DEVICE :: 1

/*
 * create a new data source
 * Create a new data source.
 */
data_device_manager_create_data_source :: #force_inline proc(
    data_device_manager: ^Data_Device_Manager,
) -> ^Data_Source {
    return cast(^Data_Source)proxy_marshal_flags(
        cast(^Proxy)data_device_manager,
        DATA_DEVICE_MANAGER_CREATE_DATA_SOURCE,
        &data_source_interface,
        proxy_get_version(cast(^Proxy)data_device_manager),
        {},
        nil,
    )
}

/*
 * create a new data device
 * Create a new data device for a given seat.
 */
data_device_manager_get_data_device :: #force_inline proc(
    data_device_manager: ^Data_Device_Manager,
    /*
     * seat associated with the data device
     */
    seat: ^Seat,
) -> ^Data_Device {
    return cast(^Data_Device)proxy_marshal_flags(
        cast(^Proxy)data_device_manager,
        DATA_DEVICE_MANAGER_GET_DATA_DEVICE,
        &data_device_interface,
        proxy_get_version(cast(^Proxy)data_device_manager),
        {},
        nil,
        seat,
    )
}


Shell_Error :: enum {
    /*
     * given wl_surface has another role
     */
    Role = 0,
}


shell_set_user_data :: #force_inline proc(shell: ^Shell, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)shell,
        user_data
    )
}
shell_get_user_data :: #force_inline proc(shell: ^Shell) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)shell)
}
shell_get_version :: #force_inline proc(shell: ^Shell) -> u32 {
    return proxy_get_version(cast(^Proxy)shell);
}

SHELL_GET_SHELL_SURFACE :: 0

/*
 * create a shell surface from a surface
 * Create a shell surface for an existing surface. This gives
 * the wl_surface the role of a shell surface. If the wl_surface
 * already has another role, it raises a protocol error.
 * 
 * Only one shell surface can be associated with a given surface.
 */
shell_get_shell_surface :: #force_inline proc(
    shell: ^Shell,
    /*
     * surface to be given the shell surface role
     */
    surface: ^Surface,
) -> ^Shell_Surface {
    return cast(^Shell_Surface)proxy_marshal_flags(
        cast(^Proxy)shell,
        SHELL_GET_SHELL_SURFACE,
        &shell_surface_interface,
        proxy_get_version(cast(^Proxy)shell),
        {},
        nil,
        surface,
    )
}


/*
 * edge values for resizing
 * These values are used to indicate which edge of a surface
 * is being dragged in a resize operation. The server may
 * use this information to adapt its behavior, e.g. choose
 * an appropriate cursor image.
 */
Shell_Surface_Resize_Flag :: enum {
    /*
     * no edge
     */
    None = 0,
    /*
     * top edge
     */
    Top = 1,
    /*
     * bottom edge
     */
    Bottom = 2,
    /*
     * left edge
     */
    Left = 4,
    /*
     * top and left edges
     */
    Top_Left = 5,
    /*
     * bottom and left edges
     */
    Bottom_Left = 6,
    /*
     * right edge
     */
    Right = 8,
    /*
     * top and right edges
     */
    Top_Right = 9,
    /*
     * bottom and right edges
     */
    Bottom_Right = 10,
}
Shell_Surface_Resize_Flags :: bit_set[Shell_Surface_Resize_Flag]

/*
 * details of transient behaviour
 * These flags specify details of the expected behaviour
 * of transient surfaces. Used in the set_transient request.
 */
Shell_Surface_Transient_Flag :: enum {
    /*
     * do not set keyboard focus
     */
    Inactive = 1,
}
Shell_Surface_Transient_Flags :: bit_set[Shell_Surface_Transient_Flag]

/*
 * different method to set the surface fullscreen
 * Hints to indicate to the compositor how to deal with a conflict
 * between the dimensions of the surface and the dimensions of the
 * output. The compositor is free to ignore this parameter.
 */
Shell_Surface_Fullscreen_Method :: enum {
    /*
     * no preference, apply default policy
     */
    Default = 0,
    /*
     * scale, preserve the surface's aspect ratio and center on output
     */
    Scale = 1,
    /*
     * switch output mode to the smallest mode that can fit the surface, add black borders to compensate size mismatch
     */
    Driver = 2,
    /*
     * no upscaling, center on output and add black borders to compensate size mismatch
     */
    Fill = 3,
}

Shell_Surface_Listener :: struct{
    /*
     * ping client
     * Ping a client to check if it is receiving events and sending
     * requests. A client is expected to reply with a pong request.
     */
    ping: proc(
        data: rawptr,
        shell_surface: ^Shell_Surface,
        /*
         * serial number of the ping
         */
        serial: u32,
    ),

    /*
     * suggest resize
     * The configure event asks the client to resize its surface.
     * 
     * The size is a hint, in the sense that the client is free to
     * ignore it if it doesn't resize, pick a smaller size (to
     * satisfy aspect ratio or resize in steps of NxM pixels).
     * 
     * The edges parameter provides a hint about how the surface
     * was resized. The client may use this information to decide
     * how to adjust its content to the new size (e.g. a scrolling
     * area might adjust its content position to leave the viewable
     * content unmoved).
     * 
     * The client is free to dismiss all but the last configure
     * event it received.
     * 
     * The width and height arguments specify the size of the window
     * in surface-local coordinates.
     */
    configure: proc(
        data: rawptr,
        shell_surface: ^Shell_Surface,
        /*
         * how the surface was resized
         */
        edges: Shell_Surface_Resize_Flags,
        /*
         * new width of the surface
         */
        width: i32,
        /*
         * new height of the surface
         */
        height: i32,
    ),

    /*
     * popup interaction is done
     * The popup_done event is sent out when a popup grab is broken,
     * that is, when the user clicks a surface that doesn't belong
     * to the client owning the popup surface.
     */
    popup_done: proc(
        data: rawptr,
        shell_surface: ^Shell_Surface,
    ),

}

shell_surface_add_listener :: #force_inline proc(shell_surface: ^Shell_Surface, listener: ^Shell_Surface_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)shell_surface,
        rawptr(listener),
        data
    )
}
shell_surface_set_user_data :: #force_inline proc(shell_surface: ^Shell_Surface, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)shell_surface,
        user_data
    )
}
shell_surface_get_user_data :: #force_inline proc(shell_surface: ^Shell_Surface) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)shell_surface)
}
shell_surface_get_version :: #force_inline proc(shell_surface: ^Shell_Surface) -> u32 {
    return proxy_get_version(cast(^Proxy)shell_surface);
}

SHELL_SURFACE_PONG :: 0
SHELL_SURFACE_MOVE :: 1
SHELL_SURFACE_RESIZE :: 2
SHELL_SURFACE_SET_TOPLEVEL :: 3
SHELL_SURFACE_SET_TRANSIENT :: 4
SHELL_SURFACE_SET_FULLSCREEN :: 5
SHELL_SURFACE_SET_POPUP :: 6
SHELL_SURFACE_SET_MAXIMIZED :: 7
SHELL_SURFACE_SET_TITLE :: 8
SHELL_SURFACE_SET_CLASS :: 9

/*
 * respond to a ping event
 * A client must respond to a ping event with a pong request or
 * the client may be deemed unresponsive.
 */
shell_surface_pong :: #force_inline proc(
    shell_surface: ^Shell_Surface,
    /*
     * serial number of the ping event
     */
    serial: u32,
) {
    proxy_marshal_flags(
        cast(^Proxy)shell_surface,
        SHELL_SURFACE_PONG,
        nil,
        1,
        {},
        serial,
    )
}

/*
 * start an interactive move
 * Start a pointer-driven move of the surface.
 * 
 * This request must be used in response to a button press event.
 * The server may ignore move requests depending on the state of
 * the surface (e.g. fullscreen or maximized).
 */
shell_surface_move :: #force_inline proc(
    shell_surface: ^Shell_Surface,
    /*
     * seat whose pointer is used
     */
    seat: ^Seat,
    /*
     * serial number of the implicit grab on the pointer
     */
    serial: u32,
) {
    proxy_marshal_flags(
        cast(^Proxy)shell_surface,
        SHELL_SURFACE_MOVE,
        nil,
        1,
        {},
        seat,
        serial,
    )
}

/*
 * start an interactive resize
 * Start a pointer-driven resizing of the surface.
 * 
 * This request must be used in response to a button press event.
 * The server may ignore resize requests depending on the state of
 * the surface (e.g. fullscreen or maximized).
 */
shell_surface_resize :: #force_inline proc(
    shell_surface: ^Shell_Surface,
    /*
     * seat whose pointer is used
     */
    seat: ^Seat,
    /*
     * serial number of the implicit grab on the pointer
     */
    serial: u32,
    /*
     * which edge or corner is being dragged
     */
    edges: Shell_Surface_Resize_Flags,
) {
    proxy_marshal_flags(
        cast(^Proxy)shell_surface,
        SHELL_SURFACE_RESIZE,
        nil,
        1,
        {},
        seat,
        serial,
        edges,
    )
}

/*
 * make the surface a toplevel surface
 * Map the surface as a toplevel surface.
 * 
 * A toplevel surface is not fullscreen, maximized or transient.
 */
shell_surface_set_toplevel :: #force_inline proc(
    shell_surface: ^Shell_Surface,
) {
    proxy_marshal_flags(
        cast(^Proxy)shell_surface,
        SHELL_SURFACE_SET_TOPLEVEL,
        nil,
        1,
        {},
    )
}

/*
 * make the surface a transient surface
 * Map the surface relative to an existing surface.
 * 
 * The x and y arguments specify the location of the upper left
 * corner of the surface relative to the upper left corner of the
 * parent surface, in surface-local coordinates.
 * 
 * The flags argument controls details of the transient behaviour.
 */
shell_surface_set_transient :: #force_inline proc(
    shell_surface: ^Shell_Surface,
    /*
     * parent surface
     */
    parent: ^Surface,
    /*
     * surface-local x coordinate
     */
    x: i32,
    /*
     * surface-local y coordinate
     */
    y: i32,
    /*
     * transient surface behavior
     */
    flags: Shell_Surface_Transient_Flags,
) {
    proxy_marshal_flags(
        cast(^Proxy)shell_surface,
        SHELL_SURFACE_SET_TRANSIENT,
        nil,
        1,
        {},
        parent,
        x,
        y,
        flags,
    )
}

/*
 * make the surface a fullscreen surface
 * Map the surface as a fullscreen surface.
 * 
 * If an output parameter is given then the surface will be made
 * fullscreen on that output. If the client does not specify the
 * output then the compositor will apply its policy - usually
 * choosing the output on which the surface has the biggest surface
 * area.
 * 
 * The client may specify a method to resolve a size conflict
 * between the output size and the surface size - this is provided
 * through the method parameter.
 * 
 * The framerate parameter is used only when the method is set
 * to "driver", to indicate the preferred framerate. A value of 0
 * indicates that the client does not care about framerate.  The
 * framerate is specified in mHz, that is framerate of 60000 is 60Hz.
 * 
 * A method of "scale" or "driver" implies a scaling operation of
 * the surface, either via a direct scaling operation or a change of
 * the output mode. This will override any kind of output scaling, so
 * that mapping a surface with a buffer size equal to the mode can
 * fill the screen independent of buffer_scale.
 * 
 * A method of "fill" means we don't scale up the buffer, however
 * any output scale is applied. This means that you may run into
 * an edge case where the application maps a buffer with the same
 * size of the output mode but buffer_scale 1 (thus making a
 * surface larger than the output). In this case it is allowed to
 * downscale the results to fit the screen.
 * 
 * The compositor must reply to this request with a configure event
 * with the dimensions for the output on which the surface will
 * be made fullscreen.
 */
shell_surface_set_fullscreen :: #force_inline proc(
    shell_surface: ^Shell_Surface,
    /*
     * method for resolving size conflict
     */
    method: Shell_Surface_Fullscreen_Method,
    /*
     * framerate in mHz
     */
    framerate: u32,
    /*
     * output on which the surface is to be fullscreen
     */
    output: ^Output,
) {
    proxy_marshal_flags(
        cast(^Proxy)shell_surface,
        SHELL_SURFACE_SET_FULLSCREEN,
        nil,
        1,
        {},
        method,
        framerate,
        output,
    )
}

/*
 * make the surface a popup surface
 * Map the surface as a popup.
 * 
 * A popup surface is a transient surface with an added pointer
 * grab.
 * 
 * An existing implicit grab will be changed to owner-events mode,
 * and the popup grab will continue after the implicit grab ends
 * (i.e. releasing the mouse button does not cause the popup to
 * be unmapped).
 * 
 * The popup grab continues until the window is destroyed or a
 * mouse button is pressed in any other client's window. A click
 * in any of the client's surfaces is reported as normal, however,
 * clicks in other clients' surfaces will be discarded and trigger
 * the callback.
 * 
 * The x and y arguments specify the location of the upper left
 * corner of the surface relative to the upper left corner of the
 * parent surface, in surface-local coordinates.
 */
shell_surface_set_popup :: #force_inline proc(
    shell_surface: ^Shell_Surface,
    /*
     * seat whose pointer is used
     */
    seat: ^Seat,
    /*
     * serial number of the implicit grab on the pointer
     */
    serial: u32,
    /*
     * parent surface
     */
    parent: ^Surface,
    /*
     * surface-local x coordinate
     */
    x: i32,
    /*
     * surface-local y coordinate
     */
    y: i32,
    /*
     * transient surface behavior
     */
    flags: Shell_Surface_Transient_Flags,
) {
    proxy_marshal_flags(
        cast(^Proxy)shell_surface,
        SHELL_SURFACE_SET_POPUP,
        nil,
        1,
        {},
        seat,
        serial,
        parent,
        x,
        y,
        flags,
    )
}

/*
 * make the surface a maximized surface
 * Map the surface as a maximized surface.
 * 
 * If an output parameter is given then the surface will be
 * maximized on that output. If the client does not specify the
 * output then the compositor will apply its policy - usually
 * choosing the output on which the surface has the biggest surface
 * area.
 * 
 * The compositor will reply with a configure event telling
 * the expected new surface size. The operation is completed
 * on the next buffer attach to this surface.
 * 
 * A maximized surface typically fills the entire output it is
 * bound to, except for desktop elements such as panels. This is
 * the main difference between a maximized shell surface and a
 * fullscreen shell surface.
 * 
 * The details depend on the compositor implementation.
 */
shell_surface_set_maximized :: #force_inline proc(
    shell_surface: ^Shell_Surface,
    /*
     * output on which the surface is to be maximized
     */
    output: ^Output,
) {
    proxy_marshal_flags(
        cast(^Proxy)shell_surface,
        SHELL_SURFACE_SET_MAXIMIZED,
        nil,
        1,
        {},
        output,
    )
}

/*
 * set surface title
 * Set a short title for the surface.
 * 
 * This string may be used to identify the surface in a task bar,
 * window list, or other user interface elements provided by the
 * compositor.
 * 
 * The string must be encoded in UTF-8.
 */
shell_surface_set_title :: #force_inline proc(
    shell_surface: ^Shell_Surface,
    /*
     * surface title
     */
    title: cstring,
) {
    proxy_marshal_flags(
        cast(^Proxy)shell_surface,
        SHELL_SURFACE_SET_TITLE,
        nil,
        1,
        {},
        title,
    )
}

/*
 * set surface class
 * Set a class for the surface.
 * 
 * The surface class identifies the general class of applications
 * to which the surface belongs. A common convention is to use the
 * file name (or the full path if it is a non-standard location) of
 * the application's .desktop file as the class.
 */
shell_surface_set_class :: #force_inline proc(
    shell_surface: ^Shell_Surface,
    /*
     * surface class
     */
    class_: cstring,
) {
    proxy_marshal_flags(
        cast(^Proxy)shell_surface,
        SHELL_SURFACE_SET_CLASS,
        nil,
        1,
        {},
        class_,
    )
}


/*
 * wl_surface error values
 * These errors can be emitted in response to wl_surface requests.
 */
Surface_Error :: enum {
    /*
     * buffer scale value is invalid
     */
    Invalid_Scale = 0,
    /*
     * buffer transform value is invalid
     */
    Invalid_Transform = 1,
    /*
     * buffer size is invalid
     */
    Invalid_Size = 2,
    /*
     * buffer offset is invalid
     */
    Invalid_Offset = 3,
    /*
     * surface was destroyed before its role object
     */
    Defunct_Role_Object = 4,
}

Surface_Listener :: struct{
    /*
     * surface enters an output
     * This is emitted whenever a surface's creation, movement, or resizing
     * results in some part of it being within the scanout region of an
     * output.
     * 
     * Note that a surface may be overlapping with zero or more outputs.
     */
    enter: proc(
        data: rawptr,
        surface: ^Surface,
        /*
         * output entered by the surface
         */
        output: ^Output,
    ),

    /*
     * surface leaves an output
     * This is emitted whenever a surface's creation, movement, or resizing
     * results in it no longer having any part of it within the scanout region
     * of an output.
     * 
     * Clients should not use the number of outputs the surface is on for frame
     * throttling purposes. The surface might be hidden even if no leave event
     * has been sent, and the compositor might expect new surface content
     * updates even if no enter event has been sent. The frame event should be
     * used instead.
     */
    leave: proc(
        data: rawptr,
        surface: ^Surface,
        /*
         * output left by the surface
         */
        output: ^Output,
    ),

    /*
     * preferred buffer scale for the surface
     * This event indicates the preferred buffer scale for this surface. It is
     * sent whenever the compositor's preference changes.
     * 
     * Before receiving this event the preferred buffer scale for this surface
     * is 1.
     * 
     * It is intended that scaling aware clients use this event to scale their
     * content and use wl_surface.set_buffer_scale to indicate the scale they
     * have rendered with. This allows clients to supply a higher detail
     * buffer.
     * 
     * The compositor shall emit a scale value greater than 0.
     */
    preferred_buffer_scale: proc(
        data: rawptr,
        surface: ^Surface,
        /*
         * preferred scaling factor
         */
        factor: i32,
    ),

    /*
     * preferred buffer transform for the surface
     * This event indicates the preferred buffer transform for this surface.
     * It is sent whenever the compositor's preference changes.
     * 
     * Before receiving this event the preferred buffer transform for this
     * surface is normal.
     * 
     * Applying this transformation to the surface buffer contents and using
     * wl_surface.set_buffer_transform might allow the compositor to use the
     * surface buffer more efficiently.
     */
    preferred_buffer_transform: proc(
        data: rawptr,
        surface: ^Surface,
        /*
         * preferred transform
         */
        transform: Output_Transform,
    ),

}

surface_add_listener :: #force_inline proc(surface: ^Surface, listener: ^Surface_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)surface,
        rawptr(listener),
        data
    )
}
surface_set_user_data :: #force_inline proc(surface: ^Surface, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)surface,
        user_data
    )
}
surface_get_user_data :: #force_inline proc(surface: ^Surface) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)surface)
}
surface_get_version :: #force_inline proc(surface: ^Surface) -> u32 {
    return proxy_get_version(cast(^Proxy)surface);
}

SURFACE_DESTROY :: 0
SURFACE_ATTACH :: 1
SURFACE_DAMAGE :: 2
SURFACE_FRAME :: 3
SURFACE_SET_OPAQUE_REGION :: 4
SURFACE_SET_INPUT_REGION :: 5
SURFACE_COMMIT :: 6
SURFACE_SET_BUFFER_TRANSFORM :: 7
SURFACE_SET_BUFFER_SCALE :: 8
SURFACE_DAMAGE_BUFFER :: 9
SURFACE_OFFSET :: 10

/*
 * delete surface
 * Deletes the surface and invalidates its object ID.
 */
surface_destroy :: #force_inline proc(
    surface: ^Surface,
) {
    proxy_marshal_flags(
        cast(^Proxy)surface,
        SURFACE_DESTROY,
        nil,
        1,
        {},
    )
}

/*
 * set the surface contents
 * Set a buffer as the content of this surface.
 * 
 * The new size of the surface is calculated based on the buffer
 * size transformed by the inverse buffer_transform and the
 * inverse buffer_scale. This means that at commit time the supplied
 * buffer size must be an integer multiple of the buffer_scale. If
 * that's not the case, an invalid_size error is sent.
 * 
 * The x and y arguments specify the location of the new pending
 * buffer's upper left corner, relative to the current buffer's upper
 * left corner, in surface-local coordinates. In other words, the
 * x and y, combined with the new surface size define in which
 * directions the surface's size changes. Setting anything other than 0
 * as x and y arguments is discouraged, and should instead be replaced
 * with using the separate wl_surface.offset request.
 * 
 * When the bound wl_surface version is 5 or higher, passing any
 * non-zero x or y is a protocol violation, and will result in an
 * 'invalid_offset' error being raised. The x and y arguments are ignored
 * and do not change the pending state. To achieve equivalent semantics,
 * use wl_surface.offset.
 * 
 * Surface contents are double-buffered state, see wl_surface.commit.
 * 
 * The initial surface contents are void; there is no content.
 * wl_surface.attach assigns the given wl_buffer as the pending
 * wl_buffer. wl_surface.commit makes the pending wl_buffer the new
 * surface contents, and the size of the surface becomes the size
 * calculated from the wl_buffer, as described above. After commit,
 * there is no pending buffer until the next attach.
 * 
 * Committing a pending wl_buffer allows the compositor to read the
 * pixels in the wl_buffer. The compositor may access the pixels at
 * any time after the wl_surface.commit request. When the compositor
 * will not access the pixels anymore, it will send the
 * wl_buffer.release event. Only after receiving wl_buffer.release,
 * the client may reuse the wl_buffer. A wl_buffer that has been
 * attached and then replaced by another attach instead of committed
 * will not receive a release event, and is not used by the
 * compositor.
 * 
 * If a pending wl_buffer has been committed to more than one wl_surface,
 * the delivery of wl_buffer.release events becomes undefined. A well
 * behaved client should not rely on wl_buffer.release events in this
 * case. Alternatively, a client could create multiple wl_buffer objects
 * from the same backing storage or use wp_linux_buffer_release.
 * 
 * Destroying the wl_buffer after wl_buffer.release does not change
 * the surface contents. Destroying the wl_buffer before wl_buffer.release
 * is allowed as long as the underlying buffer storage isn't re-used (this
 * can happen e.g. on client process termination). However, if the client
 * destroys the wl_buffer before receiving the wl_buffer.release event and
 * mutates the underlying buffer storage, the surface contents become
 * undefined immediately.
 * 
 * If wl_surface.attach is sent with a NULL wl_buffer, the
 * following wl_surface.commit will remove the surface content.
 * 
 * If a pending wl_buffer has been destroyed, the result is not specified.
 * Many compositors are known to remove the surface content on the following
 * wl_surface.commit, but this behaviour is not universal. Clients seeking to
 * maximise compatibility should not destroy pending buffers and should
 * ensure that they explicitly remove content from surfaces, even after
 * destroying buffers.
 */
surface_attach :: #force_inline proc(
    surface: ^Surface,
    /*
     * buffer of surface contents
     */
    buffer: ^Buffer,
    /*
     * surface-local x coordinate
     */
    x: i32,
    /*
     * surface-local y coordinate
     */
    y: i32,
) {
    proxy_marshal_flags(
        cast(^Proxy)surface,
        SURFACE_ATTACH,
        nil,
        1,
        {},
        buffer,
        x,
        y,
    )
}

/*
 * mark part of the surface damaged
 * This request is used to describe the regions where the pending
 * buffer is different from the current surface contents, and where
 * the surface therefore needs to be repainted. The compositor
 * ignores the parts of the damage that fall outside of the surface.
 * 
 * Damage is double-buffered state, see wl_surface.commit.
 * 
 * The damage rectangle is specified in surface-local coordinates,
 * where x and y specify the upper left corner of the damage rectangle.
 * 
 * The initial value for pending damage is empty: no damage.
 * wl_surface.damage adds pending damage: the new pending damage
 * is the union of old pending damage and the given rectangle.
 * 
 * wl_surface.commit assigns pending damage as the current damage,
 * and clears pending damage. The server will clear the current
 * damage as it repaints the surface.
 * 
 * Note! New clients should not use this request. Instead damage can be
 * posted with wl_surface.damage_buffer which uses buffer coordinates
 * instead of surface coordinates.
 */
surface_damage :: #force_inline proc(
    surface: ^Surface,
    /*
     * surface-local x coordinate
     */
    x: i32,
    /*
     * surface-local y coordinate
     */
    y: i32,
    /*
     * width of damage rectangle
     */
    width: i32,
    /*
     * height of damage rectangle
     */
    height: i32,
) {
    proxy_marshal_flags(
        cast(^Proxy)surface,
        SURFACE_DAMAGE,
        nil,
        1,
        {},
        x,
        y,
        width,
        height,
    )
}

/*
 * request a frame throttling hint
 * Request a notification when it is a good time to start drawing a new
 * frame, by creating a frame callback. This is useful for throttling
 * redrawing operations, and driving animations.
 * 
 * When a client is animating on a wl_surface, it can use the 'frame'
 * request to get notified when it is a good time to draw and commit the
 * next frame of animation. If the client commits an update earlier than
 * that, it is likely that some updates will not make it to the display,
 * and the client is wasting resources by drawing too often.
 * 
 * The frame request will take effect on the next wl_surface.commit.
 * The notification will only be posted for one frame unless
 * requested again. For a wl_surface, the notifications are posted in
 * the order the frame requests were committed.
 * 
 * The server must send the notifications so that a client
 * will not send excessive updates, while still allowing
 * the highest possible update rate for clients that wait for the reply
 * before drawing again. The server should give some time for the client
 * to draw and commit after sending the frame callback events to let it
 * hit the next output refresh.
 * 
 * A server should avoid signaling the frame callbacks if the
 * surface is not visible in any way, e.g. the surface is off-screen,
 * or completely obscured by other opaque surfaces.
 * 
 * The object returned by this request will be destroyed by the
 * compositor after the callback is fired and as such the client must not
 * attempt to use it after that point.
 * 
 * The callback_data passed in the callback is the current time, in
 * milliseconds, with an undefined base.
 */
surface_frame :: #force_inline proc(
    surface: ^Surface,
) -> ^Callback {
    return cast(^Callback)proxy_marshal_flags(
        cast(^Proxy)surface,
        SURFACE_FRAME,
        &callback_interface,
        proxy_get_version(cast(^Proxy)surface),
        {},
        nil,
    )
}

/*
 * set opaque region
 * This request sets the region of the surface that contains
 * opaque content.
 * 
 * The opaque region is an optimization hint for the compositor
 * that lets it optimize the redrawing of content behind opaque
 * regions.  Setting an opaque region is not required for correct
 * behaviour, but marking transparent content as opaque will result
 * in repaint artifacts.
 * 
 * The opaque region is specified in surface-local coordinates.
 * 
 * The compositor ignores the parts of the opaque region that fall
 * outside of the surface.
 * 
 * Opaque region is double-buffered state, see wl_surface.commit.
 * 
 * wl_surface.set_opaque_region changes the pending opaque region.
 * wl_surface.commit copies the pending region to the current region.
 * Otherwise, the pending and current regions are never changed.
 * 
 * The initial value for an opaque region is empty. Setting the pending
 * opaque region has copy semantics, and the wl_region object can be
 * destroyed immediately. A NULL wl_region causes the pending opaque
 * region to be set to empty.
 */
surface_set_opaque_region :: #force_inline proc(
    surface: ^Surface,
    /*
     * opaque region of the surface
     */
    region: ^Region,
) {
    proxy_marshal_flags(
        cast(^Proxy)surface,
        SURFACE_SET_OPAQUE_REGION,
        nil,
        1,
        {},
        region,
    )
}

/*
 * set input region
 * This request sets the region of the surface that can receive
 * pointer and touch events.
 * 
 * Input events happening outside of this region will try the next
 * surface in the server surface stack. The compositor ignores the
 * parts of the input region that fall outside of the surface.
 * 
 * The input region is specified in surface-local coordinates.
 * 
 * Input region is double-buffered state, see wl_surface.commit.
 * 
 * wl_surface.set_input_region changes the pending input region.
 * wl_surface.commit copies the pending region to the current region.
 * Otherwise the pending and current regions are never changed,
 * except cursor and icon surfaces are special cases, see
 * wl_pointer.set_cursor and wl_data_device.start_drag.
 * 
 * The initial value for an input region is infinite. That means the
 * whole surface will accept input. Setting the pending input region
 * has copy semantics, and the wl_region object can be destroyed
 * immediately. A NULL wl_region causes the input region to be set
 * to infinite.
 */
surface_set_input_region :: #force_inline proc(
    surface: ^Surface,
    /*
     * input region of the surface
     */
    region: ^Region,
) {
    proxy_marshal_flags(
        cast(^Proxy)surface,
        SURFACE_SET_INPUT_REGION,
        nil,
        1,
        {},
        region,
    )
}

/*
 * commit pending surface state
 * Surface state (input, opaque, and damage regions, attached buffers,
 * etc.) is double-buffered. Protocol requests modify the pending state,
 * as opposed to the active state in use by the compositor.
 * 
 * A commit request atomically creates a content update from the pending
 * state, even if the pending state has not been touched. The content
 * update is placed in a queue until it becomes active. After commit, the
 * new pending state is as documented for each related request.
 * 
 * When the content update is applied, the wl_buffer is applied before all
 * other state. This means that all coordinates in double-buffered state
 * are relative to the newly attached wl_buffers, except for
 * wl_surface.attach itself. If there is no newly attached wl_buffer, the
 * coordinates are relative to the previous content update.
 * 
 * All requests that need a commit to become effective are documented
 * to affect double-buffered state.
 * 
 * Other interfaces may add further double-buffered surface state.
 */
surface_commit :: #force_inline proc(
    surface: ^Surface,
) {
    proxy_marshal_flags(
        cast(^Proxy)surface,
        SURFACE_COMMIT,
        nil,
        1,
        {},
    )
}

/*
 * sets the buffer transformation
 * This request sets the transformation that the client has already applied
 * to the content of the buffer. The accepted values for the transform
 * parameter are the values for wl_output.transform.
 * 
 * The compositor applies the inverse of this transformation whenever it
 * uses the buffer contents.
 * 
 * Buffer transform is double-buffered state, see wl_surface.commit.
 * 
 * A newly created surface has its buffer transformation set to normal.
 * 
 * wl_surface.set_buffer_transform changes the pending buffer
 * transformation. wl_surface.commit copies the pending buffer
 * transformation to the current one. Otherwise, the pending and current
 * values are never changed.
 * 
 * The purpose of this request is to allow clients to render content
 * according to the output transform, thus permitting the compositor to
 * use certain optimizations even if the display is rotated. Using
 * hardware overlays and scanning out a client buffer for fullscreen
 * surfaces are examples of such optimizations. Those optimizations are
 * highly dependent on the compositor implementation, so the use of this
 * request should be considered on a case-by-case basis.
 * 
 * Note that if the transform value includes 90 or 270 degree rotation,
 * the width of the buffer will become the surface height and the height
 * of the buffer will become the surface width.
 * 
 * If transform is not one of the values from the
 * wl_output.transform enum the invalid_transform protocol error
 * is raised.
 */
surface_set_buffer_transform :: #force_inline proc(
    surface: ^Surface,
    /*
     * transform for interpreting buffer contents
     */
    transform: Output_Transform,
) {
    proxy_marshal_flags(
        cast(^Proxy)surface,
        SURFACE_SET_BUFFER_TRANSFORM,
        nil,
        1,
        {},
        transform,
    )
}

/*
 * sets the buffer scaling factor
 * This request sets an optional scaling factor on how the compositor
 * interprets the contents of the buffer attached to the window.
 * 
 * Buffer scale is double-buffered state, see wl_surface.commit.
 * 
 * A newly created surface has its buffer scale set to 1.
 * 
 * wl_surface.set_buffer_scale changes the pending buffer scale.
 * wl_surface.commit copies the pending buffer scale to the current one.
 * Otherwise, the pending and current values are never changed.
 * 
 * The purpose of this request is to allow clients to supply higher
 * resolution buffer data for use on high resolution outputs. It is
 * intended that you pick the same buffer scale as the scale of the
 * output that the surface is displayed on. This means the compositor
 * can avoid scaling when rendering the surface on that output.
 * 
 * Note that if the scale is larger than 1, then you have to attach
 * a buffer that is larger (by a factor of scale in each dimension)
 * than the desired surface size.
 * 
 * If scale is not greater than 0 the invalid_scale protocol error is
 * raised.
 */
surface_set_buffer_scale :: #force_inline proc(
    surface: ^Surface,
    /*
     * scale for interpreting buffer contents
     */
    scale: i32,
) {
    proxy_marshal_flags(
        cast(^Proxy)surface,
        SURFACE_SET_BUFFER_SCALE,
        nil,
        1,
        {},
        scale,
    )
}

/*
 * mark part of the surface damaged using buffer coordinates
 * This request is used to describe the regions where the pending
 * buffer is different from the current surface contents, and where
 * the surface therefore needs to be repainted. The compositor
 * ignores the parts of the damage that fall outside of the surface.
 * 
 * Damage is double-buffered state, see wl_surface.commit.
 * 
 * The damage rectangle is specified in buffer coordinates,
 * where x and y specify the upper left corner of the damage rectangle.
 * 
 * The initial value for pending damage is empty: no damage.
 * wl_surface.damage_buffer adds pending damage: the new pending
 * damage is the union of old pending damage and the given rectangle.
 * 
 * wl_surface.commit assigns pending damage as the current damage,
 * and clears pending damage. The server will clear the current
 * damage as it repaints the surface.
 * 
 * This request differs from wl_surface.damage in only one way - it
 * takes damage in buffer coordinates instead of surface-local
 * coordinates. While this generally is more intuitive than surface
 * coordinates, it is especially desirable when using wp_viewport
 * or when a drawing library (like EGL) is unaware of buffer scale
 * and buffer transform.
 * 
 * Note: Because buffer transformation changes and damage requests may
 * be interleaved in the protocol stream, it is impossible to determine
 * the actual mapping between surface and buffer damage until
 * wl_surface.commit time. Therefore, compositors wishing to take both
 * kinds of damage into account will have to accumulate damage from the
 * two requests separately and only transform from one to the other
 * after receiving the wl_surface.commit.
 */
surface_damage_buffer :: #force_inline proc(
    surface: ^Surface,
    /*
     * buffer-local x coordinate
     */
    x: i32,
    /*
     * buffer-local y coordinate
     */
    y: i32,
    /*
     * width of damage rectangle
     */
    width: i32,
    /*
     * height of damage rectangle
     */
    height: i32,
) {
    proxy_marshal_flags(
        cast(^Proxy)surface,
        SURFACE_DAMAGE_BUFFER,
        nil,
        1,
        {},
        x,
        y,
        width,
        height,
    )
}

/*
 * set the surface contents offset
 * The x and y arguments specify the location of the new pending
 * buffer's upper left corner, relative to the current buffer's upper
 * left corner, in surface-local coordinates. In other words, the
 * x and y, combined with the new surface size define in which
 * directions the surface's size changes.
 * 
 * The exact semantics of wl_surface.offset are role-specific. Refer to
 * the documentation of specific roles for more information.
 * 
 * Surface location offset is double-buffered state, see
 * wl_surface.commit.
 * 
 * This request is semantically equivalent to and the replaces the x and y
 * arguments in the wl_surface.attach request in wl_surface versions prior
 * to 5. See wl_surface.attach for details.
 */
surface_offset :: #force_inline proc(
    surface: ^Surface,
    /*
     * surface-local x coordinate
     */
    x: i32,
    /*
     * surface-local y coordinate
     */
    y: i32,
) {
    proxy_marshal_flags(
        cast(^Proxy)surface,
        SURFACE_OFFSET,
        nil,
        1,
        {},
        x,
        y,
    )
}


/*
 * seat capability bitmask
 * This is a bitmask of capabilities this seat has; if a member is
 * set, then it is present on the seat.
 */
Seat_Capability_Flag :: enum {
    /*
     * the seat has pointer devices
     */
    Pointer = 1,
    /*
     * the seat has one or more keyboards
     */
    Keyboard = 2,
    /*
     * the seat has touch devices
     */
    Touch = 4,
}
Seat_Capability_Flags :: bit_set[Seat_Capability_Flag]

/*
 * wl_seat error values
 * These errors can be emitted in response to wl_seat requests.
 */
Seat_Error :: enum {
    /*
     * get_pointer, get_keyboard or get_touch called on seat without the matching capability
     */
    Missing_Capability = 0,
}

Seat_Listener :: struct{
    /*
     * seat capabilities changed
     * This is emitted whenever a seat gains or loses the pointer,
     * keyboard or touch capabilities.  The argument is a capability
     * enum containing the complete set of capabilities this seat has.
     * 
     * When the pointer capability is added, a client may create a
     * wl_pointer object using the wl_seat.get_pointer request. This object
     * will receive pointer events until the capability is removed in the
     * future.
     * 
     * When the pointer capability is removed, a client should destroy the
     * wl_pointer objects associated with the seat where the capability was
     * removed, using the wl_pointer.release request. No further pointer
     * events will be received on these objects.
     * 
     * In some compositors, if a seat regains the pointer capability and a
     * client has a previously obtained wl_pointer object of version 4 or
     * less, that object may start sending pointer events again. This
     * behavior is considered a misinterpretation of the intended behavior
     * and must not be relied upon by the client. wl_pointer objects of
     * version 5 or later must not send events if created before the most
     * recent event notifying the client of an added pointer capability.
     * 
     * The above behavior also applies to wl_keyboard and wl_touch with the
     * keyboard and touch capabilities, respectively.
     */
    capabilities: proc(
        data: rawptr,
        seat: ^Seat,
        /*
         * capabilities of the seat
         */
        capabilities: Seat_Capability_Flags,
    ),

    /*
     * unique identifier for this seat
     * In a multi-seat configuration the seat name can be used by clients to
     * help identify which physical devices the seat represents.
     * 
     * The seat name is a UTF-8 string with no convention defined for its
     * contents. Each name is unique among all wl_seat globals. The name is
     * only guaranteed to be unique for the current compositor instance.
     * 
     * The same seat names are used for all clients. Thus, the name can be
     * shared across processes to refer to a specific wl_seat global.
     * 
     * The name event is sent after binding to the seat global. This event is
     * only sent once per seat object, and the name does not change over the
     * lifetime of the wl_seat global.
     * 
     * Compositors may re-use the same seat name if the wl_seat global is
     * destroyed and re-created later.
     */
    name: proc(
        data: rawptr,
        seat: ^Seat,
        /*
         * seat identifier
         */
        name: cstring,
    ),

}

seat_add_listener :: #force_inline proc(seat: ^Seat, listener: ^Seat_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)seat,
        rawptr(listener),
        data
    )
}
seat_set_user_data :: #force_inline proc(seat: ^Seat, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)seat,
        user_data
    )
}
seat_get_user_data :: #force_inline proc(seat: ^Seat) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)seat)
}
seat_get_version :: #force_inline proc(seat: ^Seat) -> u32 {
    return proxy_get_version(cast(^Proxy)seat);
}

SEAT_GET_POINTER :: 0
SEAT_GET_KEYBOARD :: 1
SEAT_GET_TOUCH :: 2
SEAT_RELEASE :: 3

/*
 * return pointer object
 * The ID provided will be initialized to the wl_pointer interface
 * for this seat.
 * 
 * This request only takes effect if the seat has the pointer
 * capability, or has had the pointer capability in the past.
 * It is a protocol violation to issue this request on a seat that has
 * never had the pointer capability. The missing_capability error will
 * be sent in this case.
 */
seat_get_pointer :: #force_inline proc(
    seat: ^Seat,
) -> ^Pointer {
    return cast(^Pointer)proxy_marshal_flags(
        cast(^Proxy)seat,
        SEAT_GET_POINTER,
        &pointer_interface,
        proxy_get_version(cast(^Proxy)seat),
        {},
        nil,
    )
}

/*
 * return keyboard object
 * The ID provided will be initialized to the wl_keyboard interface
 * for this seat.
 * 
 * This request only takes effect if the seat has the keyboard
 * capability, or has had the keyboard capability in the past.
 * It is a protocol violation to issue this request on a seat that has
 * never had the keyboard capability. The missing_capability error will
 * be sent in this case.
 */
seat_get_keyboard :: #force_inline proc(
    seat: ^Seat,
) -> ^Keyboard {
    return cast(^Keyboard)proxy_marshal_flags(
        cast(^Proxy)seat,
        SEAT_GET_KEYBOARD,
        &keyboard_interface,
        proxy_get_version(cast(^Proxy)seat),
        {},
        nil,
    )
}

/*
 * return touch object
 * The ID provided will be initialized to the wl_touch interface
 * for this seat.
 * 
 * This request only takes effect if the seat has the touch
 * capability, or has had the touch capability in the past.
 * It is a protocol violation to issue this request on a seat that has
 * never had the touch capability. The missing_capability error will
 * be sent in this case.
 */
seat_get_touch :: #force_inline proc(
    seat: ^Seat,
) -> ^Touch {
    return cast(^Touch)proxy_marshal_flags(
        cast(^Proxy)seat,
        SEAT_GET_TOUCH,
        &touch_interface,
        proxy_get_version(cast(^Proxy)seat),
        {},
        nil,
    )
}

/*
 * release the seat object
 * Using this request a client can tell the server that it is not going to
 * use the seat object anymore.
 */
seat_release :: #force_inline proc(
    seat: ^Seat,
) {
    proxy_marshal_flags(
        cast(^Proxy)seat,
        SEAT_RELEASE,
        nil,
        1,
        {},
    )
}


Pointer_Error :: enum {
    /*
     * given wl_surface has another role
     */
    Role = 0,
}

/*
 * physical button state
 * Describes the physical state of a button that produced the button
 * event.
 */
Pointer_Button_State :: enum {
    /*
     * the button is not pressed
     */
    Released = 0,
    /*
     * the button is pressed
     */
    Pressed = 1,
}

/*
 * axis types
 * Describes the axis types of scroll events.
 */
Pointer_Axis :: enum {
    /*
     * vertical axis
     */
    Vertical_Scroll = 0,
    /*
     * horizontal axis
     */
    Horizontal_Scroll = 1,
}

/*
 * axis source types
 * Describes the source types for axis events. This indicates to the
 * client how an axis event was physically generated; a client may
 * adjust the user interface accordingly. For example, scroll events
 * from a "finger" source may be in a smooth coordinate space with
 * kinetic scrolling whereas a "wheel" source may be in discrete steps
 * of a number of lines.
 * 
 * The "continuous" axis source is a device generating events in a
 * continuous coordinate space, but using something other than a
 * finger. One example for this source is button-based scrolling where
 * the vertical motion of a device is converted to scroll events while
 * a button is held down.
 * 
 * The "wheel tilt" axis source indicates that the actual device is a
 * wheel but the scroll event is not caused by a rotation but a
 * (usually sideways) tilt of the wheel.
 */
Pointer_Axis_Source :: enum {
    /*
     * a physical wheel rotation
     */
    Wheel = 0,
    /*
     * finger on a touch surface
     */
    Finger = 1,
    /*
     * continuous coordinate space
     */
    Continuous = 2,
    /*
     * a physical wheel tilt
     */
    Wheel_Tilt = 3,
}

/*
 * axis relative direction
 * This specifies the direction of the physical motion that caused a
 * wl_pointer.axis event, relative to the wl_pointer.axis direction.
 */
Pointer_Axis_Relative_Direction :: enum {
    /*
     * physical motion matches axis direction
     */
    Identical = 0,
    /*
     * physical motion is the inverse of the axis direction
     */
    Inverted = 1,
}

Pointer_Listener :: struct{
    /*
     * enter event
     * Notification that this seat's pointer is focused on a certain
     * surface.
     * 
     * When a seat's focus enters a surface, the pointer image
     * is undefined and a client should respond to this event by setting
     * an appropriate pointer image with the set_cursor request.
     */
    enter: proc(
        data: rawptr,
        pointer: ^Pointer,
        /*
         * serial number of the enter event
         */
        serial: u32,
        /*
         * surface entered by the pointer
         */
        surface: ^Surface,
        /*
         * surface-local x coordinate
         */
        surface_x: Fixed,
        /*
         * surface-local y coordinate
         */
        surface_y: Fixed,
    ),

    /*
     * leave event
     * Notification that this seat's pointer is no longer focused on
     * a certain surface.
     * 
     * The leave notification is sent before the enter notification
     * for the new focus.
     */
    leave: proc(
        data: rawptr,
        pointer: ^Pointer,
        /*
         * serial number of the leave event
         */
        serial: u32,
        /*
         * surface left by the pointer
         */
        surface: ^Surface,
    ),

    /*
     * pointer motion event
     * Notification of pointer location change. The arguments
     * surface_x and surface_y are the location relative to the
     * focused surface.
     */
    motion: proc(
        data: rawptr,
        pointer: ^Pointer,
        /*
         * timestamp with millisecond granularity
         */
        time: u32,
        /*
         * surface-local x coordinate
         */
        surface_x: Fixed,
        /*
         * surface-local y coordinate
         */
        surface_y: Fixed,
    ),

    /*
     * pointer button event
     * Mouse button click and release notifications.
     * 
     * The location of the click is given by the last motion or
     * enter event.
     * The time argument is a timestamp with millisecond
     * granularity, with an undefined base.
     * 
     * The button is a button code as defined in the Linux kernel's
     * linux/input-event-codes.h header file, e.g. BTN_LEFT.
     * 
     * Any 16-bit button code value is reserved for future additions to the
     * kernel's event code list. All other button codes above 0xFFFF are
     * currently undefined but may be used in future versions of this
     * protocol.
     */
    button: proc(
        data: rawptr,
        pointer: ^Pointer,
        /*
         * serial number of the button event
         */
        serial: u32,
        /*
         * timestamp with millisecond granularity
         */
        time: u32,
        /*
         * button that produced the event
         */
        button: u32,
        /*
         * physical state of the button
         */
        state: Pointer_Button_State,
    ),

    /*
     * axis event
     * Scroll and other axis notifications.
     * 
     * For scroll events (vertical and horizontal scroll axes), the
     * value parameter is the length of a vector along the specified
     * axis in a coordinate space identical to those of motion events,
     * representing a relative movement along the specified axis.
     * 
     * For devices that support movements non-parallel to axes multiple
     * axis events will be emitted.
     * 
     * When applicable, for example for touch pads, the server can
     * choose to emit scroll events where the motion vector is
     * equivalent to a motion event vector.
     * 
     * When applicable, a client can transform its content relative to the
     * scroll distance.
     */
    axis: proc(
        data: rawptr,
        pointer: ^Pointer,
        /*
         * timestamp with millisecond granularity
         */
        time: u32,
        /*
         * axis type
         */
        axis: Pointer_Axis,
        /*
         * length of vector in surface-local coordinate space
         */
        value: Fixed,
    ),

    /*
     * end of a pointer event sequence
     * Indicates the end of a set of events that logically belong together.
     * A client is expected to accumulate the data in all events within the
     * frame before proceeding.
     * 
     * All wl_pointer events before a wl_pointer.frame event belong
     * logically together. For example, in a diagonal scroll motion the
     * compositor will send an optional wl_pointer.axis_source event, two
     * wl_pointer.axis events (horizontal and vertical) and finally a
     * wl_pointer.frame event. The client may use this information to
     * calculate a diagonal vector for scrolling.
     * 
     * When multiple wl_pointer.axis events occur within the same frame,
     * the motion vector is the combined motion of all events.
     * When a wl_pointer.axis and a wl_pointer.axis_stop event occur within
     * the same frame, this indicates that axis movement in one axis has
     * stopped but continues in the other axis.
     * When multiple wl_pointer.axis_stop events occur within the same
     * frame, this indicates that these axes stopped in the same instance.
     * 
     * A wl_pointer.frame event is sent for every logical event group,
     * even if the group only contains a single wl_pointer event.
     * Specifically, a client may get a sequence: motion, frame, button,
     * frame, axis, frame, axis_stop, frame.
     * 
     * The wl_pointer.enter and wl_pointer.leave events are logical events
     * generated by the compositor and not the hardware. These events are
     * also grouped by a wl_pointer.frame. When a pointer moves from one
     * surface to another, a compositor should group the
     * wl_pointer.leave event within the same wl_pointer.frame.
     * However, a client must not rely on wl_pointer.leave and
     * wl_pointer.enter being in the same wl_pointer.frame.
     * Compositor-specific policies may require the wl_pointer.leave and
     * wl_pointer.enter event being split across multiple wl_pointer.frame
     * groups.
     */
    frame: proc(
        data: rawptr,
        pointer: ^Pointer,
    ),

    /*
     * axis source event
     * Source information for scroll and other axes.
     * 
     * This event does not occur on its own. It is sent before a
     * wl_pointer.frame event and carries the source information for
     * all events within that frame.
     * 
     * The source specifies how this event was generated. If the source is
     * wl_pointer.axis_source.finger, a wl_pointer.axis_stop event will be
     * sent when the user lifts the finger off the device.
     * 
     * If the source is wl_pointer.axis_source.wheel,
     * wl_pointer.axis_source.wheel_tilt or
     * wl_pointer.axis_source.continuous, a wl_pointer.axis_stop event may
     * or may not be sent. Whether a compositor sends an axis_stop event
     * for these sources is hardware-specific and implementation-dependent;
     * clients must not rely on receiving an axis_stop event for these
     * scroll sources and should treat scroll sequences from these scroll
     * sources as unterminated by default.
     * 
     * This event is optional. If the source is unknown for a particular
     * axis event sequence, no event is sent.
     * Only one wl_pointer.axis_source event is permitted per frame.
     * 
     * The order of wl_pointer.axis_discrete and wl_pointer.axis_source is
     * not guaranteed.
     */
    axis_source: proc(
        data: rawptr,
        pointer: ^Pointer,
        /*
         * source of the axis event
         */
        axis_source: Pointer_Axis_Source,
    ),

    /*
     * axis stop event
     * Stop notification for scroll and other axes.
     * 
     * For some wl_pointer.axis_source types, a wl_pointer.axis_stop event
     * is sent to notify a client that the axis sequence has terminated.
     * This enables the client to implement kinetic scrolling.
     * See the wl_pointer.axis_source documentation for information on when
     * this event may be generated.
     * 
     * Any wl_pointer.axis events with the same axis_source after this
     * event should be considered as the start of a new axis motion.
     * 
     * The timestamp is to be interpreted identical to the timestamp in the
     * wl_pointer.axis event. The timestamp value may be the same as a
     * preceding wl_pointer.axis event.
     */
    axis_stop: proc(
        data: rawptr,
        pointer: ^Pointer,
        /*
         * timestamp with millisecond granularity
         */
        time: u32,
        /*
         * the axis stopped with this event
         */
        axis: Pointer_Axis,
    ),

    /*
     * axis click event
     * Discrete step information for scroll and other axes.
     * 
     * This event carries the axis value of the wl_pointer.axis event in
     * discrete steps (e.g. mouse wheel clicks).
     * 
     * This event is deprecated with wl_pointer version 8 - this event is not
     * sent to clients supporting version 8 or later.
     * 
     * This event does not occur on its own, it is coupled with a
     * wl_pointer.axis event that represents this axis value on a
     * continuous scale. The protocol guarantees that each axis_discrete
     * event is always followed by exactly one axis event with the same
     * axis number within the same wl_pointer.frame. Note that the protocol
     * allows for other events to occur between the axis_discrete and
     * its coupled axis event, including other axis_discrete or axis
     * events. A wl_pointer.frame must not contain more than one axis_discrete
     * event per axis type.
     * 
     * This event is optional; continuous scrolling devices
     * like two-finger scrolling on touchpads do not have discrete
     * steps and do not generate this event.
     * 
     * The discrete value carries the directional information. e.g. a value
     * of -2 is two steps towards the negative direction of this axis.
     * 
     * The axis number is identical to the axis number in the associated
     * axis event.
     * 
     * The order of wl_pointer.axis_discrete and wl_pointer.axis_source is
     * not guaranteed.
     */
    axis_discrete: proc(
        data: rawptr,
        pointer: ^Pointer,
        /*
         * axis type
         */
        axis: Pointer_Axis,
        /*
         * number of steps
         */
        discrete: i32,
    ),

    /*
     * axis high-resolution scroll event
     * Discrete high-resolution scroll information.
     * 
     * This event carries high-resolution wheel scroll information,
     * with each multiple of 120 representing one logical scroll step
     * (a wheel detent). For example, an axis_value120 of 30 is one quarter of
     * a logical scroll step in the positive direction, a value120 of
     * -240 are two logical scroll steps in the negative direction within the
     * same hardware event.
     * Clients that rely on discrete scrolling should accumulate the
     * value120 to multiples of 120 before processing the event.
     * 
     * The value120 must not be zero.
     * 
     * This event replaces the wl_pointer.axis_discrete event in clients
     * supporting wl_pointer version 8 or later.
     * 
     * Where a wl_pointer.axis_source event occurs in the same
     * wl_pointer.frame, the axis source applies to this event.
     * 
     * The order of wl_pointer.axis_value120 and wl_pointer.axis_source is
     * not guaranteed.
     */
    axis_value120: proc(
        data: rawptr,
        pointer: ^Pointer,
        /*
         * axis type
         */
        axis: Pointer_Axis,
        /*
         * scroll distance as fraction of 120
         */
        value120: i32,
    ),

    /*
     * axis relative physical direction event
     * Relative directional information of the entity causing the axis
     * motion.
     * 
     * For a wl_pointer.axis event, the wl_pointer.axis_relative_direction
     * event specifies the movement direction of the entity causing the
     * wl_pointer.axis event. For example:
     * - if a user's fingers on a touchpad move down and this
     * causes a wl_pointer.axis vertical_scroll down event, the physical
     * direction is 'identical'
     * - if a user's fingers on a touchpad move down and this causes a
     * wl_pointer.axis vertical_scroll up scroll up event ('natural
     * scrolling'), the physical direction is 'inverted'.
     * 
     * A client may use this information to adjust scroll motion of
     * components. Specifically, enabling natural scrolling causes the
     * content to change direction compared to traditional scrolling.
     * Some widgets like volume control sliders should usually match the
     * physical direction regardless of whether natural scrolling is
     * active. This event enables clients to match the scroll direction of
     * a widget to the physical direction.
     * 
     * This event does not occur on its own, it is coupled with a
     * wl_pointer.axis event that represents this axis value.
     * The protocol guarantees that each axis_relative_direction event is
     * always followed by exactly one axis event with the same
     * axis number within the same wl_pointer.frame. Note that the protocol
     * allows for other events to occur between the axis_relative_direction
     * and its coupled axis event.
     * 
     * The axis number is identical to the axis number in the associated
     * axis event.
     * 
     * The order of wl_pointer.axis_relative_direction,
     * wl_pointer.axis_discrete and wl_pointer.axis_source is not
     * guaranteed.
     */
    axis_relative_direction: proc(
        data: rawptr,
        pointer: ^Pointer,
        /*
         * axis type
         */
        axis: Pointer_Axis,
        /*
         * physical direction relative to axis motion
         */
        direction: Pointer_Axis_Relative_Direction,
    ),

}

pointer_add_listener :: #force_inline proc(pointer: ^Pointer, listener: ^Pointer_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)pointer,
        rawptr(listener),
        data
    )
}
pointer_set_user_data :: #force_inline proc(pointer: ^Pointer, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)pointer,
        user_data
    )
}
pointer_get_user_data :: #force_inline proc(pointer: ^Pointer) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)pointer)
}
pointer_get_version :: #force_inline proc(pointer: ^Pointer) -> u32 {
    return proxy_get_version(cast(^Proxy)pointer);
}

POINTER_SET_CURSOR :: 0
POINTER_RELEASE :: 1

/*
 * set the pointer surface
 * Set the pointer surface, i.e., the surface that contains the
 * pointer image (cursor). This request gives the surface the role
 * of a cursor. If the surface already has another role, it raises
 * a protocol error.
 * 
 * The cursor actually changes only if the pointer
 * focus for this device is one of the requesting client's surfaces
 * or the surface parameter is the current pointer surface. If
 * there was a previous surface set with this request it is
 * replaced. If surface is NULL, the pointer image is hidden.
 * 
 * The parameters hotspot_x and hotspot_y define the position of
 * the pointer surface relative to the pointer location. Its
 * top-left corner is always at (x, y) - (hotspot_x, hotspot_y),
 * where (x, y) are the coordinates of the pointer location, in
 * surface-local coordinates.
 * 
 * On wl_surface.offset requests to the pointer surface, hotspot_x
 * and hotspot_y are decremented by the x and y parameters
 * passed to the request. The offset must be applied by
 * wl_surface.commit as usual.
 * 
 * The hotspot can also be updated by passing the currently set
 * pointer surface to this request with new values for hotspot_x
 * and hotspot_y.
 * 
 * The input region is ignored for wl_surfaces with the role of
 * a cursor. When the use as a cursor ends, the wl_surface is
 * unmapped.
 * 
 * The serial parameter must match the latest wl_pointer.enter
 * serial number sent to the client. Otherwise the request will be
 * ignored.
 */
pointer_set_cursor :: #force_inline proc(
    pointer: ^Pointer,
    /*
     * serial number of the enter event
     */
    serial: u32,
    /*
     * pointer surface
     */
    surface: ^Surface,
    /*
     * surface-local x coordinate
     */
    hotspot_x: i32,
    /*
     * surface-local y coordinate
     */
    hotspot_y: i32,
) {
    proxy_marshal_flags(
        cast(^Proxy)pointer,
        POINTER_SET_CURSOR,
        nil,
        1,
        {},
        serial,
        surface,
        hotspot_x,
        hotspot_y,
    )
}

/*
 * release the pointer object
 * Using this request a client can tell the server that it is not going to
 * use the pointer object anymore.
 * 
 * This request destroys the pointer proxy object, so clients must not call
 * wl_pointer_destroy() after using this request.
 */
pointer_release :: #force_inline proc(
    pointer: ^Pointer,
) {
    proxy_marshal_flags(
        cast(^Proxy)pointer,
        POINTER_RELEASE,
        nil,
        1,
        {},
    )
}


/*
 * keyboard mapping format
 * This specifies the format of the keymap provided to the
 * client with the wl_keyboard.keymap event.
 */
Keyboard_Keymap_Format :: enum {
    /*
     * no keymap; client must understand how to interpret the raw keycode
     */
    No_Keymap = 0,
    /*
     * libxkbcommon compatible, null-terminated string; to determine the xkb keycode, clients must add 8 to the key event keycode
     */
    Xkb_V1 = 1,
}

/*
 * physical key state
 * Describes the physical state of a key that produced the key event.
 * 
 * Since version 10, the key can be in a "repeated" pseudo-state which
 * means the same as "pressed", but is used to signal repetition in the
 * key event.
 * 
 * The key may only enter the repeated state after entering the pressed
 * state and before entering the released state. This event may be
 * generated multiple times while the key is down.
 */
Keyboard_Key_State :: enum {
    /*
     * key is not pressed
     */
    Released = 0,
    /*
     * key is pressed
     */
    Pressed = 1,
    /*
     * key was repeated
     */
    Repeated = 2,
}

Keyboard_Listener :: struct{
    /*
     * keyboard mapping
     * This event provides a file descriptor to the client which can be
     * memory-mapped in read-only mode to provide a keyboard mapping
     * description.
     * 
     * From version 7 onwards, the fd must be mapped with MAP_PRIVATE by
     * the recipient, as MAP_SHARED may fail.
     */
    keymap: proc(
        data: rawptr,
        keyboard: ^Keyboard,
        /*
         * keymap format
         */
        format: Keyboard_Keymap_Format,
        /*
         * keymap file descriptor
         */
        fd: i32,
        /*
         * keymap size, in bytes
         */
        size: u32,
    ),

    /*
     * enter event
     * Notification that this seat's keyboard focus is on a certain
     * surface.
     * 
     * The compositor must send the wl_keyboard.modifiers event after this
     * event.
     * 
     * In the wl_keyboard logical state, this event sets the active surface to
     * the surface argument and the keys currently logically down to the keys
     * in the keys argument. The compositor must not send this event if the
     * wl_keyboard already had an active surface immediately before this event.
     * 
     * Clients should not use the list of pressed keys to emulate key-press
     * events. The order of keys in the list is unspecified.
     */
    enter: proc(
        data: rawptr,
        keyboard: ^Keyboard,
        /*
         * serial number of the enter event
         */
        serial: u32,
        /*
         * surface gaining keyboard focus
         */
        surface: ^Surface,
        /*
         * the keys currently logically down
         */
        keys: ^Array,
    ),

    /*
     * leave event
     * Notification that this seat's keyboard focus is no longer on
     * a certain surface.
     * 
     * The leave notification is sent before the enter notification
     * for the new focus.
     * 
     * In the wl_keyboard logical state, this event resets all values to their
     * defaults. The compositor must not send this event if the active surface
     * of the wl_keyboard was not equal to the surface argument immediately
     * before this event.
     */
    leave: proc(
        data: rawptr,
        keyboard: ^Keyboard,
        /*
         * serial number of the leave event
         */
        serial: u32,
        /*
         * surface that lost keyboard focus
         */
        surface: ^Surface,
    ),

    /*
     * key event
     * A key was pressed or released.
     * The time argument is a timestamp with millisecond
     * granularity, with an undefined base.
     * 
     * The key is a platform-specific key code that can be interpreted
     * by feeding it to the keyboard mapping (see the keymap event).
     * 
     * If this event produces a change in modifiers, then the resulting
     * wl_keyboard.modifiers event must be sent after this event.
     * 
     * In the wl_keyboard logical state, this event adds the key to the keys
     * currently logically down (if the state argument is pressed) or removes
     * the key from the keys currently logically down (if the state argument is
     * released). The compositor must not send this event if the wl_keyboard
     * did not have an active surface immediately before this event. The
     * compositor must not send this event if state is pressed (resp. released)
     * and the key was already logically down (resp. was not logically down)
     * immediately before this event.
     * 
     * Since version 10, compositors may send key events with the "repeated"
     * key state when a wl_keyboard.repeat_info event with a rate argument of
     * 0 has been received. This allows the compositor to take over the
     * responsibility of key repetition.
     */
    key: proc(
        data: rawptr,
        keyboard: ^Keyboard,
        /*
         * serial number of the key event
         */
        serial: u32,
        /*
         * timestamp with millisecond granularity
         */
        time: u32,
        /*
         * key that produced the event
         */
        key: u32,
        /*
         * physical state of the key
         */
        state: Keyboard_Key_State,
    ),

    /*
     * modifier and group state
     * Notifies clients that the modifier and/or group state has
     * changed, and it should update its local state.
     * 
     * The compositor may send this event without a surface of the client
     * having keyboard focus, for example to tie modifier information to
     * pointer focus instead. If a modifier event with pressed modifiers is sent
     * without a prior enter event, the client can assume the modifier state is
     * valid until it receives the next wl_keyboard.modifiers event. In order to
     * reset the modifier state again, the compositor can send a
     * wl_keyboard.modifiers event with no pressed modifiers.
     * 
     * In the wl_keyboard logical state, this event updates the modifiers and
     * group.
     */
    modifiers: proc(
        data: rawptr,
        keyboard: ^Keyboard,
        /*
         * serial number of the modifiers event
         */
        serial: u32,
        /*
         * depressed modifiers
         */
        mods_depressed: u32,
        /*
         * latched modifiers
         */
        mods_latched: u32,
        /*
         * locked modifiers
         */
        mods_locked: u32,
        /*
         * keyboard layout
         */
        group: u32,
    ),

    /*
     * repeat rate and delay
     * Informs the client about the keyboard's repeat rate and delay.
     * 
     * This event is sent as soon as the wl_keyboard object has been created,
     * and is guaranteed to be received by the client before any key press
     * event.
     * 
     * Negative values for either rate or delay are illegal. A rate of zero
     * will disable any repeating (regardless of the value of delay).
     * 
     * This event can be sent later on as well with a new value if necessary,
     * so clients should continue listening for the event past the creation
     * of wl_keyboard.
     */
    repeat_info: proc(
        data: rawptr,
        keyboard: ^Keyboard,
        /*
         * the rate of repeating keys in characters per second
         */
        rate: i32,
        /*
         * delay in milliseconds since key down until repeating starts
         */
        delay: i32,
    ),

}

keyboard_add_listener :: #force_inline proc(keyboard: ^Keyboard, listener: ^Keyboard_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)keyboard,
        rawptr(listener),
        data
    )
}
keyboard_set_user_data :: #force_inline proc(keyboard: ^Keyboard, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)keyboard,
        user_data
    )
}
keyboard_get_user_data :: #force_inline proc(keyboard: ^Keyboard) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)keyboard)
}
keyboard_get_version :: #force_inline proc(keyboard: ^Keyboard) -> u32 {
    return proxy_get_version(cast(^Proxy)keyboard);
}

KEYBOARD_RELEASE :: 0

/*
 * release the keyboard object
 */
keyboard_release :: #force_inline proc(
    keyboard: ^Keyboard,
) {
    proxy_marshal_flags(
        cast(^Proxy)keyboard,
        KEYBOARD_RELEASE,
        nil,
        1,
        {},
    )
}


Touch_Listener :: struct{
    /*
     * touch down event and beginning of a touch sequence
     * A new touch point has appeared on the surface. This touch point is
     * assigned a unique ID. Future events from this touch point reference
     * this ID. The ID ceases to be valid after a touch up event and may be
     * reused in the future.
     */
    down: proc(
        data: rawptr,
        touch: ^Touch,
        /*
         * serial number of the touch down event
         */
        serial: u32,
        /*
         * timestamp with millisecond granularity
         */
        time: u32,
        /*
         * surface touched
         */
        surface: ^Surface,
        /*
         * the unique ID of this touch point
         */
        id: i32,
        /*
         * surface-local x coordinate
         */
        x: Fixed,
        /*
         * surface-local y coordinate
         */
        y: Fixed,
    ),

    /*
     * end of a touch event sequence
     * The touch point has disappeared. No further events will be sent for
     * this touch point and the touch point's ID is released and may be
     * reused in a future touch down event.
     */
    up: proc(
        data: rawptr,
        touch: ^Touch,
        /*
         * serial number of the touch up event
         */
        serial: u32,
        /*
         * timestamp with millisecond granularity
         */
        time: u32,
        /*
         * the unique ID of this touch point
         */
        id: i32,
    ),

    /*
     * update of touch point coordinates
     * A touch point has changed coordinates.
     */
    motion: proc(
        data: rawptr,
        touch: ^Touch,
        /*
         * timestamp with millisecond granularity
         */
        time: u32,
        /*
         * the unique ID of this touch point
         */
        id: i32,
        /*
         * surface-local x coordinate
         */
        x: Fixed,
        /*
         * surface-local y coordinate
         */
        y: Fixed,
    ),

    /*
     * end of touch frame event
     * Indicates the end of a set of events that logically belong together.
     * A client is expected to accumulate the data in all events within the
     * frame before proceeding.
     * 
     * A wl_touch.frame terminates at least one event but otherwise no
     * guarantee is provided about the set of events within a frame. A client
     * must assume that any state not updated in a frame is unchanged from the
     * previously known state.
     */
    frame: proc(
        data: rawptr,
        touch: ^Touch,
    ),

    /*
     * touch session cancelled
     * Sent if the compositor decides the touch stream is a global
     * gesture. No further events are sent to the clients from that
     * particular gesture. Touch cancellation applies to all touch points
     * currently active on this client's surface. The client is
     * responsible for finalizing the touch points, future touch points on
     * this surface may reuse the touch point ID.
     * 
     * No frame event is required after the cancel event.
     */
    cancel: proc(
        data: rawptr,
        touch: ^Touch,
    ),

    /*
     * update shape of touch point
     * Sent when a touchpoint has changed its shape.
     * 
     * This event does not occur on its own. It is sent before a
     * wl_touch.frame event and carries the new shape information for
     * any previously reported, or new touch points of that frame.
     * 
     * Other events describing the touch point such as wl_touch.down,
     * wl_touch.motion or wl_touch.orientation may be sent within the
     * same wl_touch.frame. A client should treat these events as a single
     * logical touch point update. The order of wl_touch.shape,
     * wl_touch.orientation and wl_touch.motion is not guaranteed.
     * A wl_touch.down event is guaranteed to occur before the first
     * wl_touch.shape event for this touch ID but both events may occur within
     * the same wl_touch.frame.
     * 
     * A touchpoint shape is approximated by an ellipse through the major and
     * minor axis length. The major axis length describes the longer diameter
     * of the ellipse, while the minor axis length describes the shorter
     * diameter. Major and minor are orthogonal and both are specified in
     * surface-local coordinates. The center of the ellipse is always at the
     * touchpoint location as reported by wl_touch.down or wl_touch.move.
     * 
     * This event is only sent by the compositor if the touch device supports
     * shape reports. The client has to make reasonable assumptions about the
     * shape if it did not receive this event.
     */
    shape: proc(
        data: rawptr,
        touch: ^Touch,
        /*
         * the unique ID of this touch point
         */
        id: i32,
        /*
         * length of the major axis in surface-local coordinates
         */
        major: Fixed,
        /*
         * length of the minor axis in surface-local coordinates
         */
        minor: Fixed,
    ),

    /*
     * update orientation of touch point
     * Sent when a touchpoint has changed its orientation.
     * 
     * This event does not occur on its own. It is sent before a
     * wl_touch.frame event and carries the new shape information for
     * any previously reported, or new touch points of that frame.
     * 
     * Other events describing the touch point such as wl_touch.down,
     * wl_touch.motion or wl_touch.shape may be sent within the
     * same wl_touch.frame. A client should treat these events as a single
     * logical touch point update. The order of wl_touch.shape,
     * wl_touch.orientation and wl_touch.motion is not guaranteed.
     * A wl_touch.down event is guaranteed to occur before the first
     * wl_touch.orientation event for this touch ID but both events may occur
     * within the same wl_touch.frame.
     * 
     * The orientation describes the clockwise angle of a touchpoint's major
     * axis to the positive surface y-axis and is normalized to the -180 to
     * +180 degree range. The granularity of orientation depends on the touch
     * device, some devices only support binary rotation values between 0 and
     * 90 degrees.
     * 
     * This event is only sent by the compositor if the touch device supports
     * orientation reports.
     */
    orientation: proc(
        data: rawptr,
        touch: ^Touch,
        /*
         * the unique ID of this touch point
         */
        id: i32,
        /*
         * angle between major axis and positive surface y-axis in degrees
         */
        orientation: Fixed,
    ),

}

touch_add_listener :: #force_inline proc(touch: ^Touch, listener: ^Touch_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)touch,
        rawptr(listener),
        data
    )
}
touch_set_user_data :: #force_inline proc(touch: ^Touch, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)touch,
        user_data
    )
}
touch_get_user_data :: #force_inline proc(touch: ^Touch) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)touch)
}
touch_get_version :: #force_inline proc(touch: ^Touch) -> u32 {
    return proxy_get_version(cast(^Proxy)touch);
}

TOUCH_RELEASE :: 0

/*
 * release the touch object
 */
touch_release :: #force_inline proc(
    touch: ^Touch,
) {
    proxy_marshal_flags(
        cast(^Proxy)touch,
        TOUCH_RELEASE,
        nil,
        1,
        {},
    )
}


/*
 * subpixel geometry information
 * This enumeration describes how the physical
 * pixels on an output are laid out.
 */
Output_Subpixel :: enum {
    /*
     * unknown geometry
     */
    Unknown = 0,
    /*
     * no geometry
     */
    None = 1,
    /*
     * horizontal RGB
     */
    Horizontal_Rgb = 2,
    /*
     * horizontal BGR
     */
    Horizontal_Bgr = 3,
    /*
     * vertical RGB
     */
    Vertical_Rgb = 4,
    /*
     * vertical BGR
     */
    Vertical_Bgr = 5,
}

/*
 * transformation applied to buffer contents
 * This describes transformations that clients and compositors apply to
 * buffer contents.
 * 
 * The flipped values correspond to an initial flip around a
 * vertical axis followed by rotation.
 * 
 * The purpose is mainly to allow clients to render accordingly and
 * tell the compositor, so that for fullscreen surfaces, the
 * compositor will still be able to scan out directly from client
 * surfaces.
 */
Output_Transform :: enum {
    /*
     * no transform
     */
    Normal = 0,
    /*
     * 90 degrees counter-clockwise
     */
    _90 = 1,
    /*
     * 180 degrees counter-clockwise
     */
    _180 = 2,
    /*
     * 270 degrees counter-clockwise
     */
    _270 = 3,
    /*
     * 180 degree flip around a vertical axis
     */
    Flipped = 4,
    /*
     * flip and rotate 90 degrees counter-clockwise
     */
    Flipped_90 = 5,
    /*
     * flip and rotate 180 degrees counter-clockwise
     */
    Flipped_180 = 6,
    /*
     * flip and rotate 270 degrees counter-clockwise
     */
    Flipped_270 = 7,
}

/*
 * mode information
 * These flags describe properties of an output mode.
 * They are used in the flags bitfield of the mode event.
 */
Output_Mode_Flag :: enum {
    /*
     * indicates this is the current mode
     */
    Current = 1,
    /*
     * indicates this is the preferred mode
     */
    Preferred = 2,
}
Output_Mode_Flags :: bit_set[Output_Mode_Flag]

Output_Listener :: struct{
    /*
     * properties of the output
     * The geometry event describes geometric properties of the output.
     * The event is sent when binding to the output object and whenever
     * any of the properties change.
     * 
     * The physical size can be set to zero if it doesn't make sense for this
     * output (e.g. for projectors or virtual outputs).
     * 
     * The geometry event will be followed by a done event (starting from
     * version 2).
     * 
     * Clients should use wl_surface.preferred_buffer_transform instead of the
     * transform advertised by this event to find the preferred buffer
     * transform to use for a surface.
     * 
     * Note: wl_output only advertises partial information about the output
     * position and identification. Some compositors, for instance those not
     * implementing a desktop-style output layout or those exposing virtual
     * outputs, might fake this information. Instead of using x and y, clients
     * should use xdg_output.logical_position. Instead of using make and model,
     * clients should use name and description.
     */
    geometry: proc(
        data: rawptr,
        output: ^Output,
        /*
         * x position within the global compositor space
         */
        x: i32,
        /*
         * y position within the global compositor space
         */
        y: i32,
        /*
         * width in millimeters of the output
         */
        physical_width: i32,
        /*
         * height in millimeters of the output
         */
        physical_height: i32,
        /*
         * subpixel orientation of the output
         */
        subpixel: Output_Subpixel,
        /*
         * textual description of the manufacturer
         */
        make: cstring,
        /*
         * textual description of the model
         */
        model: cstring,
        /*
         * additional transformation applied to buffer contents during presentation
         */
        transform: Output_Transform,
    ),

    /*
     * advertise available modes for the output
     * The mode event describes an available mode for the output.
     * 
     * The event is sent when binding to the output object and there
     * will always be one mode, the current mode.  The event is sent
     * again if an output changes mode, for the mode that is now
     * current.  In other words, the current mode is always the last
     * mode that was received with the current flag set.
     * 
     * Non-current modes are deprecated. A compositor can decide to only
     * advertise the current mode and never send other modes. Clients
     * should not rely on non-current modes.
     * 
     * The size of a mode is given in physical hardware units of
     * the output device. This is not necessarily the same as
     * the output size in the global compositor space. For instance,
     * the output may be scaled, as described in wl_output.scale,
     * or transformed, as described in wl_output.transform. Clients
     * willing to retrieve the output size in the global compositor
     * space should use xdg_output.logical_size instead.
     * 
     * The vertical refresh rate can be set to zero if it doesn't make
     * sense for this output (e.g. for virtual outputs).
     * 
     * The mode event will be followed by a done event (starting from
     * version 2).
     * 
     * Clients should not use the refresh rate to schedule frames. Instead,
     * they should use the wl_surface.frame event or the presentation-time
     * protocol.
     * 
     * Note: this information is not always meaningful for all outputs. Some
     * compositors, such as those exposing virtual outputs, might fake the
     * refresh rate or the size.
     */
    mode: proc(
        data: rawptr,
        output: ^Output,
        /*
         * bitfield of mode flags
         */
        flags: Output_Mode_Flags,
        /*
         * width of the mode in hardware units
         */
        width: i32,
        /*
         * height of the mode in hardware units
         */
        height: i32,
        /*
         * vertical refresh rate in mHz
         */
        refresh: i32,
    ),

    /*
     * sent all information about output
     * This event is sent after all other properties have been
     * sent after binding to the output object and after any
     * other property changes done after that. This allows
     * changes to the output properties to be seen as
     * atomic, even if they happen via multiple events.
     */
    done: proc(
        data: rawptr,
        output: ^Output,
    ),

    /*
     * output scaling properties
     * This event contains scaling geometry information
     * that is not in the geometry event. It may be sent after
     * binding the output object or if the output scale changes
     * later. The compositor will emit a non-zero, positive
     * value for scale. If it is not sent, the client should
     * assume a scale of 1.
     * 
     * A scale larger than 1 means that the compositor will
     * automatically scale surface buffers by this amount
     * when rendering. This is used for very high resolution
     * displays where applications rendering at the native
     * resolution would be too small to be legible.
     * 
     * Clients should use wl_surface.preferred_buffer_scale
     * instead of this event to find the preferred buffer
     * scale to use for a surface.
     * 
     * The scale event will be followed by a done event.
     */
    scale: proc(
        data: rawptr,
        output: ^Output,
        /*
         * scaling factor of output
         */
        factor: i32,
    ),

    /*
     * name of this output
     * Many compositors will assign user-friendly names to their outputs, show
     * them to the user, allow the user to refer to an output, etc. The client
     * may wish to know this name as well to offer the user similar behaviors.
     * 
     * The name is a UTF-8 string with no convention defined for its contents.
     * Each name is unique among all wl_output globals. The name is only
     * guaranteed to be unique for the compositor instance.
     * 
     * The same output name is used for all clients for a given wl_output
     * global. Thus, the name can be shared across processes to refer to a
     * specific wl_output global.
     * 
     * The name is not guaranteed to be persistent across sessions, thus cannot
     * be used to reliably identify an output in e.g. configuration files.
     * 
     * Examples of names include 'HDMI-A-1', 'WL-1', 'X11-1', etc. However, do
     * not assume that the name is a reflection of an underlying DRM connector,
     * X11 connection, etc.
     * 
     * The name event is sent after binding the output object. This event is
     * only sent once per output object, and the name does not change over the
     * lifetime of the wl_output global.
     * 
     * Compositors may re-use the same output name if the wl_output global is
     * destroyed and re-created later. Compositors should avoid re-using the
     * same name if possible.
     * 
     * The name event will be followed by a done event.
     */
    name: proc(
        data: rawptr,
        output: ^Output,
        /*
         * output name
         */
        name: cstring,
    ),

    /*
     * human-readable description of this output
     * Many compositors can produce human-readable descriptions of their
     * outputs. The client may wish to know this description as well, e.g. for
     * output selection purposes.
     * 
     * The description is a UTF-8 string with no convention defined for its
     * contents. The description is not guaranteed to be unique among all
     * wl_output globals. Examples might include 'Foocorp 11" Display' or
     * 'Virtual X11 output via :1'.
     * 
     * The description event is sent after binding the output object and
     * whenever the description changes. The description is optional, and may
     * not be sent at all.
     * 
     * The description event will be followed by a done event.
     */
    description: proc(
        data: rawptr,
        output: ^Output,
        /*
         * output description
         */
        description: cstring,
    ),

}

output_add_listener :: #force_inline proc(output: ^Output, listener: ^Output_Listener, data: rawptr) -> i32 {
    return proxy_add_listener(
        cast(^Proxy)output,
        rawptr(listener),
        data
    )
}
output_set_user_data :: #force_inline proc(output: ^Output, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)output,
        user_data
    )
}
output_get_user_data :: #force_inline proc(output: ^Output) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)output)
}
output_get_version :: #force_inline proc(output: ^Output) -> u32 {
    return proxy_get_version(cast(^Proxy)output);
}

OUTPUT_RELEASE :: 0

/*
 * release the output object
 * Using this request a client can tell the server that it is not going to
 * use the output object anymore.
 */
output_release :: #force_inline proc(
    output: ^Output,
) {
    proxy_marshal_flags(
        cast(^Proxy)output,
        OUTPUT_RELEASE,
        nil,
        1,
        {},
    )
}



region_set_user_data :: #force_inline proc(region: ^Region, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)region,
        user_data
    )
}
region_get_user_data :: #force_inline proc(region: ^Region) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)region)
}
region_get_version :: #force_inline proc(region: ^Region) -> u32 {
    return proxy_get_version(cast(^Proxy)region);
}

REGION_DESTROY :: 0
REGION_ADD :: 1
REGION_SUBTRACT :: 2

/*
 * destroy region
 * Destroy the region.  This will invalidate the object ID.
 */
region_destroy :: #force_inline proc(
    region: ^Region,
) {
    proxy_marshal_flags(
        cast(^Proxy)region,
        REGION_DESTROY,
        nil,
        1,
        {},
    )
}

/*
 * add rectangle to region
 * Add the specified rectangle to the region.
 */
region_add :: #force_inline proc(
    region: ^Region,
    /*
     * region-local x coordinate
     */
    x: i32,
    /*
     * region-local y coordinate
     */
    y: i32,
    /*
     * rectangle width
     */
    width: i32,
    /*
     * rectangle height
     */
    height: i32,
) {
    proxy_marshal_flags(
        cast(^Proxy)region,
        REGION_ADD,
        nil,
        1,
        {},
        x,
        y,
        width,
        height,
    )
}

/*
 * subtract rectangle from region
 * Subtract the specified rectangle from the region.
 */
region_subtract :: #force_inline proc(
    region: ^Region,
    /*
     * region-local x coordinate
     */
    x: i32,
    /*
     * region-local y coordinate
     */
    y: i32,
    /*
     * rectangle width
     */
    width: i32,
    /*
     * rectangle height
     */
    height: i32,
) {
    proxy_marshal_flags(
        cast(^Proxy)region,
        REGION_SUBTRACT,
        nil,
        1,
        {},
        x,
        y,
        width,
        height,
    )
}


Subcompositor_Error :: enum {
    /*
     * the to-be sub-surface is invalid
     */
    Bad_Surface = 0,
    /*
     * the to-be sub-surface parent is invalid
     */
    Bad_Parent = 1,
}


subcompositor_set_user_data :: #force_inline proc(subcompositor: ^Subcompositor, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)subcompositor,
        user_data
    )
}
subcompositor_get_user_data :: #force_inline proc(subcompositor: ^Subcompositor) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)subcompositor)
}
subcompositor_get_version :: #force_inline proc(subcompositor: ^Subcompositor) -> u32 {
    return proxy_get_version(cast(^Proxy)subcompositor);
}

SUBCOMPOSITOR_DESTROY :: 0
SUBCOMPOSITOR_GET_SUBSURFACE :: 1

/*
 * unbind from the subcompositor interface
 * Informs the server that the client will not be using this
 * protocol object anymore. This does not affect any other
 * objects, wl_subsurface objects included.
 */
subcompositor_destroy :: #force_inline proc(
    subcompositor: ^Subcompositor,
) {
    proxy_marshal_flags(
        cast(^Proxy)subcompositor,
        SUBCOMPOSITOR_DESTROY,
        nil,
        1,
        {},
    )
}

/*
 * give a surface the role sub-surface
 * Create a sub-surface interface for the given surface, and
 * associate it with the given parent surface. This turns a
 * plain wl_surface into a sub-surface.
 * 
 * The to-be sub-surface must not already have another role, and it
 * must not have an existing wl_subsurface object. Otherwise the
 * bad_surface protocol error is raised.
 * 
 * Adding sub-surfaces to a parent is a double-buffered operation on the
 * parent (see wl_surface.commit). The effect of adding a sub-surface
 * becomes visible on the next time the state of the parent surface is
 * applied.
 * 
 * The parent surface must not be one of the child surface's descendants,
 * and the parent must be different from the child surface, otherwise the
 * bad_parent protocol error is raised.
 * 
 * This request modifies the behaviour of wl_surface.commit request on
 * the sub-surface, see the documentation on wl_subsurface interface.
 */
subcompositor_get_subsurface :: #force_inline proc(
    subcompositor: ^Subcompositor,
    /*
     * the surface to be turned into a sub-surface
     */
    surface: ^Surface,
    /*
     * the parent surface
     */
    parent: ^Surface,
) -> ^Subsurface {
    return cast(^Subsurface)proxy_marshal_flags(
        cast(^Proxy)subcompositor,
        SUBCOMPOSITOR_GET_SUBSURFACE,
        &subsurface_interface,
        proxy_get_version(cast(^Proxy)subcompositor),
        {},
        nil,
        surface,
        parent,
    )
}


Subsurface_Error :: enum {
    /*
     * wl_surface is not a sibling or the parent
     */
    Bad_Surface = 0,
}


subsurface_set_user_data :: #force_inline proc(subsurface: ^Subsurface, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)subsurface,
        user_data
    )
}
subsurface_get_user_data :: #force_inline proc(subsurface: ^Subsurface) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)subsurface)
}
subsurface_get_version :: #force_inline proc(subsurface: ^Subsurface) -> u32 {
    return proxy_get_version(cast(^Proxy)subsurface);
}

SUBSURFACE_DESTROY :: 0
SUBSURFACE_SET_POSITION :: 1
SUBSURFACE_PLACE_ABOVE :: 2
SUBSURFACE_PLACE_BELOW :: 3
SUBSURFACE_SET_SYNC :: 4
SUBSURFACE_SET_DESYNC :: 5

/*
 * remove sub-surface interface
 * The sub-surface interface is removed from the wl_surface object
 * that was turned into a sub-surface with a
 * wl_subcompositor.get_subsurface request. The wl_surface's association
 * to the parent is deleted. The wl_surface is unmapped immediately.
 */
subsurface_destroy :: #force_inline proc(
    subsurface: ^Subsurface,
) {
    proxy_marshal_flags(
        cast(^Proxy)subsurface,
        SUBSURFACE_DESTROY,
        nil,
        1,
        {},
    )
}

/*
 * reposition the sub-surface
 * This schedules a sub-surface position change.
 * The sub-surface will be moved so that its origin (top left
 * corner pixel) will be at the location x, y of the parent surface
 * coordinate system. The coordinates are not restricted to the parent
 * surface area. Negative values are allowed.
 * 
 * The scheduled coordinates will take effect whenever the state of the
 * parent surface is applied.
 * 
 * If more than one set_position request is invoked by the client before
 * the commit of the parent surface, the position of a new request always
 * replaces the scheduled position from any previous request.
 * 
 * The initial position is 0, 0.
 */
subsurface_set_position :: #force_inline proc(
    subsurface: ^Subsurface,
    /*
     * x coordinate in the parent surface
     */
    x: i32,
    /*
     * y coordinate in the parent surface
     */
    y: i32,
) {
    proxy_marshal_flags(
        cast(^Proxy)subsurface,
        SUBSURFACE_SET_POSITION,
        nil,
        1,
        {},
        x,
        y,
    )
}

/*
 * restack the sub-surface
 * This sub-surface is taken from the stack, and put back just
 * above the reference surface, changing the z-order of the sub-surfaces.
 * The reference surface must be one of the sibling surfaces, or the
 * parent surface. Using any other surface, including this sub-surface,
 * will cause a protocol error.
 * 
 * The z-order is double-buffered. Requests are handled in order and
 * applied immediately to a pending state. The final pending state is
 * copied to the active state the next time the state of the parent
 * surface is applied.
 * 
 * A new sub-surface is initially added as the top-most in the stack
 * of its siblings and parent.
 */
subsurface_place_above :: #force_inline proc(
    subsurface: ^Subsurface,
    /*
     * the reference surface
     */
    sibling: ^Surface,
) {
    proxy_marshal_flags(
        cast(^Proxy)subsurface,
        SUBSURFACE_PLACE_ABOVE,
        nil,
        1,
        {},
        sibling,
    )
}

/*
 * restack the sub-surface
 * The sub-surface is placed just below the reference surface.
 * See wl_subsurface.place_above.
 */
subsurface_place_below :: #force_inline proc(
    subsurface: ^Subsurface,
    /*
     * the reference surface
     */
    sibling: ^Surface,
) {
    proxy_marshal_flags(
        cast(^Proxy)subsurface,
        SUBSURFACE_PLACE_BELOW,
        nil,
        1,
        {},
        sibling,
    )
}

/*
 * set sub-surface to synchronized mode
 * Change the commit behaviour of the sub-surface to synchronized
 * mode, also described as the parent dependent mode.
 * 
 * In synchronized mode, wl_surface.commit on a sub-surface will
 * accumulate the committed state in a cache, but the state will
 * not be applied and hence will not change the compositor output.
 * The cached state is applied to the sub-surface immediately after
 * the parent surface's state is applied. This ensures atomic
 * updates of the parent and all its synchronized sub-surfaces.
 * Applying the cached state will invalidate the cache, so further
 * parent surface commits do not (re-)apply old state.
 * 
 * See wl_subsurface for the recursive effect of this mode.
 */
subsurface_set_sync :: #force_inline proc(
    subsurface: ^Subsurface,
) {
    proxy_marshal_flags(
        cast(^Proxy)subsurface,
        SUBSURFACE_SET_SYNC,
        nil,
        1,
        {},
    )
}

/*
 * set sub-surface to desynchronized mode
 * Change the commit behaviour of the sub-surface to desynchronized
 * mode, also described as independent or freely running mode.
 * 
 * In desynchronized mode, wl_surface.commit on a sub-surface will
 * apply the pending state directly, without caching, as happens
 * normally with a wl_surface. Calling wl_surface.commit on the
 * parent surface has no effect on the sub-surface's wl_surface
 * state. This mode allows a sub-surface to be updated on its own.
 * 
 * If cached state exists when wl_surface.commit is called in
 * desynchronized mode, the pending state is added to the cached
 * state, and applied as a whole. This invalidates the cache.
 * 
 * Note: even if a sub-surface is set to desynchronized, a parent
 * sub-surface may override it to behave as synchronized. For details,
 * see wl_subsurface.
 * 
 * If a surface's parent surface behaves as desynchronized, then
 * the cached state is applied on set_desync.
 */
subsurface_set_desync :: #force_inline proc(
    subsurface: ^Subsurface,
) {
    proxy_marshal_flags(
        cast(^Proxy)subsurface,
        SUBSURFACE_SET_DESYNC,
        nil,
        1,
        {},
    )
}



fixes_set_user_data :: #force_inline proc(fixes: ^Fixes, user_data: rawptr) {
	proxy_set_user_data(
        cast(^Proxy)fixes,
        user_data
    )
}
fixes_get_user_data :: #force_inline proc(fixes: ^Fixes) -> rawptr {
	return proxy_get_user_data(cast(^Proxy)fixes)
}
fixes_get_version :: #force_inline proc(fixes: ^Fixes) -> u32 {
    return proxy_get_version(cast(^Proxy)fixes);
}

FIXES_DESTROY :: 0
FIXES_DESTROY_REGISTRY :: 1

/*
 * destroys this object
 */
fixes_destroy :: #force_inline proc(
    fixes: ^Fixes,
) {
    proxy_marshal_flags(
        cast(^Proxy)fixes,
        FIXES_DESTROY,
        nil,
        1,
        {},
    )
}

/*
 * destroy a wl_registry
 * This request destroys a wl_registry object.
 * 
 * The client should no longer use the wl_registry after making this
 * request.
 * 
 * The compositor will emit a wl_display.delete_id event with the object ID
 * of the registry and will no longer emit any events on the registry. The
 * client should re-use the object ID once it receives the
 * wl_display.delete_id event.
 */
fixes_destroy_registry :: #force_inline proc(
    fixes: ^Fixes,
    /*
     * the registry to destroy
     */
    registry: ^Registry,
) {
    proxy_marshal_flags(
        cast(^Proxy)fixes,
        FIXES_DESTROY_REGISTRY,
        nil,
        1,
        {},
        registry,
    )
}


