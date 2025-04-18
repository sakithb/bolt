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

/**
* @struct xkb_compose_table
* Opaque Compose table object.
*
* The compose table holds the definitions of the Compose sequences, as
* gathered from Compose files.  It is immutable.
*/
Compose_Table :: struct {
}

/**
* @struct xkb_compose_state
* Opaque Compose state object.
*
* The compose state maintains state for compose sequence matching, such
* as which possible sequences are being matched, and the position within
* these sequences.  It acts as a simple state machine wherein keysyms are
* the input, and composed keysyms and strings are the output.
*
* The compose state is usually associated with a keyboard device.
*/
Compose_State :: struct {
}

/** Flags affecting Compose file compilation. */
Compose_Compile_Flags :: enum c.int {
	/** Do not apply any flags. */
	XKB_COMPOSE_COMPILE_NO_FLAGS = 0,
}

/** The recognized Compose file formats. */
Compose_Format :: enum c.int {
	/** The classic libX11 Compose text format, described in Compose(5). */
	XKB_COMPOSE_FORMAT_TEXT_V1 = 1,
}

/**
* @struct xkb_compose_table_entry
* Opaque Compose table entry object.
*
* Represents a single entry in a Compose file in the iteration API.
* It is immutable.
*
* @sa xkb_compose_table_iterator_new
* @since 1.6.0
*/
Compose_Table_Entry :: struct {
}

/**
* @struct xkb_compose_table_iterator
* Iterator over a compose table’s entries.
*
* @sa xkb_compose_table_iterator_new()
* @since 1.6.0
*/
Compose_Table_Iterator :: struct {
}

/** Flags for compose state creation. */
Compose_State_Flags :: enum c.int {
	/** Do not apply any flags. */
	XKB_COMPOSE_STATE_NO_FLAGS = 0,
}

/** Status of the Compose sequence state machine. */
Compose_Status :: enum c.int {
	/** The initial state; no sequence has started yet. */
	NOTHING,

	/** In the middle of a sequence. */
	COMPOSING,

	/** A complete sequence has been matched. */
	COMPOSED,

	/** The last sequence was cancelled due to an unmatched keysym. */
	CANCELLED,
}

/** The effect of a keysym fed to xkb_compose_state_feed(). */
Compose_Feed_Result :: enum c.int {
	/** The keysym had no effect - it did not affect the status. */
	IGNORED,

	/** The keysym started, advanced or cancelled a sequence. */
	ACCEPTED,
}

