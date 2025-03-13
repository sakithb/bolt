package bolt

import "core:dynlib"
import "core:log"
import "core:mem"

import "bolt:renderer"
import pl "bolt:platform"

import vk "vendored:vulkan"

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

tmp_vertex_data := [3][5]f32{
    {0.0, -0.5, 1.0, 0.0, 0.0},
    {0.5, 0.5, 0.0, 1.0, 0.0},
    {-0.5, 0.5, 0.0, 0.0, 1.0}
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

    // TODO: width and height
    if !pl.init(INIT_WIDTH, INIT_HEIGHT) do log.panic("Could not init platform layer")
    defer pl.deinit()

    game_api, game_api_ok := load_game_api()
    if !game_api_ok do log.panic("Could not load game library")
    defer if !unload_game_api(game_api) do log.panic("Could not unload game library")

    // Init engine
    renderer_err := renderer.init({"Test", 0, 1, 0})
    if renderer_err != nil do log.panicf("Could not init renderer: %v", renderer_err)
    defer renderer.deinit()

    buf, buf_err := renderer.upload_buffer(tmp_vertex_data[:])
    if buf_err != nil do log.panicf("Could not upload vertices")
    defer renderer.free_buffer(buf)

    // Init game
    game_api.init()
    defer game_api.deinit()

    for !pl.wsi_should_close() {
        game_api.update()

        renderer.draw_begin(renderer.renderer.cmd_buf_tmp)

        vk.CmdBindPipeline(renderer.renderer.cmd_buf_tmp, .GRAPHICS, renderer.renderer.pipeline.hnd)
        vk.CmdBindVertexBuffers(renderer.renderer.cmd_buf_tmp, 0, 1, &buf.hnd, raw_data([]vk.DeviceSize{0}))

        renderer.draw_end(renderer.renderer.cmd_buf_tmp)

        pl.wsi_poll_events()
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
