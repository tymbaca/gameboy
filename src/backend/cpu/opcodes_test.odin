package cpu

import "core:testing"
import "src:helper/math"

test_cpu :: proc() -> CPU {
	return CPU{}
}

@(test)
inc_test :: proc(t: ^testing.T) {
	cpu := test_cpu()
	f_at_start := cpu.f
	inc_a := inc(.A)

	cpu.a = 1

	inc_a(&cpu)
	testing.expect(t, cpu.a == 2)
	testing.expect(t, cpu.f == f_at_start)

	inc_a(&cpu)
	testing.expect(t, cpu.a == 3)
	testing.expect(t, cpu.f == f_at_start)

	cpu.a = 0b00001111
	inc_a(&cpu)
	testing.expect(t, cpu.a == 0b00010000)
	testing.expect(t, cpu.f.h == true) // half-carry

	inc_a(&cpu)
	testing.expect(t, cpu.a == 0b00010001)
	testing.expect(t, cpu.f == f_at_start)

	cpu.a = 254
	inc_a(&cpu)
	testing.expect(t, cpu.a == math.MAX_U8)
	testing.expect(t, cpu.f == f_at_start)

	inc_a(&cpu)
	testing.expect(t, cpu.a == 0)
	testing.expect(t, cpu.f.z == true) // zero
}

@(test)
inc_u16_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    f_at_start := cpu.f
    inc_hl := inc_u16(.HL)

    set_reg_u16(&cpu, .HL, 1)

    inc_hl(&cpu)
    testing.expect(t, get_reg_u16(&cpu, .HL) == 2)

    inc_hl(&cpu)
    testing.expect(t, get_reg_u16(&cpu, .HL) == 3)

    set_reg_u16(&cpu, .HL, math.MAX_U16)

    inc_hl(&cpu)
    testing.expect(t, get_reg_u16(&cpu, .HL) == 0)
}

@(test)
add_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    f_at_start := cpu.f
    add_ab := add_u8(.A, .B)

    cpu.a = 1
    cpu.b = 2

    add_ab(&cpu)
    testing.expect(t, cpu.a == 3)
    testing.expect(t, cpu.b == 2)
    testing.expect(t, cpu.f == f_at_start)

    add_ab(&cpu)
    testing.expect(t, cpu.a == 5)
    testing.expect(t, cpu.b == 2)
    testing.expect(t, cpu.f == f_at_start)

    cpu.a = 0x0F
    cpu.b = 1
    add_ab(&cpu)
    testing.expect(t, cpu.a == 0x10)
    testing.expect(t, cpu.b == 1)
    testing.expect(t, cpu.f.z == false)
    testing.expect(t, cpu.f.c == false)
    testing.expect(t, cpu.f.h == true)

    cpu.a = 255
    cpu.b = 2
    add_ab(&cpu)
    testing.expect(t, cpu.a == 1)
    testing.expect(t, cpu.b == 2)
    testing.expect(t, cpu.f.z == false)
    testing.expect(t, cpu.f.c == true)
    testing.expect(t, cpu.f.h == true)

    cpu.a = 255
    cpu.b = 1
    add_ab(&cpu)
    testing.expect(t, cpu.a == 0)
    testing.expect(t, cpu.b == 1)
    testing.expect(t, cpu.f.z == true)
    testing.expect(t, cpu.f.c == true)
    testing.expect(t, cpu.f.h == true)
}

@(test)
add_mem_test :: proc(t: ^testing.T) {
    // TODO:
}
