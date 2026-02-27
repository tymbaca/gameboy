package ppu

LCD_REG_START :: 0xFF40
LCD_REG_STOP :: 0xFF4C

LCDC :: 0xFF40

// Bit flags for LCDC
LCDC_LCD_ENABLED_BIT :: 7
LCDC_WNDW_MAP_BIT :: 6
LCDC_WNDW_ENABLED_BIT :: 5
LCDC_BG_WNDW_TILE_BIT :: 4
LCDC_BG_MAP_BIT :: 3
LCDC_SPR_SIZE_BIT :: 2
LCDC_SPR_ENABLED_BIT :: 1
LCDC_BG_WNDW_ENABLED_BIT :: 0

read_lcd_reg :: proc(ppu: PPU, addr: u16) -> u8 {
	addr := addr - LCD_REG_START
	return ppu.lcd_reg[addr]
}

write_lcd_reg :: proc(ppu: ^PPU, addr: u16, val: u8) {
	addr := addr - LCD_REG_START
	ppu.lcd_reg[addr] = val
}
