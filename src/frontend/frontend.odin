package frontend

import "core:encoding/hex"
import "base:intrinsics"
import "core:mem"
import "core:math/rand"
import "core:fmt"
import "core:c"
import im "lib:imgui"
import cpu_pkg "src:backend/cpu"
import "src:helper/dump"

TABLE_FLAGS :: im.TableFlags_Resizable | im.TableFlags_BordersOuter | im.TableFlags_RowBg  | im.TableFlags_ContextMenuInBody // | im.TableFlags_SizingFixedFit | im.TableFlags_NoHostExtendX

screen :: proc(cpu: ^cpu_pkg.CPU, allocator := context.allocator) { 
	im.Begin("Screen")
	defer im.End()

    dl := im.GetWindowDrawList()
    origin := im.GetCursorScreenPos()

    height := 128
    width := 128
    pixel_size: f32 = 2
    for y in 0..<height {
        for x in 0..<width {
            pos: im.Vec2 
            pos.x = origin.x + pixel_size * f32(x)
            pos.y = origin.y + pixel_size * f32(y)
            im.DrawList_AddRectFilled(dl, pos, pos + {pixel_size, pixel_size}, rand.uint32())
        }
    }
}

cpu_debug_menu :: proc(cpu: ^cpu_pkg.CPU, allocator := context.allocator) {
	im.Begin("CPU")
	defer im.End()

    ram_menu(cpu, allocator)

    if im.Button("step") {
        buf: [size_of(cpu_pkg.CPU)]byte
        _ = rand.read(buf[:])

        mem.copy(cpu, &buf, len(buf))
    }

	if im.CollapsingHeader("Registers") {
        @(static) byte_fmt: string = "%2x"
        @(static) two_byte_fmt: string = "%4x"
		@(static) reg_mode: int = 1

        if im.SmallButton("DEC") {
            byte_fmt = "%d"
            two_byte_fmt = "%d"
        }
        im.SameLine()
        if im.SmallButton("BIN") {
            byte_fmt = "%8b"
            two_byte_fmt = "%16b"
        }
        im.SameLine()
        if im.SmallButton("HEX") {
            byte_fmt = "%2x"
            two_byte_fmt = "%4x"
        }

        im.SameLine()
        im.Text("|")
        im.SameLine()

        if im.SmallButton("R|R") do reg_mode = 1
        im.SameLine()
        if im.SmallButton("RR") do reg_mode = 2

        general_regs(cpu, byte_fmt, two_byte_fmt, reg_mode, allocator)
        special_regs(cpu, two_byte_fmt, allocator)
	}
}

special_regs :: proc(cpu: ^cpu_pkg.CPU, two_byte_fmt: string, allocator := context.allocator) {
    im.SeparatorText("Special Registers")
    if im.BeginTable("special_regs", 1, TABLE_FLAGS) {
        defer im.EndTable()

        im.TableNextRow()
        table_item("PC", fmt.caprintf(two_byte_fmt, cpu.pc, allocator = allocator))
        im.TableNextRow()
        table_item("SP", fmt.caprintf(two_byte_fmt, cpu.sp, allocator = allocator))
    }
}

general_regs :: proc(cpu: ^cpu_pkg.CPU, byte_fmt, two_byte_fmt: string, reg_mode: int, allocator := context.allocator) {
    im.SeparatorText("General Purpose Registers")
    if reg_mode == 1 {
        if im.BeginTable("common_regs", 2, TABLE_FLAGS) {
            defer im.EndTable()

            im.TableNextRow()
            table_item("A", fmt.caprintf(byte_fmt, cpu.a, allocator = allocator))
            table_item("F", fmt.caprintf(byte_fmt, u8(cpu.f), allocator = allocator))
            im.TableNextRow()
            table_item("B", fmt.caprintf(byte_fmt, cpu.b, allocator = allocator))
            table_item("C", fmt.caprintf(byte_fmt, cpu.c, allocator = allocator))
            im.TableNextRow()
            table_item("D", fmt.caprintf(byte_fmt, cpu.d, allocator = allocator))
            table_item("E", fmt.caprintf(byte_fmt, cpu.e, allocator = allocator))
            im.TableNextRow()
            table_item("H", fmt.caprintf(byte_fmt, cpu.h, allocator = allocator))
            table_item("L", fmt.caprintf(byte_fmt, cpu.l, allocator = allocator))
        }
    } else {
        if im.BeginTable("common_regs", 1, TABLE_FLAGS) {
            defer im.EndTable()

            im.TableNextRow()
            table_item("AF", fmt.caprintf(two_byte_fmt, cpu_pkg.get_reg_u16(cpu, .AF), allocator = allocator))
            im.TableNextRow()
            table_item("BC", fmt.caprintf(two_byte_fmt, cpu_pkg.get_reg_u16(cpu, .BC), allocator = allocator))
            im.TableNextRow()
            table_item("DE", fmt.caprintf(two_byte_fmt, cpu_pkg.get_reg_u16(cpu, .DE), allocator = allocator))
            im.TableNextRow()
            table_item("HL", fmt.caprintf(two_byte_fmt, cpu_pkg.get_reg_u16(cpu, .HL), allocator = allocator))
        }
    }
}

table_item :: proc(label, value: cstring) {
    im.TableNextColumn()
    im.Text("%s:", label); im.SameLine()
    im.Text(value)
}

ram_menu :: proc(cpu: ^cpu_pkg.CPU, allocator := context.allocator) {
    im.Begin("RAM")
    defer im.End()

    @(static) from_addr: c.int = 0
    im.DragScalar("addr", .U16, &from_addr, format = "%04X")

    // im.SameLine()
    
    @(static) limit: c.int = 0x200
    im.DragScalar("limit", .U16, &limit)

    dump_text := dump.dump_cstring(cpu.bus.ram[from_addr:from_addr+limit], int(from_addr), allocator = allocator)
    im.TextUnformatted(dump_text)
}
