package cpu

IF_ADDR :: 0xFF0F
IE_ADDR :: 0xFFFF

Interrupt :: enum {
	VBLANK = 1 << 0,
	STAT   = 1 << 1,
	TIMER  = 1 << 2,
	SERIAL = 1 << 3,
	JOYPAD = 1 << 4,
}

Interrupts :: bit_set[Interrupt; u8]

get_interrupt_vector :: proc(i: Interrupt) -> u16 {
    switch i {
    case .VBLANK:
        return 0x0040
    case .STAT:
        return  0x0048
    case .TIMER:
        return 0x0050
    case .SERIAL:
        return 0x0058
    case .JOYPAD:
        return 0x0060
    }

    panic("unreachable")
}

set_interrupt :: proc(cpu: ^CPU, intr: Interrupt) {
    panic("not implemented")
}
