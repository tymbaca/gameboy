package frontend

import "core:sys/wasm/js"
import "base:runtime"
import os "core:os/os2"
import "core:strings"
import "core:sys/windows"
import "core:sys/darwin"
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

Context :: struct {
    cpu: ^cpu_pkg.CPU,

    load_rom_path: []u8,
    load_rom_error: string,

    byte_fmt: string,
    two_byte_fmt: string,
	reg_mode: int,

    viewers: [dynamic]Ram_Viewer,
    editors: [dynamic]Ram_Editor,
}

context_init :: proc(ctx: ^Context, cpu: ^cpu_pkg.CPU, allocator: runtime.Allocator) {
    ctx.cpu = cpu

    ctx.load_rom_path = make([]u8, 1024, allocator)

    ctx.byte_fmt = "%2x"
    ctx.two_byte_fmt = "%4x"
    ctx.reg_mode = 1

    ctx.viewers = make([dynamic]Ram_Viewer, allocator)
    ctx.editors = make([dynamic]Ram_Editor, allocator)
}

context_destroy :: proc(ctx: ^Context) {
    delete(ctx.viewers)
    delete(ctx.editors)
}

render :: proc(ctx: ^Context, allocator: runtime.Allocator) {
    render_cpu(ctx, allocator)
    render_ram(ctx, allocator)
    render_screen(ctx.cpu, allocator)
}

