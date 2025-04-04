/*
* Copyright © 2012 Intel Corporation
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
*
* Author: Daniel Stone <daniel@fooishbar.org>
*/
package xkbcommon

foreign import lib "system:xkbcommon"

XKB_MOD_NAME_SHIFT :: "Shift"
XKB_MOD_NAME_CAPS :: "Lock"
XKB_MOD_NAME_CTRL :: "Control"
XKB_MOD_NAME_ALT :: "Mod1"
XKB_MOD_NAME_NUM :: "Mod2"
XKB_MOD_NAME_LOGO :: "Mod4"

XKB_LED_NAME_CAPS :: "Caps Lock"
XKB_LED_NAME_NUM :: "Num Lock"
XKB_LED_NAME_SCROLL :: "Scroll Lock"