@(default_calling_convention="c", link_prefix="xkb_")
foreign lib {
	/**
	* Create a compose table for a given locale.
	*
	* The locale is used for searching the file-system for an appropriate
	* Compose file.  The search order is described in Compose(5).  It is
	* affected by the following environment variables:
	*
	* 1. `XCOMPOSEFILE` - see Compose(5).
	* 2. `XDG_CONFIG_HOME` - before `$HOME/.XCompose` is checked,
	*    `$XDG_CONFIG_HOME/XCompose` is checked (with a fall back to
	*    `$HOME/.config/XCompose` if `XDG_CONFIG_HOME` is not defined).
	*    This is a libxkbcommon extension to the search procedure in
	*    Compose(5) (since libxkbcommon 1.0.0). Note that other
	*    implementations, such as libX11, might not find a Compose file in
	*    this path.
	* 3. `HOME` - see Compose(5).
	* 4. `XLOCALEDIR` - if set, used as the base directory for the system's
	*    X locale files, e.g. `/usr/share/X11/locale`, instead of the
	*    preconfigured directory.
	*
	* @param context
	*     The library context in which to create the compose table.
	* @param locale
	*     The current locale.  See @ref compose-locale.
	*     \n
	*     The value is copied, so it is safe to pass the result of getenv(3)
	*     (or similar) without fear of it being invalidated by a subsequent
	*     setenv(3) (or similar).
	* @param flags
	*     Optional flags for the compose table, or 0.
	*
	* @returns A compose table for the given locale, or NULL if the
	* compilation failed or a Compose file was not found.
	*
	* @memberof xkb_compose_table
	*/
	compose_table_new_from_locale :: proc(_context: ^Context, locale: cstring, flags: Compose_Compile_Flags) -> ^Compose_Table ---

	/**
	* Create a new compose table from a Compose file.
	*
	* @param context
	*     The library context in which to create the compose table.
	* @param file
	*     The Compose file to compile.
	* @param locale
	*     The current locale.  See @ref compose-locale.
	* @param format
	*     The text format of the Compose file to compile.
	* @param flags
	*     Optional flags for the compose table, or 0.
	*
	* @returns A compose table compiled from the given file, or NULL if
	* the compilation failed.
	*
	* @memberof xkb_compose_table
	*/
	compose_table_new_from_file :: proc(_context: ^Context, file: ^c.FILE, locale: cstring, format: Compose_Format, flags: Compose_Compile_Flags) -> ^Compose_Table ---

	/**
	* Create a new compose table from a memory buffer.
	*
	* This is just like xkb_compose_table_new_from_file(), but instead of
	* a file, gets the table as one enormous string.
	*
	* @see xkb_compose_table_new_from_file()
	* @memberof xkb_compose_table
	*/
	compose_table_new_from_buffer :: proc(_context: ^Context, buffer: cstring, length: uint, locale: cstring, format: Compose_Format, flags: Compose_Compile_Flags) -> ^Compose_Table ---

	/**
	* Take a new reference on a compose table.
	*
	* @returns The passed in object.
	*
	* @memberof xkb_compose_table
	*/
	compose_table_ref :: proc(table: ^Compose_Table) -> ^Compose_Table ---

	/**
	* Release a reference on a compose table, and possibly free it.
	*
	* @param table The object.  If it is NULL, this function does nothing.
	*
	* @memberof xkb_compose_table
	*/
	compose_table_unref :: proc(table: ^Compose_Table) ---

	/**
	* Get the left-hand keysym sequence of a Compose table entry.
	*
	* For example, given the following entry:
	*
	* ```
	* <dead_tilde> <space> : "~" asciitilde # TILDE
	* ```
	*
	* it will return `{XKB_KEY_dead_tilde, XKB_KEY_space}`.
	*
	* @param[in]  entry The compose table entry object to process.
	*
	* @param[out] sequence_length Number of keysyms in the sequence.
	*
	* @returns The array of left-hand side keysyms.  The number of keysyms
	* is returned in the @p sequence_length out-parameter.
	*
	* @memberof xkb_compose_table_entry
	* @since 1.6.0
	*/
	compose_table_entry_sequence :: proc(entry: ^Compose_Table_Entry, sequence_length: ^uint) -> ^Keysym ---

	/**
	* Get the right-hand result keysym of a Compose table entry.
	*
	* For example, given the following entry:
	*
	* ```
	* <dead_tilde> <space> : "~" asciitilde # TILDE
	* ```
	*
	* it will return `XKB_KEY_asciitilde`.
	*
	* The keysym is optional; if the entry does not specify a keysym,
	* returns `XKB_KEY_NoSymbol`.
	*
	* @memberof xkb_compose_table_entry
	* @since 1.6.0
	*/
	compose_table_entry_keysym :: proc(entry: ^Compose_Table_Entry) -> Keysym ---

	/**
	* Get the right-hand result string of a Compose table entry.
	*
	* The string is UTF-8 encoded and NULL-terminated.
	*
	* For example, given the following entry:
	*
	* ```
	* <dead_tilde> <space> : "~" asciitilde # TILDE
	* ```
	*
	* it will return `"~"`.
	*
	* The string is optional; if the entry does not specify a string,
	* returns the empty string.
	*
	* @memberof xkb_compose_table_entry
	* @since 1.6.0
	*/
	compose_table_entry_utf8 :: proc(entry: ^Compose_Table_Entry) -> cstring ---

	/**
	* Create a new iterator for a compose table.
	*
	* Intended use:
	*
	* ```c
	* struct xkb_compose_table_iterator *iter = xkb_compose_table_iterator_new(compose_table);
	* struct xkb_compose_table_entry *entry;
	* while ((entry = xkb_compose_table_iterator_next(iter))) {
	*     // ...
	* }
	* xkb_compose_table_iterator_free(iter);
	* ```
	*
	* @returns A new compose table iterator, or `NULL` on failure.
	*
	* @memberof xkb_compose_table_iterator
	* @sa xkb_compose_table_iterator_free()
	* @since 1.6.0
	*/
	compose_table_iterator_new :: proc(table: ^Compose_Table) -> ^Compose_Table_Iterator ---

	/**
	* Free a compose iterator.
	*
	* @memberof xkb_compose_table_iterator
	* @since 1.6.0
	*/
	compose_table_iterator_free :: proc(iter: ^Compose_Table_Iterator) ---

	/**
	* Get the next compose entry from a compose table iterator.
	*
	* The entries are returned in lexicographic order of the left-hand
	* side of entries. This does not correspond to the order in which
	* the entries appear in the Compose file.
	*
	* @attention The return value is valid until the next call to this function.
	*
	* Returns `NULL` in case there is no more entries.
	*
	* @memberof xkb_compose_table_iterator
	* @since 1.6.0
	*/
	compose_table_iterator_next :: proc(iter: ^Compose_Table_Iterator) -> ^Compose_Table_Entry ---

	/**
	* Create a new compose state object.
	*
	* @param table
	*     The compose table the state will use.
	* @param flags
	*     Optional flags for the compose state, or 0.
	*
	* @returns A new compose state, or NULL on failure.
	*
	* @memberof xkb_compose_state
	*/
	compose_state_new :: proc(table: ^Compose_Table, flags: Compose_State_Flags) -> ^Compose_State ---

	/**
	* Take a new reference on a compose state object.
	*
	* @returns The passed in object.
	*
	* @memberof xkb_compose_state
	*/
	compose_state_ref :: proc(state: ^Compose_State) -> ^Compose_State ---

	/**
	* Release a reference on a compose state object, and possibly free it.
	*
	* @param state The object.  If NULL, do nothing.
	*
	* @memberof xkb_compose_state
	*/
	compose_state_unref :: proc(state: ^Compose_State) ---

	/**
	* Get the compose table which a compose state object is using.
	*
	* @returns The compose table which was passed to xkb_compose_state_new()
	* when creating this state object.
	*
	* This function does not take a new reference on the compose table; you
	* must explicitly reference it yourself if you plan to use it beyond the
	* lifetime of the state.
	*
	* @memberof xkb_compose_state
	*/
	compose_state_get_compose_table :: proc(state: ^Compose_State) -> ^Compose_Table ---

	/**
	* Feed one keysym to the Compose sequence state machine.
	*
	* This function can advance into a compose sequence, cancel a sequence,
	* start a new sequence, or do nothing in particular.  The resulting
	* status may be observed with xkb_compose_state_get_status().
	*
	* Some keysyms, such as keysyms for modifier keys, are ignored - they
	* have no effect on the status or otherwise.
	*
	* The following is a description of the possible status transitions, in
	* the format CURRENT STATUS => NEXT STATUS, given a non-ignored input
	* keysym `keysym`:
	*
	@verbatim
	NOTHING or CANCELLED or COMPOSED =>
	NOTHING   if keysym does not start a sequence.
	COMPOSING if keysym starts a sequence.
	COMPOSED  if keysym starts and terminates a single-keysym sequence.
	
	COMPOSING =>
	COMPOSING if keysym advances any of the currently possible
	sequences but does not terminate any of them.
	COMPOSED  if keysym terminates one of the currently possible
	sequences.
	CANCELLED if keysym does not advance any of the currently
	possible sequences.
	@endverbatim
	*
	* The current Compose formats do not support multiple-keysyms.
	* Therefore, if you are using a function such as xkb_state_key_get_syms()
	* and it returns more than one keysym, consider feeding XKB_KEY_NoSymbol
	* instead.
	*
	* @param state
	*     The compose state object.
	* @param keysym
	*     A keysym, usually obtained after a key-press event, with a
	*     function such as xkb_state_key_get_one_sym().
	*
	* @returns Whether the keysym was ignored.  This is useful, for example,
	* if you want to keep a record of the sequence matched thus far.
	*
	* @memberof xkb_compose_state
	*/
	compose_state_feed :: proc(state: ^Compose_State, keysym: Keysym) -> Compose_Feed_Result ---

	/**
	* Reset the Compose sequence state machine.
	*
	* The status is set to XKB_COMPOSE_NOTHING, and the current sequence
	* is discarded.
	*
	* @memberof xkb_compose_state
	*/
	compose_state_reset :: proc(state: ^Compose_State) ---

	/**
	* Get the current status of the compose state machine.
	*
	* @see xkb_compose_status
	* @memberof xkb_compose_state
	**/
	compose_state_get_status :: proc(state: ^Compose_State) -> Compose_Status ---

	/**
	* Get the result Unicode/UTF-8 string for a composed sequence.
	*
	* See @ref compose-overview for more details.  This function is only
	* useful when the status is XKB_COMPOSE_COMPOSED.
	*
	* @param[in] state
	*     The compose state.
	* @param[out] buffer
	*     A buffer to write the string into.
	* @param[in] size
	*     Size of the buffer.
	*
	* @warning If the buffer passed is too small, the string is truncated
	* (though still NUL-terminated).
	*
	* @returns
	*   The number of bytes required for the string, excluding the NUL byte.
	*   If the sequence is not complete, or does not have a viable result
	*   string, returns 0, and sets `buffer` to the empty string (if possible).
	* @returns
	*   You may check if truncation has occurred by comparing the return value
	*   with the size of `buffer`, similarly to the `snprintf`(3) function.
	*   You may safely pass NULL and 0 to `buffer` and `size` to find the
	*   required size (without the NUL-byte).
	*
	* @memberof xkb_compose_state
	**/
	compose_state_get_utf8 :: proc(state: ^Compose_State, buffer: cstring, size: uint) -> i32 ---

	/**
	* Get the result keysym for a composed sequence.
	*
	* See @ref compose-overview for more details.  This function is only
	* useful when the status is XKB_COMPOSE_COMPOSED.
	*
	* @returns The result keysym.  If the sequence is not complete, or does
	* not specify a result keysym, returns XKB_KEY_NoSymbol.
	*
	* @memberof xkb_compose_state
	**/
	compose_state_get_one_sym :: proc(state: ^Compose_State) -> Keysym ---
}
