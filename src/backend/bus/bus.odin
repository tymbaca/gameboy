package bus

import "src:backend/cart"
import "src:backend/ppu"
import "src:helper/math"

RAM_SIZE :: math.MAX_U16 + 1

Bus :: struct {
	cart: cart.Cartridge,
	ppu:  ppu.PPU,
	ram:  [RAM_SIZE]u8,
}

new :: proc() -> Bus {
	return Bus{}
}

read :: proc(b: Bus, addr: u16) -> u8 {
    switch {
    case addr >= cart.MEM_START && addr < cart.MEM_END:
		return cart.read(b.cart, addr - cart.MEM_START)

    case addr >= ppu.MEM_START && addr < ppu.MEM_END:
        return ppu.read_vram(b.ppu, addr - ppu.MEM_START)

    case:
        return b.ram[addr - ppu.MEM_END]
    }

}

write :: proc(b: ^Bus, addr: u16, val: u8) {
    switch {
    case addr >= cart.MEM_START && addr < cart.MEM_END:
		cart.write(&b.cart, addr - cart.MEM_START, val)

    case addr >= ppu.MEM_START && addr < ppu.MEM_END:
		ppu.write_vram(&b.ppu, addr - ppu.MEM_START, val)

    case:
        b.ram[addr - ppu.MEM_END] = val
    }
}

load_cart :: proc(b: ^Bus, cart: cart.Cartridge) {
	b.cart = cart
}

unload_cart :: proc(b: ^Bus) {
	b.cart = {}
}
