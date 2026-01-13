package main

import imgui "lib:imgui"
import imgui_rl "lib:imgui/imgui_impl_raylib"
import "core:fmt"
import rl "vendor:raylib"


init :: proc() {
	rl.SetConfigFlags({rl.ConfigFlag.WINDOW_RESIZABLE})
	rl.InitWindow(800, 600, "app")
	rl.SetTargetFPS(60)
    rl.InitAudioDevice()
}

on_exit :: proc() {
	rl.CloseWindow()
}

main :: proc() {
    init()
    defer on_exit()

	imgui.CreateContext(nil)
	defer imgui.DestroyContext(nil)
	imgui_rl.init()
	defer imgui_rl.shutdown()
	imgui_rl.build_font_atlas()
	
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		imgui_rl.process_events()
		imgui_rl.new_frame()
		imgui.NewFrame()
		
		// YOUR CODE HERE
		
		imgui.Render()
		imgui_rl.render_draw_data(imgui.GetDrawData())
		rl.EndDrawing()
	}
}

