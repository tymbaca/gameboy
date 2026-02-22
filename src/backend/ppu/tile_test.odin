package ppu

import "core:testing"
@(test)
tile_test :: proc(t: ^testing.T) {
	tile := Tile {
		pixels = {},
	}

    tile = write_tile(tile, 0, 0xA5)
    tile = write_tile(tile, 1, 0xC3)

    tile = write_tile(tile, 2, 0xA5)
    tile = write_tile(tile, 3, 0xC3)

    tile = write_tile(tile, 4, 0xA5)
    tile = write_tile(tile, 5, 0xC3)

    tile = write_tile(tile, 6, 0xA5)
    tile = write_tile(tile, 7, 0xC3)

    tile = write_tile(tile, 8, 0x55)
    tile = write_tile(tile, 9, 0x33)

    tile = write_tile(tile, 10, 0x55)
    tile = write_tile(tile, 11, 0x33)

    tile = write_tile(tile, 12, 0x55)
    tile = write_tile(tile, 13, 0x33)

    tile = write_tile(tile, 14, 0x55)
    tile = write_tile(tile, 15, 0x33)

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
        }
    })

    testing.expect(t, read_tile(tile, 0) == 0xA5)
    testing.expect(t, read_tile(tile, 1) == 0xC3)

    testing.expect(t, read_tile(tile, 2) == 0xA5)
    testing.expect(t, read_tile(tile, 3) == 0xC3)

    testing.expect(t, read_tile(tile, 4) == 0xA5)
    testing.expect(t, read_tile(tile, 5) == 0xC3)

    testing.expect(t, read_tile(tile, 6) == 0xA5)
    testing.expect(t, read_tile(tile, 7) == 0xC3)

    testing.expect(t, read_tile(tile, 8) == 0x55)
    testing.expect(t, read_tile(tile, 9) == 0x33)

    testing.expect(t, read_tile(tile, 10) == 0x55)
    testing.expect(t, read_tile(tile, 11) == 0x33)

    testing.expect(t, read_tile(tile, 12) == 0x55)
    testing.expect(t, read_tile(tile, 13) == 0x33)

    testing.expect(t, read_tile(tile, 14) == 0x55)
    testing.expect(t, read_tile(tile, 15) == 0x33)
}
