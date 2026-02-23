package cpu

import "base:runtime"
import "core:log"
import "src:helper/math"
import "src:backend/bus"
import "src:backend/cart"
import "src:backend/ppu"

CPU :: struct {
    pc, sp: u16,
    a: u8,       // Accumulator 
    f: Flag_Reg, // Flag Register
    b, c: u8, 
    d, e: u8,
    h, l: u8,
    irq_enabled: bool,
    halted: bool,
    bus: bus.Bus,

    allocator: runtime.Allocator,
}

SP_START :: 0xFFFE

when !ODIN_TEST {
    new_cpu :: proc() -> CPU {
        cpu := CPU{
            pc = 0x0100,
            sp = SP_START,
            a = 0x01,
            b = 0x00,
            c = 0x13,
            d = 0x00,
            e = 0xD8,
            f = Flag_Reg(0xB0),
            h = 0x01,
            l = 0x4D,
            irq_enabled = false,
            halted = false,
            bus = bus.new(),
        }

        // Magic values for RAM initialization
        write_mem(&cpu, 0xFF10, 0x80)
        write_mem(&cpu, 0xFF11, 0xBF)
        write_mem(&cpu, 0xFF12, 0xF3)
        write_mem(&cpu, 0xFF14, 0xBF)
        write_mem(&cpu, 0xFF16, 0x3F)
        write_mem(&cpu, 0xFF19, 0xBF)
        write_mem(&cpu, 0xFF1A, 0x7F)
        write_mem(&cpu, 0xFF1B, 0xFF)
        write_mem(&cpu, 0xFF1C, 0x9F)
        write_mem(&cpu, 0xFF1E, 0xBF)
        write_mem(&cpu, 0xFF20, 0xFF)
        write_mem(&cpu, 0xFF23, 0xBF)
        write_mem(&cpu, 0xFF24, 0x77)
        write_mem(&cpu, 0xFF25, 0xF3)
        write_mem(&cpu, 0xFF26, 0xF1) // 0xF0 for SGB
        write_mem(&cpu, 0xFF40, 0x91)
        write_mem(&cpu, 0xFF47, 0xFC)
        write_mem(&cpu, 0xFF48, 0xFF)
        write_mem(&cpu, 0xFF49, 0xFF)

        return cpu
    }
} else {
    new_cpu :: proc() -> CPU {
        return CPU{
            sp = SP_START,
        }
    }
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

Flag_Kind :: enum {
    Z, // 8 Zero Flag
    N, // 7 Negative Flag
    H, // 6 Half-Carry Flag
    C, // 5 Carry Flag
}

load_rom :: proc(cpu: ^CPU, rom: []u8) {
    rom_copy := make([]u8, len(rom), allocator = cpu.allocator)
    copy(rom_copy, rom)

    cart := cart.new(rom_copy)
}


tick :: proc(cpu: ^CPU) -> bool {
    cycles := execute(cpu) if !cpu.halted else 1
    ppu_result := bus.update_ppu(&cpu.bus, cycles)

    return ppu_result.lcd == .Render_Frame
}

execute :: proc(cpu: ^CPU) -> u8 {
    op := fetch(cpu)
    return OPCODES[op](cpu)
}

fetch :: proc(cpu: ^CPU) -> u8 {
    val := read_mem(cpu, cpu.pc)
    cpu.pc += 1
    return val
}

fetch_i8 :: proc(cpu: ^CPU) -> i8 {
    return transmute(i8)(fetch(cpu))
}

fetch_u16 :: proc(cpu: ^CPU) -> u16 {
    low := fetch(cpu)
    high := fetch(cpu)

    return math.merge_u16(high, low)
}

pop :: proc(cpu: ^CPU) -> u16 {
    assert(cpu.sp <= 0xFFFE, "you'r cooked bro")
    assert(cpu.sp != 0xFFFE, "pop called when stack is empty")

    low := read_mem(cpu, cpu.sp)
    high := read_mem(cpu, cpu.sp+1)
    cpu.sp += 2

    return math.merge_u16(high, low)
} 

push :: proc(cpu: ^CPU, val: u16) {
    cpu.sp -= 2
    high, low := math.split_u16(val)
    write_mem(cpu, cpu.sp, low)
    write_mem(cpu, cpu.sp+1, high)
}

get_flag :: proc(cpu: ^CPU, flag: Flag_Kind) -> bool {
    switch flag {
    case .Z:
        return cpu.f.z
    case .N:
        return cpu.f.n
    case .H:
        return cpu.f.h
    case .C:
        return cpu.f.c
    }

    log.panic("unreachable, got unknown flag kind", flag)
}

set_flag :: proc(cpu: ^CPU, flag: Flag_Kind, val: bool) {
    switch flag {
    case .Z:
        cpu.f.z = val
    case .N:
        cpu.f.n = val
    case .H:
        cpu.f.h = val
    case .C:
        cpu.f.c = val
    }
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
        return math.merge_u16(u8(cpu.f), cpu.a)
    case .BC:
        return math.merge_u16(cpu.c, cpu.b)
    case .DE:
        return math.merge_u16(cpu.e, cpu.d)
    case .HL:
        return math.merge_u16(cpu.l, cpu.h)
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
        f, a := math.split_u16(val)
        cpu.f, cpu.a = Flag_Reg(f), a
    case .BC:
        cpu.c, cpu.b = math.split_u16(val)
    case .DE:
        cpu.e, cpu.d = math.split_u16(val)
    case .HL:
        cpu.l, cpu.h = math.split_u16(val)
    case: 
        log.panic("unreachable, got unknown reg_u16", reg)
    }

    return
}

add_reg_u16 :: proc(cpu: ^CPU, reg: Reg_u16, delta: i8) {
    val := get_reg_u16(cpu, reg)

    if delta >= 0 {
        set_reg_u16(cpu, reg, val + u16(delta))
    } else {
        set_reg_u16(cpu, reg, val - u16(abs(delta)))
    }
}

inc_reg_u16 :: proc(cpu: ^CPU, reg: Reg_u16) {
    val := get_reg_u16(cpu, reg)
    set_reg_u16(cpu, reg, val + 1)
}

dec_reg_u16 :: proc(cpu: ^CPU, reg: Reg_u16) {
    val := get_reg_u16(cpu, reg)
    set_reg_u16(cpu, reg, val - 1)
}

add_u16_i8 :: proc(a: u16, b: i8) -> (res: u16, flags: Flag_Reg) {
    res = a
    flags.z = false
    flags.n = false

    if b >= 0 {
        abs_b := u16(b)
        flags.h = math.will_half_carry_u16(a, abs_b)
        flags.c = math.will_carry_u16(a, abs_b)
        res += abs_b
    } else {
        abs_b := u16(abs(b))
        flags.h = math.will_half_borrow_u16(a, abs_b)
        flags.c = math.will_borrow_u16(a, abs_b)
        res -= abs_b
    }

    return res, flags
}
