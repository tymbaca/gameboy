package bus

import "src:backend/cart"
import "src:backend/ppu"
import "src:helper/math"

RAM_SIZE :: math.MAX_U16 + 1

RAM_START :: 0xA000

Bus :: struct {
	cart: cart.Cartridge,
	ppu:  ppu.PPU,
	ram:  [RAM_SIZE]u8,
}

new :: proc() -> Bus {
	return Bus{}
}

read :: proc(b: Bus, addr: u16) -> u8 {
    switch addr {
    case cart.MEM_START..<cart.MEM_END:
		return cart.read(b.cart, addr)

    case ppu.MEM_START..<ppu.MEM_END:
        return ppu.read_vram(b.ppu, addr)

    case:
        return b.ram[addr - RAM_START]
    }

}

write :: proc(b: ^Bus, addr: u16, val: u8) {
    switch addr {
    case cart.MEM_START..<cart.MEM_END:
		cart.write(&b.cart, addr, val)

    case ppu.MEM_START..<ppu.MEM_END:
		ppu.write_vram(&b.ppu, addr, val)

    case:
        b.ram[addr - RAM_START] = val
    }
}

load_cart :: proc(b: ^Bus, cart: cart.Cartridge) {
	b.cart = cart
}

unload_cart :: proc(b: ^Bus) {
	b.cart = {}
}
