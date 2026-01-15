package frontend

import "base:intrinsics"
import "core:mem"
import "core:math/rand"
import "core:fmt"
import "core:c"
import im "lib:imgui"
import cpu_pkg "src:backend/cpu"

cpu_debug_menu :: proc(cpu: ^cpu_pkg.CPU, allocator := context.allocator) {
	im.Begin("CPU")
	defer im.End()

    if im.Button("step") {
        buf: [size_of(cpu_pkg.CPU)]byte
        _ = rand.read(buf[:])

        mem.copy(cpu, &buf, len(buf))
    }

	if im.CollapsingHeader("Registers") {
		@(static) byte_mode: c.int = 1
		im.RadioButtonIntPtr("DEC", &byte_mode, 1)
        im.SameLine()
		im.RadioButtonIntPtr("BIN", &byte_mode, 2)
        im.SameLine()
		im.RadioButtonIntPtr("HEX", &byte_mode, 3)

        byte_fmt: string
        two_byte_fmt: string
        switch byte_mode {
        case 1:
            byte_fmt = "%d"
            two_byte_fmt = "%d"
        case 2:
            byte_fmt = "%8b"
            two_byte_fmt = "%16b"
        case 3:
            byte_fmt = "%2x"
            two_byte_fmt = "%4x"
        }

		@(static) reg_mode: c.int = 1
		im.RadioButtonIntPtr("separate", &reg_mode, 1)
        im.SameLine()
		im.RadioButtonIntPtr("double", &reg_mode, 2)

        table_flags := im.TableFlags_Resizable | im.TableFlags_BordersOuter | im.TableFlags_RowBg  | im.TableFlags_ContextMenuInBody // | im.TableFlags_SizingFixedFit | im.TableFlags_NoHostExtendX

        if im.BeginTable("special_regs", 1, table_flags) {
            defer im.EndTable()

            im.TableNextRow()
            table_item("PC", fmt.caprintf(two_byte_fmt, cpu.pc))
            im.TableNextRow()
            table_item("SP", fmt.caprintf(two_byte_fmt, cpu.sp))
        }
        if reg_mode == 1 {
            if im.BeginTable("common_regs", 2, table_flags) {
                defer im.EndTable()

                im.TableNextRow()
                table_item("A", fmt.caprintf(byte_fmt, cpu.a))
                table_item("F", fmt.caprintf(byte_fmt, u8(cpu.f)))
                im.TableNextRow()
                table_item("B", fmt.caprintf(byte_fmt, cpu.b))
                table_item("C", fmt.caprintf(byte_fmt, cpu.c))
                im.TableNextRow()
                table_item("D", fmt.caprintf(byte_fmt, cpu.d))
                table_item("E", fmt.caprintf(byte_fmt, cpu.e))
                im.TableNextRow()
                table_item("H", fmt.caprintf(byte_fmt, cpu.h))
                table_item("L", fmt.caprintf(byte_fmt, cpu.l))
            }
        } else {
            if im.BeginTable("common_regs", 1, table_flags) {
                defer im.EndTable()

                im.TableNextRow()
                table_item("AF", fmt.caprintf(two_byte_fmt, cpu_pkg.get_reg_u16(cpu, .AF)))
                im.TableNextRow()
                table_item("BC", fmt.caprintf(two_byte_fmt, cpu_pkg.get_reg_u16(cpu, .BC)))
                im.TableNextRow()
                table_item("DE", fmt.caprintf(two_byte_fmt, cpu_pkg.get_reg_u16(cpu, .DE)))
                im.TableNextRow()
                table_item("HL", fmt.caprintf(two_byte_fmt, cpu_pkg.get_reg_u16(cpu, .HL)))
            }
        }
	}
}

table_item :: proc(label, value: cstring) {
    im.TableNextColumn()
    im.Text("%s:", label); im.SameLine()
    im.Text(value)
}
