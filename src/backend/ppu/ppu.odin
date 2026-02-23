package ppu

MEM_START :: 0x8000
MEM_END :: 0xA000

TILE_SET_START :: 0x8000
TILE_SET_STOP :: 0x9800
TILE_MAP_START :: 0x9800
TILE_MAP_STOP :: 0xA000


TILE_SIZE :: 16
TILE_COUNT :: 384

PPU :: struct {
	lcd:     LCD,
	tileset: [TILE_COUNT]Tile,
	maps:    [TILE_MAP_STOP - TILE_MAP_START]u8,
}

new :: proc() -> PPU {
	return {
        lcd = new_lcd(),
    }
}

Result :: struct {
    lcd: LCD_Result,
}

update :: proc(ppu: ^PPU, cycles: u8) -> Result {
    lcd_res := step(&ppu.lcd, cycles)
    return {lcd = lcd_res}
}

read_vram :: proc(ppu: PPU, addr: u16) -> u8 {
	switch addr {
	case TILE_SET_START ..< TILE_SET_STOP:
		addr := addr - TILE_SET_START
		tile_index := addr / TILE_SIZE
		tile_byte_offset := addr % TILE_SIZE
		return read_tile_byte(ppu.tileset[tile_index], tile_byte_offset)

	case TILE_MAP_START ..< TILE_MAP_STOP:
		addr := addr - TILE_MAP_START
		return ppu.maps[addr]

	case:
		panic("unreachable")
	}
}

write_vram :: proc(ppu: ^PPU, addr: u16, val: u8) {
	switch addr {
	case TILE_SET_START ..< TILE_SET_STOP:
		addr := addr - TILE_SET_START
		tile_index := addr / TILE_SIZE
		tile_byte_offset := addr % TILE_SIZE
		write_tile_byte(ppu.tileset[tile_index], tile_byte_offset, val)

	case TILE_MAP_START ..< TILE_MAP_STOP:
		addr := addr - TILE_MAP_START
		ppu.maps[addr] = val

	case:
		panic("unreachable")
	}
}
