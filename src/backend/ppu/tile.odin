package ppu

import "src:helper/math"

/*
0th byte: 0x55:  0 1 0 1 0 1 0 1
1st byte: 0x33: 0 0 1 1 0 0 1 1

                0001101100011011
                 0 1 2 3 0 1 2 3
*/
Tile :: struct {
	pixels: [8][8]Color,
}

Color :: enum u8 {
	White = 0b00,
	Light = 0b01,
	Dark  = 0b10,
	Black = 0b11,
}

// data must be 16 len
tile_from_bytes :: proc(data: []u8) -> Tile {
    assert(len(data) == 16)

    tile: Tile
    for ch, i in data {
        tile = write_tile_byte(tile, u16(i), ch)
    }

    return tile
}

// buf must be 16 len
tile_to_bytes :: proc(tile: Tile, buf: []u8) -> []u8 {
    buf := buf[:16]
    for i in 0..<16 {
        buf[i] = read_tile_byte(tile, u16(i))
    }

    return buf
}

read_tile_byte :: proc(t: Tile, offset: u16) -> u8 {
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

write_tile_byte :: proc(t: Tile, offset: u16, val: u8) -> Tile {
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
