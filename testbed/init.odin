package testbed

import "core:fmt"

@(export, link_name="game_init")
init :: proc() {
    fmt.println("Hello world!")
}

@(export, link_name="game_update")
update :: proc() {
    fmt.println("Updating...")
}

@(export, link_name="game_deinit")
deinit :: proc() {
    fmt.println("Bye world!")
}
