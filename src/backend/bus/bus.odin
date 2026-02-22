package bus

import "src:helper/math"
import "src:backend/cart"

RAM_SIZE :: math.MAX_U16 + 1

Bus :: struct {
    cart: cart.Cartridge,
    ram: [RAM_SIZE]u8,
}

new :: proc() -> Bus {
    return Bus{}
}

read :: proc(b: ^Bus, addr: u16) -> u8 {
    if addr >= cart.ROM_START || addr <= cart.ROM_END {
        return cart.read(&b.cart, addr)
    }

    return b.ram[addr]
}

write :: proc(b: ^Bus, addr: u16, val: u8) {
    if addr >= cart.ROM_START || addr <= cart.ROM_END {
        cart.write(&b.cart, addr, val)
        return
    }

    b.ram[addr] = val
}

load_cart :: proc(b: ^Bus, cart: cart.Cartridge) {
    b.cart = cart
}
