package ppu

import "src:helper/math"

Tile :: struct {
	pixels: [8][8]Color,
}

Color :: enum u8 {
	White = 0b00,
	Light = 0b01,
	Dark  = 0b10,
	Black = 0b11,
}

/*
0: 0x55:  0 1 0 1 0 1 0 1
1: 0x33: 0 0 1 1 0 0 1 1

         0001101100011011
          0 1 2 3 0 1 2 3
*/
read_tile :: proc(t: Tile, offset: u16) -> u8 {
    if offset > 16 {
        panic("offset too large to fit in this tile")
    }
    row := offset / 2
    bit := offset % 2
    ret: u8 = 0
    for i in 0..<8 {
        ret <<= 1
        ret |= 1 if math.get_bit(u8(t.pixels[row][i]), uint(bit)) else 0
    }

    return ret
}

write_tile :: proc(t: Tile, offset: u16, val: u8) -> Tile {
    t := t
    if offset > 16 {
        panic("offset too large to fit in this tile")
    }

    row := offset / 2
    bit := offset % 2
    for i in 0..<8 {
        target := u8(t.pixels[row][7-i])
        bit_val := math.get_bit(val, uint(i))
        target = math.set_bit(target, uint(bit), bit_val)

        t.pixels[row][7-i] = Color(target)
    }

    return t
}
