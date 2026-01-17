package cpu

import "core:fmt"
import "core:testing"

@(test)
set_get_reg_u16_test :: proc(t: ^testing.T) {
    cpu := test_cpu()

    set_reg_u16(&cpu, .HL, 0x4321)
    testing.expectf(t, cpu.h == 0x21, "H: 0x%x", cpu.h)
    testing.expectf(t, cpu.l == 0x43, "L: 0x%x", cpu.l)
    
    get_val := get_reg_u16(&cpu, .HL)
    testing.expectf(t, get_val == 0x4321, "get(HL): 0x%x", get_val)
}

@(test)
fetch_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    test_ram[0] = 0
    test_ram[1] = 1
    test_ram[2] = 2

    cpu.pc = 0

    testing.expect(t, fetch(&cpu) == 0)
    testing.expect(t, fetch(&cpu) == 1)
    testing.expect(t, fetch(&cpu) == 2)
}
