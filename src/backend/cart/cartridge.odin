package cart

import "base:runtime"

ROM_START :: 0x0000
ROM_END :: 0x7FFF

Cartridge :: struct {
	rom: []u8,
}

new :: proc(rom: []u8) -> Cartridge {
	return {rom}
}

read :: proc(cart: ^Cartridge, addr: u16) -> u8 {
    return cart.rom[addr]
}

write :: proc(cart: ^Cartridge, addr: u16, val: u8) {
    cart.rom[addr] = val
}
