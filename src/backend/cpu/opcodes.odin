package cpu

import "src:helper/math"

// https://izik1.github.io/gbops/

OPCODES: [256]proc(^CPU) -> u8 = {
//  0x00,        0x01,        0x02,        0x03,         0x04,        0x05,        0x06,   0x07,        0x08, 0x09, 0x0A, 0x0B,         0x0C,    0x0D, 0x0E, 0x0F
    nop_00,      todo,        todo,        inc_u16(.BC), inc(.B),     dec(.B),     todo,   todo,        todo, add_u16(.HL, .BC), todo, dec_u16(.BC), inc(.C), dec(.C), todo, todo, // 0x00
    todo,        todo,        todo,        inc_u16(.DE), inc(.D),     dec(.D),     todo,   todo,        todo, add_u16(.HL, .BC), todo, dec_u16(.DE), inc(.E), dec(.E), todo, todo, // 0x10
    todo,        todo,        todo,        inc_u16(.HL), inc(.H),     dec(.H),     todo,   todo,        todo, add_u16(.HL, .BC), todo, dec_u16(.HL), inc(.L), dec(.L), todo, todo, // 0x20
    todo,        todo,        todo,        inc_u16(.SP), inc_34,      dec_35,      todo,   todo,        todo, add_u16(.HL, .BC), todo, dec_u16(.SP), inc(.A), dec(.A), todo, todo, // 0x30
    todo,        todo,        todo,        todo,         todo,        todo,        todo,   todo,        todo, todo, todo, todo,         todo,    todo, todo, todo, // 0x40
    todo,        todo,        todo,        todo,         todo,        todo,        todo,   todo,        todo, todo, todo, todo,         todo,    todo, todo, todo, // 0x50
    todo,        todo,        todo,        todo,         todo,        todo,        todo,   todo,        todo, todo, todo, todo,         todo,    todo, todo, todo, // 0x60
    todo,        todo,        todo,        todo,         todo,        todo,        todo,   todo,        todo, todo, todo, todo,         todo,    todo, todo, todo, // 0x70
    add(.A, .B), add(.A, .C), add(.A, .D), add(.A, .E),  add(.A, .H), add(.A, .L), add_86, add(.A, .A), todo, todo, todo, todo,         todo,    todo, todo, todo, // 0x80
    todo,        todo,        todo,        todo,         todo,        todo,        todo,   todo,        todo, todo, todo, todo,         todo,    todo, todo, todo, // 0x90
    todo,        todo,        todo,        todo,         todo,        todo,        todo,   todo,        todo, todo, todo, todo,         todo,    todo, todo, todo, // 0xA0
    todo,        todo,        todo,        todo,         todo,        todo,        todo,   todo,        todo, todo, todo, todo,         todo,    todo, todo, todo, // 0xB0
    todo,        todo,        todo,        todo,         todo,        todo,        todo,   todo,        todo, todo, todo, todo,         todo,    todo, todo, todo, // 0xC0
    todo,        todo,        todo,        todo,         todo,        todo,        todo,   todo,        todo, todo, todo, todo,         todo,    todo, todo, todo, // 0xD0
    todo,        todo,        todo,        todo,         todo,        todo,        todo,   todo,        todo, todo, todo, todo,         todo,    todo, todo, todo, // 0xE0
    todo,        todo,        todo,        todo,         todo,        todo,        todo,   todo,        todo, todo, todo, todo,         todo,    todo, todo, todo, // 0xF0
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
        cpu.f.h = math.will_half_carry(val, 1)
        
        set_reg(cpu, reg, val + 1)

        return 1
    }
}

inc_u16 :: proc($reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg_u16(cpu, reg)
        set_reg_u16(cpu, reg, val + 1)

        return 2
    }
}

inc_34 :: proc(cpu: ^CPU) -> u8 {
    addr := get_reg_u16(cpu, .HL)
    val := read_mem(cpu, addr)

    cpu.f.z = (val + 1) == 0
    cpu.f.n = false
    cpu.f.h = math.will_half_carry(val, 1)

    write_mem(cpu, addr, val + 1)

    return 3
}

dec :: proc($reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg(cpu, reg)

        cpu.f.z = (val - 1) == 0
        cpu.f.n = true
        cpu.f.h = math.will_half_borrow(val, 1)
        
        set_reg(cpu, reg, val - 1)

        return 1
    }
}

dec_u16 :: proc($reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg_u16(cpu, reg)
        set_reg_u16(cpu, reg, val - 1)

        return 2
    }
}

dec_35 :: proc(cpu: ^CPU) -> u8 {
    addr := get_reg_u16(cpu, .HL)
    val := read_mem(cpu, addr)

    cpu.f.z = (val - 1) == 0
    cpu.f.n = true
    cpu.f.h = math.will_half_borrow(val, 1)

    write_mem(cpu, addr, val - 1)

    return 3
}

ad :: proc {
    add,
    add_u16,
}

add :: proc($left_reg, $right_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        left := get_reg(cpu, left_reg)
        right := get_reg(cpu, right_reg)

        set_flag_z0hc(cpu, left, right)
        set_reg(cpu, left_reg, left + right)

        return 1
    }
}

add_u16 :: proc($left_reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        left := get_reg_u16(cpu, left_reg)
        right := get_reg_u16(cpu, right_reg)

        // cpu.f.z untouched
        cpu.f.n = false
        cpu.f.h = math.will_half_carry_u16(left, right)
        cpu.f.c = math.will_carry_u16(left, right)

        set_reg_u16(cpu, left_reg, left + right)

        return 2
    }
}

add_86 :: proc($left_reg: Reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        left := get_reg(cpu, left_reg)
        right := read_mem(cpu, get_reg_u16(cpu, right_reg))

        set_flag_z0hc(cpu, left, right)
        set_reg(cpu, left_reg, left + right)

        return 2
    }
}

set_flag_z0hc :: proc(cpu: ^CPU, left, right: u8) {
    cpu.f.z = (left + right) == 0
    cpu.f.n = false
    cpu.f.h = math.will_half_carry(left, right)
    cpu.f.c = math.will_carry(left, right)
}
