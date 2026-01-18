package bus

import "src:helper/math"

RAM_SIZE :: math.MAX_U16 + 1

new :: proc() -> Bus {
    return Bus{}
}

Bus :: struct {
    ram: [RAM_SIZE]u8,
}

read :: proc(b: ^Bus, addr: u16) -> u8 {
    return b.ram[addr]
}

write :: proc(b: ^Bus, addr: u16, val: u8) {
    b.ram[addr] = val
}
