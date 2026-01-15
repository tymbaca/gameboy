package cpu

import "core:testing"
import "src:helper/math"

// https://izik1.github.io/gbops/

OPCODES: [256]proc(^CPU) -> u8 = {
//  0x00,        0x01,        0x02,        0x03,         0x04,        0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C,    0x0D, 0x0E, 0x0F
    nop_00,      todo,        todo,        inc_u16(.BC), inc(.B),     todo, todo, todo, todo, todo, todo, todo, inc(.C), todo, todo, todo, // 0x00
    todo,        todo,        todo,        inc_u16(.DE), inc(.D),     todo, todo, todo, todo, todo, todo, todo, inc(.E), todo, todo, todo, // 0x10
    todo,        todo,        todo,        inc_u16(.HL), inc(.H),     todo, todo, todo, todo, todo, todo, todo, inc(.L), todo, todo, todo, // 0x20
    todo,        todo,        todo,        inc_u16(.SP), inc_mem_34,  todo, todo, todo, todo, todo, todo, todo, inc(.A), todo, todo, todo, // 0x30
    todo,        todo,        todo,        todo,         todo,        todo, todo, todo, todo, todo, todo, todo, todo,    todo, todo, todo, // 0x40
    todo,        todo,        todo,        todo,         todo,        todo, todo, todo, todo, todo, todo, todo, todo,    todo, todo, todo, // 0x50
    todo,        todo,        todo,        todo,         todo,        todo, todo, todo, todo, todo, todo, todo, todo,    todo, todo, todo, // 0x60
    todo,        todo,        todo,        todo,         todo,        todo, todo, todo, todo, todo, todo, todo, todo,    todo, todo, todo, // 0x70
    add(.A, .B), add(.A, .C), add(.A, .D), add(.A, .E),  add(.A, .H), add(.A, .L), todo, todo, todo, todo, todo, todo, todo,    todo, todo, todo, // 0x80
    todo,        todo,        todo,        todo,         todo,        todo, todo, todo, todo, todo, todo, todo, todo,    todo, todo, todo, // 0x90
    todo,        todo,        todo,        todo,         todo,        todo, todo, todo, todo, todo, todo, todo, todo,    todo, todo, todo, // 0xA0
    todo,        todo,        todo,        todo,         todo,        todo, todo, todo, todo, todo, todo, todo, todo,    todo, todo, todo, // 0xB0
    todo,        todo,        todo,        todo,         todo,        todo, todo, todo, todo, todo, todo, todo, todo,    todo, todo, todo, // 0xC0
    todo,        todo,        todo,        todo,         todo,        todo, todo, todo, todo, todo, todo, todo, todo,    todo, todo, todo, // 0xD0
    todo,        todo,        todo,        todo,         todo,        todo, todo, todo, todo, todo, todo, todo, todo,    todo, todo, todo, // 0xE0
    todo,        todo,        todo,        todo,         todo,        todo, todo, todo, todo, todo, todo, todo, todo,    todo, todo, todo, // 0xF0
}

todo :: proc(^CPU) -> u8 {
    panic("not implemented")
}

nop_00 :: proc(cpu: ^CPU) -> u8 {
    return 1
}

inc :: proc($reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg(cpu, reg)

        cpu.f.z = (val + 1) == 0
        cpu.f.n = false
        cpu.f.h = math.will_add_half_carry(val, 1)
        
        set_reg(cpu, reg, val + 1)

        return 1
    }
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

test_cpu :: proc() -> CPU {
    return CPU{}
}

inc_u16 :: proc($reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg_u16(cpu, reg)
        set_reg_u16(cpu, reg, val + 1)

        return 2
    }
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

inc_mem_34 :: proc(cpu: ^CPU) -> u8 {
    addr := get_reg_u16(cpu, .HL)
    val := read_mem(cpu, addr)
    write_mem(cpu, addr, val + 1)

    return 3
}

add :: proc($left_reg, $right_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        left := get_reg(cpu, left_reg)
        right: u8

        right = get_reg(cpu, right_reg)

        set_flag_z0hc(cpu, left, right)
        set_reg(cpu, left_reg, left + right)

        return 1
    }
}

@(test)
add_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    f_at_start := cpu.f
    add_ab := add(.A, .B)

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

    cpu.a = 255
    add_ab(&cpu)
    testing.expect(t, cpu.a == 1)
    testing.expect(t, cpu.b == 2)
    testing.expect(t, cpu.f.z == false)
    testing.expect(t, cpu.f.c == true)

    cpu.a = 255
    cpu.b = 1
    add_ab(&cpu)
    testing.expect(t, cpu.a == 0)
    testing.expect(t, cpu.b == 1)
    testing.expect(t, cpu.f.z == true)
    testing.expect(t, cpu.f.c == true)
}

add_mem :: proc($left_reg: Reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        left := get_reg(cpu, left_reg)
        right = read_mem(cpu, get_reg_u16(cpu, right_reg))

        set_flag_z0hc(cpu, left, right)
        set_reg(cpu, left_reg, left + right)

        return 1
    }
}

set_flag_z0hc :: proc(cpu: ^CPU, left, right: u8) {
    cpu.f.z = (left + right) == 0
    cpu.f.n = false
    cpu.f.h = math.will_add_half_carry(left, right)
    cpu.f.c = math.will_add_carry(left, right)
}
