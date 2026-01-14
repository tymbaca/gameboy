package cpu

import "src:helper/math"

// https://izik1.github.io/gbops/

OPCODES: [256]proc(^CPU) -> u8 = {
//  0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x00
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x10
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x20
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x30
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x40
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x50
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x60
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x70
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x80
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x90
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0xA0
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0xB0
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0xC0
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0xD0
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0xE0
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0xF0
}

todo :: proc(^CPU) -> u8 {
    panic("not implemented")
}

execute :: proc(cpu: ^CPU) -> u8 {
    op := fetch(cpu)
    return OPCODES[op](cpu)
}

fetch :: proc(cpu: ^CPU) -> u8 {
    val := read_mem(cpu.pc)
    cpu.pc += 1
    return val
}

fetch_u16 :: proc(cpu: ^CPU) -> u16 {
    low := fetch(cpu)
    high := fetch(cpu)

    return math.merge_u16(high, low)
}

read_mem :: proc(addr: u16) -> u8 {
    panic("not implemented")
}

nop_00 :: proc(cpu: ^CPU) -> u8 {
    return 1
}
