/*
* Copyright © 2013 Ran Benita
*
* Permission is hereby granted, free of charge, to any person obtaining a
* copy of this software and associated documentation files (the "Software"),
* to deal in the Software without restriction, including without limitation
* the rights to use, copy, modify, merge, publish, distribute, sublicense,
* and/or sell copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice (including the next
* paragraph) shall be included in all copies or substantial portions of the
* Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
* DEALINGS IN THE SOFTWARE.
*/
package xkbcommon

import "core:c"

_ :: c

foreign import lib "system:xkbcommon"

/** Flags for the xkb_x11_setup_xkb_extension() function. */
X11_Setup_Xkb_Extension_Flags :: enum c.int {
	/** Do not apply any flags. */
	XKB_X11_SETUP_XKB_EXTENSION_NO_FLAGS = 0,
}

Connection :: struct {
}

@(default_calling_convention="c", link_prefix="xkb_")
foreign lib {
	/**
	* Setup the XKB X11 extension for this X client.
	*
	* The xkbcommon-x11 library uses various XKB requests.  Before doing so,
	* an X client must notify the server that it will be using the extension.
	* This function (or an XCB equivalent) must be called before any other
	* function in this library is used.
	*
	* Some X servers may not support or disable the XKB extension.  If you
	* want to support such servers, you need to use a different fallback.
	*
	* You may call this function several times; it is idempotent.
	*
	* @param connection
	*     An XCB connection to the X server.
	* @param major_xkb_version
	*     See @p minor_xkb_version.
	* @param minor_xkb_version
	*     The XKB extension version to request.  To operate correctly, you
	*     must have (major_xkb_version, minor_xkb_version) >=
	*     (XKB_X11_MIN_MAJOR_XKB_VERSION, XKB_X11_MIN_MINOR_XKB_VERSION),
	*     though this is not enforced.
	* @param flags
	*     Optional flags, or 0.
	* @param[out] major_xkb_version_out
	*     See @p minor_xkb_version_out.
	* @param[out] minor_xkb_version_out
	*     Backfilled with the compatible XKB extension version numbers picked
	*     by the server.  Can be NULL.
	* @param[out] base_event_out
	*     Backfilled with the XKB base (also known as first) event code, needed
	*     to distinguish XKB events.  Can be NULL.
	* @param[out] base_error_out
	*     Backfilled with the XKB base (also known as first) error code, needed
	*     to distinguish XKB errors.  Can be NULL.
	*
	* @returns 1 on success, or 0 on failure.
	*/
	x11_setup_xkb_extension :: proc(connection: ^Connection, major_xkb_version: u16, minor_xkb_version: u16, flags: X11_Setup_Xkb_Extension_Flags, major_xkb_version_out: ^u16, minor_xkb_version_out: ^u16, base_event_out: ^u8, base_error_out: ^u8) -> i32 ---

	/**
	* Get the keyboard device ID of the core X11 keyboard.
	*
	* @param connection An XCB connection to the X server.
	*
	* @returns A device ID which may be used with other xkb_x11_* functions,
	*          or -1 on failure.
	*/
	x11_get_core_keyboard_device_id :: proc(connection: ^Connection) -> i32 ---

	/**
	* Create a keymap from an X11 keyboard device.
	*
	* This function queries the X server with various requests, fetches the
	* details of the active keymap on a keyboard device, and creates an
	* xkb_keymap from these details.
	*
	* @param context
	*     The context in which to create the keymap.
	* @param connection
	*     An XCB connection to the X server.
	* @param device_id
	*     An XInput device ID (in the range 0-127) with input class KEY.
	*     Passing values outside of this range is an error (the XKB protocol
	*     predates the XInput2 protocol, which first allowed IDs > 127).
	* @param flags
	*     Optional flags for the keymap, or 0.
	*
	* @returns A keymap retrieved from the X server, or NULL on failure.
	*
	* @memberof xkb_keymap
	*/
	x11_keymap_new_from_device :: proc(_context: ^Context, connection: ^Connection, device_id: i32, flags: Keymap_Compile_Flags) -> ^Keymap ---

	/**
	* Create a new keyboard state object from an X11 keyboard device.
	*
	* This function is the same as xkb_state_new(), only pre-initialized
	* with the state of the device at the time this function is called.
	*
	* @param keymap
	*     The keymap for which to create the state.
	* @param connection
	*     An XCB connection to the X server.
	* @param device_id
	*     An XInput 1 device ID (in the range 0-255) with input class KEY.
	*     Passing values outside of this range is an error.
	*
	* @returns A new keyboard state object, or NULL on failure.
	*
	* @memberof xkb_state
	*/
	x11_state_new_from_device :: proc(keymap: ^Keymap, connection: ^Connection, device_id: i32) -> ^State ---
}
