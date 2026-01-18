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

    @(static) viewers: [dynamic]Ram_Viewer
    if viewers == nil {
        viewers = make([dynamic]Ram_Viewer, allocator = allocator)
    }

    if im.SmallButton("add viewer") {
        append(&viewers, Ram_Viewer{
            id = fmt.caprintf("RAM viewer #%d", len(viewers), allocator = allocator),
            cpu = cpu,
            from_addr = 0,
            limit = 0x200,
        })
    }

    for &viewer in viewers {
        ram_viewer_render(&viewer, allocator = allocator)
    }

    @(static) editors: [dynamic]Ram_Editor
    if editors == nil {
        editors = make([dynamic]Ram_Editor, allocator = allocator)
    }

    if im.SmallButton("add editor") {
        append(&editors, Ram_Editor{
            id = fmt.caprintf("RAM editor #%d", len(editors), allocator = allocator),
            val_fmt = IM_U8_HEX_FMT,
            val_type = .U8,
        })
    }

    for &editor in editors {
        ram_editor_render(&editor, allocator = allocator)
    }
}

Ram_Viewer :: struct {
    id: cstring,
    cpu: ^cpu_pkg.CPU,
    from_addr: u16,
    limit: u16,
}

ram_viewer_render :: proc(r: ^Ram_Viewer, allocator := context.allocator) {
    im.Begin(r.id)
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
    im.TextUnformatted(dump_text)
}

Ram_Editor :: struct {
    id: cstring,
    addr: u16,
    val: u8,
    val_fmt: cstring,
    val_type: im.DataType,
}

IM_U8_DEC_FMT :: "%d"
IM_U8_HEX_FMT :: "%02X"
IM_U16_DEC_FMT :: "%d"
IM_U16_HEX_FMT :: "%04X"

ram_editor_render :: proc(r: ^Ram_Editor, allocator := context.allocator) {
    im.Begin(r.id)
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
}