render_screen :: proc(cpu: ^cpu_pkg.CPU, allocator: runtime.Allocator) { 
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

render_cpu :: proc(ctx: ^Context, allocator: runtime.Allocator) {
	im.Begin("CPU")
	defer im.End()

    if im.Button("step") {
        buf: [size_of(cpu_pkg.CPU)]byte
        _ = rand.read(buf[:])

        mem.copy(ctx.cpu, &buf, len(buf))
    }

	if im.CollapsingHeader("Registers") {
        if im.SmallButton("DEC") {
            ctx.byte_fmt = "%d"
            ctx.two_byte_fmt = "%d"
        }
        im.SameLine()
        if im.SmallButton("BIN") {
            ctx.byte_fmt = "%8b"
            ctx.two_byte_fmt = "%16b"
        }
        im.SameLine()
        if im.SmallButton("HEX") {
            ctx.byte_fmt = "%2x"
            ctx.two_byte_fmt = "%4x"
        }

        im.SameLine()
        im.Text("|")
        im.SameLine()

        if im.SmallButton("R|R") do ctx.reg_mode = 1
        im.SameLine()
        if im.SmallButton("RR") do ctx.reg_mode = 2

        general_regs(ctx.cpu, ctx.byte_fmt, ctx.two_byte_fmt, ctx.reg_mode, allocator)
        special_regs(ctx.cpu, ctx.two_byte_fmt, allocator)
	}

    im.InputTextWithHint("rom_location", "path to ROM", cstring(raw_data(ctx.load_rom_path)), len(ctx.load_rom_path))
    if im.Button("load ROM") {
        load_rom(ctx, strings.string_from_null_terminated_ptr(raw_data(ctx.load_rom_path), len(ctx.load_rom_path)), allocator)
    }
    if ctx.load_rom_error != "" {
        im.Text("failed to open ROM file: %s", ctx.load_rom_error)
        return
    }
}

load_rom :: proc(ctx: ^Context, path: string, allocator: runtime.Allocator) {
    data, read_err := os.read_entire_file(path, allocator)
    if read_err != nil {
        ctx.load_rom_error = fmt.aprint(read_err, allocator = allocator)
        return
    } 

    ctx.load_rom_error = ""
    cpu_pkg.load_rom(ctx.cpu, data)
}

special_regs :: proc(cpu: ^cpu_pkg.CPU, two_byte_fmt: string, allocator: runtime.Allocator) {
    im.SeparatorText("Special Registers")
    if im.BeginTable("special_regs", 1, TABLE_FLAGS) {
        defer im.EndTable()

        im.TableNextRow()
        table_item("PC", fmt.caprintf(two_byte_fmt, cpu.pc, allocator = allocator))
        im.TableNextRow()
        table_item("SP", fmt.caprintf(two_byte_fmt, cpu.sp, allocator = allocator))
    }
}

general_regs :: proc(cpu: ^cpu_pkg.CPU, byte_fmt, two_byte_fmt: string, reg_mode: int, allocator: runtime.Allocator) {
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

render_ram :: proc(ctx: ^Context, allocator: runtime.Allocator) {
    im.Begin("RAM")
    defer im.End()

    if im.SmallButton("add viewer") {
        append(&ctx.viewers, Ram_Viewer{
            id = len(ctx.viewers),
            cpu = ctx.cpu,
            from_addr = 0,
            limit = 0x200,
        })
    }

    for &viewer in ctx.viewers {
        ram_viewer_render(&viewer, allocator)
    }

    if im.SmallButton("add editor") {
        append(&ctx.editors, Ram_Editor{
            id = len(ctx.editors),
            cpu = ctx.cpu,
            val_fmt = IM_U8_HEX_FMT,
            val_type = .U8,
        })
    }

    for &editor in ctx.editors {
        ram_editor_render(&editor, allocator)
    }
}

Ram_Viewer :: struct {
    id: int,
    cpu: ^cpu_pkg.CPU,
    from_addr: u16,
    limit: u16,
}

ram_viewer_render :: proc(r: ^Ram_Viewer, allocator: runtime.Allocator) {
    id := fmt.caprintf("RAM viewer #%d", r.id, allocator = allocator)
    im.Begin(id)
    defer im.End()

    im.DragScalar("addr", .U16, &r.from_addr, format = IM_U16_HEX_FMT)
    im.DragScalar("limit", .U16, &r.limit)

    im.TextUnformatted(dump.HEADER)
    dump_text := dump.dump_cstring(
        r.cpu.bus.ram[r.from_addr:r.from_addr+r.limit], 
        int(r.from_addr - (r.from_addr % 16)), 
        offset = int(r.from_addr % 16),
        allocator = allocator,
    )
    im.BeginChild(id)
    im.TextUnformatted(dump_text)
    im.EndChild()
}

Ram_Editor :: struct {
    id: int,
    cpu: ^cpu_pkg.CPU,
    addr: u16,
    val: u8,
    val_fmt: cstring,
    val_type: im.DataType,
}

IM_U8_DEC_FMT :: "%d"
IM_U8_HEX_FMT :: "%02X"
IM_U16_DEC_FMT :: "%d"
IM_U16_HEX_FMT :: "%04X"

ram_editor_render :: proc(r: ^Ram_Editor, allocator: runtime.Allocator) {
    im.Begin(fmt.caprintf("RAM editor #%d", r.id, allocator = allocator))
    defer im.End()

    if im.SmallButton("DEC") {
        r.val_fmt = IM_U8_DEC_FMT
    }
    im.SameLine()
    if im.SmallButton("HEX") {
        r.val_fmt = IM_U8_HEX_FMT
    }

    if im.SmallButton("u8") {
        r.val_type = .U8
    }
    im.SameLine()
    if im.SmallButton("i8") {
        r.val_type = .S8
    }

    im.DragScalar("addr", .U16, &r.addr, format = IM_U16_HEX_FMT)
    im.DragScalar("val", r.val_type, &r.val, format = r.val_fmt)

    im.BeginGroup()
    im.Text(fmt.caprintf("bin: %8b", r.val, allocator = allocator))
    im.SameLine()
    im.Text(fmt.caprintf("ascii: %c", r.val, allocator = allocator))
    im.EndGroup()

    if im.SmallButton("set") {
        r.cpu.bus.ram[r.addr] = r.val
    }
    im.SameLine()
    if im.SmallButton("set & step") {
        r.cpu.bus.ram[r.addr] = r.val
        r.addr += 1
    }
}
