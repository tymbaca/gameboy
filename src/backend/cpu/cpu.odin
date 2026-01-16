package cpu

import "core:log"
import "src:helper/math"

CPU :: struct {
    pc, sp: u16,
    a: u8,       // Accumulator 
    f: Flag_Reg, // Flag Register
    b, c: u8, 
    d, e: u8,
    h, l: u8, // High / Low
}

Reg :: enum {
    A = 0, 
    F = 1, 
    B = 2, 
    C = 3, 
    D = 4, 
    E = 5, 
    H = 6, 
    L = 7,
}

Reg_u16 :: enum {
    PC, 
    SP, 
    AF, 
    BC, 
    DE, 
    HL,
}

Flag_Reg :: bit_field u8 {
    _: bool | 4, // 1-4 reserved, not used
    c: bool | 1, // 5 Carry Flag
    h: bool | 1, // 6 Half-Carry Flag
    n: bool | 1, // 7 Negative Flag
    z: bool | 1, // 8 Zero Flag
}

get_reg :: proc(cpu: ^CPU, reg: Reg) -> u8 {
    switch reg {
    case .A:
        return cpu.a
    case .F:
        return u8(cpu.f)
    case .B:
        return cpu.b
    case .C:
        return cpu.c
    case .D:
        return cpu.d
    case .E:
        return cpu.e
    case .H:
        return cpu.h
    case .L:
        return cpu.l
    }

    log.panic("unreachable, got unknown reg", reg)
}

get_reg_u16 :: proc(cpu: ^CPU, reg: Reg_u16) -> u16 {
    switch reg {
    case .PC:
        return cpu.pc
    case .SP:
        return cpu.sp
    case .AF:
        return math.merge_u16(cpu.a, u8(cpu.f))
    case .BC:
        return math.merge_u16(cpu.b, cpu.c)
    case .DE:
        return math.merge_u16(cpu.d, cpu.e)
    case .HL:
        return math.merge_u16(cpu.h, cpu.l)
    }

    log.panic("unreachable, got unknown reg_u16", reg)
}

set_reg :: proc(cpu: ^CPU, reg: Reg, val: u8) {
    switch reg {
    case .A:
        cpu.a = val
    case .F:
        cpu.f = Flag_Reg(val)
    case .B:
        cpu.b = val
    case .C:
        cpu.c = val
    case .D:
        cpu.d = val
    case .E:
        cpu.e = val
    case .H:
        cpu.h = val
    case .L:
        cpu.l = val
    case:
        log.panic("unreachable, got unknown reg", reg)
    }

    return
}

set_reg_u16 :: proc(cpu: ^CPU, reg: Reg_u16, val: u16) {
    switch reg {
    case .PC:
        cpu.pc = val
    case .SP:
        cpu.sp = val
    case .AF:
        a, f := math.split_u16(val)
        cpu.a, cpu.f = a, Flag_Reg(f)
    case .BC:
        cpu.b, cpu.c = math.split_u16(val)
    case .DE:
        cpu.d, cpu.e = math.split_u16(val)
    case .HL:
        cpu.h, cpu.l = math.split_u16(val)
    case: 
        log.panic("unreachable, got unknown reg_u16", reg)
    }

    return
}

inc_reg_u16 :: proc(cpu: ^CPU, reg: Reg_u16) {
    val := get_reg_u16(cpu, reg)
    set_reg_u16(cpu, reg, val + 1)
}

dec_reg_u16 :: proc(cpu: ^CPU, reg: Reg_u16) {
    val := get_reg_u16(cpu, reg)
    set_reg_u16(cpu, reg, val - 1)
}
// TODO: tests

execute :: proc(cpu: ^CPU) -> u8 {
    op := fetch(cpu)
    return OPCODES[op](cpu)
}

fetch :: proc(cpu: ^CPU) -> u8 {
    val := read_mem(cpu, cpu.pc)
    cpu.pc += 1
    return val
}

fetch_u16 :: proc(cpu: ^CPU) -> u16 {
    low := fetch(cpu)
    high := fetch(cpu)

    return math.merge_u16(high, low)
}

read_mem :: proc(cpu: ^CPU, addr: u16) -> u8 {
    panic("not implemented")
}

write_mem :: proc(cpu: ^CPU, addr: u16, val: u8) {
    panic("not implemented")
}
