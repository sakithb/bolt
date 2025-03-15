package bolt

import "core:dynlib"
import "core:log"
import "core:mem"

import "bolt:renderer"
import "bolt:events"
import "bolt:platform"

INIT_WIDTH :: #config(INIT_WIDTH, 1280)
INIT_HEIGHT :: #config(INIT_WIDTH, 720)

GAME_NAME :: #config(GAME_NAME, "testbed")
GAME_LIB :: GAME_NAME + ".so"

Game_Api :: struct {
    init: proc(),
    update: proc(),
    deinit: proc(),

    library: dynlib.Library
}

tmp_vertex_data := [?]f32{
    0.0, -0.5, 1.0, 0.0, 0.0,
    0.5, 0.5, 0.0, 1.0, 0.0,
    -0.5, 0.5, 0.0, 0.0, 1.0
}

main :: proc() {
    when ODIN_DEBUG {
        console_logger := log.create_console_logger()
        context.logger = console_logger
        defer log.destroy_console_logger(console_logger)

		tracking_alloc: mem.Tracking_Allocator
		mem.tracking_allocator_init(&tracking_alloc, context.allocator)
		context.allocator = mem.tracking_allocator(&tracking_alloc)
        defer {
            if len(tracking_alloc.allocation_map) > 0 {
                log.fatalf("%v allocations not freed:\n", len(tracking_alloc.allocation_map))
                for _, entry in tracking_alloc.allocation_map {
                    log.fatalf(" - %v bytes @ %v\n", entry.size, entry.location)
                }
            }

            if len(tracking_alloc.bad_free_array) > 0 {
                log.fatalf("%v incorrect frees:\n", len(tracking_alloc.bad_free_array))
                for entry in tracking_alloc.bad_free_array {
                    log.fatalf(" - %p @ %v\n", entry.memory, entry.location)
                }
            }

            mem.tracking_allocator_destroy(&tracking_alloc)
        }
	}

    game_api := load_game_api() or_else log.panic("Could not load game library")
    defer if !unload_game_api(game_api) do log.panic("Could not unload game library")

    if !platform.init(INIT_WIDTH, INIT_HEIGHT) do log.panic("Could not init platform layer")
    defer platform.deinit()

    if err := events.init(); err != nil do log.panicf("Could not init event subsystem: %v", err)
    defer if err := events.deinit(); err != nil do log.panic("Could not de-init event subsystem: %v", err)

    if err := renderer.init({"Test", 0, 1, 0}); err != nil do log.panic("Could not init renderer subsystem: %v")
    defer renderer.deinit()

    tri := renderer.mesh_create(tmp_vertex_data[:], 3) or_else log.panic("Could not create mesh")
    defer renderer.mesh_destroy(&tri)

    game_api.init()
    defer game_api.deinit()

    for !platform.wsi_should_close() {
        game_api.update()

        if err := renderer.draw_begin(); err != nil {
            log.panicf("could not begin drawing: %v", err)
        }

        renderer.mesh_draw(&tri)

        if err := renderer.draw_end(); err != nil {
            log.panicf("could not end drawing: %v", err)
        }

        platform.wsi_poll_events()
    }
}

load_game_api :: proc() -> (api: Game_Api, ok: bool) {
    api.library = dynlib.load_library(GAME_LIB) or_return

    api.init = cast(proc())dynlib.symbol_address(api.library, "game_init") or_return
    api.update = cast(proc())dynlib.symbol_address(api.library, "game_update") or_return
    api.deinit = cast(proc())dynlib.symbol_address(api.library, "game_deinit") or_return

    return api, true
}

unload_game_api :: proc(api: Game_Api) -> bool {
    return dynlib.unload_library(api.library)
}

