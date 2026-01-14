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
    A, F, 
    B, C, 
    D, E, 
    H, L,
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


