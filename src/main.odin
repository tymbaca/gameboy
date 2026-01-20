package main

import "core:strings"
import "core:log"
import "core:mem"
import "core:mem/virtual"
import "core:fmt"
import imgui "lib:imgui"
import imgui_rl "lib:imgui/imgui_impl_raylib"
import rl "vendor:raylib"
import "src:backend/cpu"
import "src:frontend"


init :: proc() {
	rl.SetConfigFlags({rl.ConfigFlag.WINDOW_RESIZABLE})
	rl.InitWindow(1200, 800, "app")
	rl.SetTargetFPS(60)
	rl.InitAudioDevice()
}

on_exit :: proc() {
	rl.CloseWindow()
}

main :: proc() {
	init()
	defer on_exit()

    when ODIN_DEBUG {
		track: mem.Tracking_Allocator
        context.allocator = tracking_allocator(&track, context.allocator)
		defer check_tracking_allocator(&track)
	}

	imgui.CreateContext(nil)
	defer imgui.DestroyContext(nil)
	imgui_rl.init()
	defer imgui_rl.shutdown()
	imgui_rl.build_font_atlas()

    // YOUR CODE HERE
    allocator := context.allocator
    context.allocator = mem.panic_allocator()
    context.temp_allocator = mem.panic_allocator()

    cpu: cpu.CPU
    ctx: frontend.Context
    frontend.context_init(&ctx, &cpu, allocator)
    defer frontend.context_destroy(&ctx)

    buf := make([]u8, 4 * mem.Megabyte, allocator)
    defer delete(buf, allocator)
    arena: mem.Arena
    mem.arena_init(&arena, buf[:])
    frame_allocator := mem.arena_allocator(&arena)
    // YOUR CODE HERE

	for !rl.WindowShouldClose() {
        defer free_all(frame_allocator)

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
        rl.DrawFPS(10, 10)
		imgui_rl.process_events()
		imgui_rl.new_frame()
		imgui.NewFrame()

		// YOUR CODE HERE
        imgui.Begin("mem")
        imgui.Text("arena offset: %d", arena.offset)
        imgui.End()

        frontend.render(&ctx, frame_allocator)
		// YOUR CODE HERE

		imgui.Render()
		imgui_rl.render_draw_data(imgui.GetDrawData())
		rl.EndDrawing()
	}
}

tracking_allocator :: proc(track: ^mem.Tracking_Allocator, allocator := context.allocator) -> mem.Allocator {
    mem.tracking_allocator_init(track, context.allocator)
    return mem.tracking_allocator(track)
}

check_tracking_allocator :: proc(track: ^mem.Tracking_Allocator) {
    if len(track.allocation_map) > 0 {
        fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
        for _, entry in track.allocation_map {
            fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
        }
    }
    mem.tracking_allocator_destroy(track)
}
