package cart

import "base:runtime"

MEM_START :: 0x0000
MEM_END :: 0x8000

Cartridge :: struct {
	rom: []u8,
}

new :: proc(rom: []u8) -> Cartridge {
	return {rom}
}

read :: proc(cart: Cartridge, addr: u16) -> u8 {
    return cart.rom[addr - MEM_START]
}

write :: proc(cart: ^Cartridge, addr: u16, val: u8) {
    cart.rom[addr - MEM_START] = val
}
