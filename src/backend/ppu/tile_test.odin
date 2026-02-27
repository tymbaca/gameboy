package ppu

import "core:testing"

@(test)
tile_test :: proc(t: ^testing.T) {
    tile := tile_from_bytes([]u8{
        0xA5, 0xC3,
        0xA5, 0xC3,
        0xA5, 0xC3,
        0xA5, 0xC3,
        0x55, 0x33,
        0x55, 0x33,
        0x55, 0x33,
        0x55, 0x33,
    })

    testing.expect_value(t, tile, Tile{
        pixels = {
            {.Black, .Dark, .Light, .White, .White, .Light, .Dark, .Black},
            {.Black, .Dark, .Light, .White, .White, .Light, .Dark, .Black},
            {.Black, .Dark, .Light, .White, .White, .Light, .Dark, .Black},
            {.Black, .Dark, .Light, .White, .White, .Light, .Dark, .Black},
            {.White, .Light, .Dark, .Black, .White, .Light, .Dark, .Black},
            {.White, .Light, .Dark, .Black, .White, .Light, .Dark, .Black},
            {.White, .Light, .Dark, .Black, .White, .Light, .Dark, .Black},
            {.White, .Light, .Dark, .Black, .White, .Light, .Dark, .Black},
        },
    })

    buf: [16]u8
    buf_slice := tile_to_bytes(tile, buf[:])
    testing.expect_value(t, len(buf_slice), 16)
    testing.expect_value(t, buf, [?]u8{
        0xA5, 0xC3,
        0xA5, 0xC3,
        0xA5, 0xC3,
        0xA5, 0xC3,
        0x55, 0x33,
        0x55, 0x33,
        0x55, 0x33,
        0x55, 0x33,
    })
}

@(test)
tile_byte_test :: proc(t: ^testing.T) {
	tile := Tile {
		pixels = {},
	}

    tile = write_tile_byte(tile, 0, 0xA5)
    tile = write_tile_byte(tile, 1, 0xC3)

    tile = write_tile_byte(tile, 2, 0xA5)
    tile = write_tile_byte(tile, 3, 0xC3)

    tile = write_tile_byte(tile, 4, 0xA5)
    tile = write_tile_byte(tile, 5, 0xC3)

    tile = write_tile_byte(tile, 6, 0xA5)
    tile = write_tile_byte(tile, 7, 0xC3)

    tile = write_tile_byte(tile, 8, 0x55)
    tile = write_tile_byte(tile, 9, 0x33)

    tile = write_tile_byte(tile, 10, 0x55)
    tile = write_tile_byte(tile, 11, 0x33)

    tile = write_tile_byte(tile, 12, 0x55)
    tile = write_tile_byte(tile, 13, 0x33)

    tile = write_tile_byte(tile, 14, 0x55)
    tile = write_tile_byte(tile, 15, 0x33)

    testing.expect_value(t, tile, Tile{
        pixels = {
            {.Black, .Dark, .Light, .White, .White, .Light, .Dark, .Black},
            {.Black, .Dark, .Light, .White, .White, .Light, .Dark, .Black},
            {.Black, .Dark, .Light, .White, .White, .Light, .Dark, .Black},
            {.Black, .Dark, .Light, .White, .White, .Light, .Dark, .Black},
            {.White, .Light, .Dark, .Black, .White, .Light, .Dark, .Black},
            {.White, .Light, .Dark, .Black, .White, .Light, .Dark, .Black},
            {.White, .Light, .Dark, .Black, .White, .Light, .Dark, .Black},
            {.White, .Light, .Dark, .Black, .White, .Light, .Dark, .Black},
        },
    })

    testing.expect(t, read_tile_byte(tile, 0) == 0xA5)
    testing.expect(t, read_tile_byte(tile, 1) == 0xC3)

    testing.expect(t, read_tile_byte(tile, 2) == 0xA5)
    testing.expect(t, read_tile_byte(tile, 3) == 0xC3)

    testing.expect(t, read_tile_byte(tile, 4) == 0xA5)
    testing.expect(t, read_tile_byte(tile, 5) == 0xC3)

    testing.expect(t, read_tile_byte(tile, 6) == 0xA5)
    testing.expect(t, read_tile_byte(tile, 7) == 0xC3)

    testing.expect(t, read_tile_byte(tile, 8) == 0x55)
    testing.expect(t, read_tile_byte(tile, 9) == 0x33)

    testing.expect(t, read_tile_byte(tile, 10) == 0x55)
    testing.expect(t, read_tile_byte(tile, 11) == 0x33)

    testing.expect(t, read_tile_byte(tile, 12) == 0x55)
    testing.expect(t, read_tile_byte(tile, 13) == 0x33)

    testing.expect(t, read_tile_byte(tile, 14) == 0x55)
    testing.expect(t, read_tile_byte(tile, 15) == 0x33)
}
