package bolt

import "core:log"
import "core:mem"
import "core:time"
import "core:math/linalg"
import "base:runtime"

import "bolt:renderer"
import "bolt:events"
import "bolt:platform"

INIT_WIDTH :: #config(INIT_WIDTH, 1280)
INIT_HEIGHT :: #config(INIT_WIDTH, 720)

Game_Api :: struct {
    init: proc(),
    update: proc(delta_time: f32, elapsed_time: time.Duration),
    deinit: proc(),
}

Bolt_Errs :: enum {
    None,
}

Bolt_Err :: union  #shared_nil {
    Bolt_Errs,
    runtime.Allocator_Error
}

start :: proc(game_api: Game_Api) {
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

    if !platform.init(INIT_WIDTH, INIT_HEIGHT) do log.panic("Could not init platform layer")
    defer platform.deinit()

    if err := events.init(); err != nil do log.panicf("Could not init event subsystem: %v", err)
    defer if err := events.deinit(); err != nil do log.panic("Could not de-init event subsystem: %v", err)

    if err := renderer.init({"Test", 0, 1, 0}); err != nil do log.panic("Could not init renderer subsystem: %v")
    defer renderer.deinit()

    game_api.init()
    defer game_api.deinit()

    delta_time: f32
    start_time := time.tick_now()
    last_time := start_time

    for !platform.win_should_close() {
        now := time.tick_now()
        delta_time = f32(time.tick_diff(last_time, now)) / f32(time.Second)
        last_time = now

        game_api.update(delta_time, time.tick_diff(start_time, now))

        if err := renderer.draw_begin(); err != nil {
            log.panicf("could not begin drawing: %v", err)
        }

        for &entity in entities {
            renderer.mesh_draw(entity.mesh, renderer.Push_Consts{linalg.matrix4_translate(entity.position)})
        }

        if err := renderer.draw_end(); err != nil {
            log.panicf("could not end drawing: %v", err)
        }

        platform.win_poll_events()
    }
}
