package ppu

HBLANK_LEN :: 204
VBLANK_LEN :: 456
OAM_READ_LEN :: 80
VRAM_READ_LEN :: 172

VBLANK_LINE_START :: 143
VBLANK_LINE_END :: VBLANK_LINE_START + 10

LCD_Mode :: enum {
	HBLANK    = 0,
	VBLANK    = 1,
	OAM_Read  = 2,
	VRAM_Read = 3,
}

LCD :: struct {
	mode:   LCD_Mode,
	cycles: u16,
	line:   u8,
}

new_lcd :: proc() -> LCD {
    return {
        mode = .HBLANK,
        cycles = 0,
        line = 0,
    }
}

LCD_Result :: enum {
    No_Action,
    Render_Frame,
}

step :: proc(lcd: ^LCD, cycles: u8) -> LCD_Result {
    result: LCD_Result = .No_Action
    lcd.cycles += u16(cycles)
    
    switch lcd.mode {
    case .HBLANK:
        if lcd.cycles > HBLANK_LEN {
            lcd.cycles = 0
            lcd.line += 1

            if lcd.line >= VBLANK_LINE_START {
                lcd.mode = .VBLANK
                result = .Render_Frame
            } else {
                lcd.mode = .OAM_Read
            }
        }
    case .VBLANK:
        if lcd.cycles > VBLANK_LEN {
            lcd.cycles = 0
            lcd.line += 1

            if lcd.line >= VBLANK_LINE_END {
                lcd.line = 0
                lcd.mode = .OAM_Read
            }
        }
    case .OAM_Read:
        if lcd.cycles > OAM_READ_LEN {
            lcd.cycles = 0
            lcd.mode = .VRAM_Read
        }
    case .VRAM_Read:
        if lcd.cycles > OAM_READ_LEN {
            lcd.cycles = 0 // TODO: maybe do lcd.cycles % OAM_READ_LEN?
            lcd.mode = .HBLANK
        }
    }

    return result
}
