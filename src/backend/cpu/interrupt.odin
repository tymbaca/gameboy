package cpu

IF_ADDR :: 0xFF0F
IE_ADDR :: 0xFFFF

// Upper == higher priority
Interrupt :: enum {
	VBLANK = 1 << 0,
	STAT   = 1 << 1,
	TIMER  = 1 << 2,
	SERIAL = 1 << 3,
	JOYPAD = 1 << 4,
}

Interrupt_Set :: u8

interrupt_priority := []Interrupt{
    .VBLANK,
    .STAT,
    .TIMER,
    .SERIAL,
    .JOYPAD,
}

get_interrupt_vector :: proc(i: Interrupt) -> u16 {
    switch i {
    case .VBLANK:
        return 0x0040
    case .STAT:
        return 0x0048
    case .TIMER:
        return 0x0050
    case .SERIAL:
        return 0x0058
    case .JOYPAD:
        return 0x0060
    }

    panic("unreachable")
}

check_interrupt_required :: proc(cpu: ^CPU) -> (Interrupt, bool) {
    if !cpu.irq_enabled && !cpu.halted {
        return {}, false
    }

    raw_flags := read_mem(cpu, IF_ADDR)
    enabled := read_mem(cpu, IE_ADDR)

    flags := transmute(Interrupt_Set)(raw_flags & enabled) // if interrupt is disabled in IE, it will be zeroed

    for intr in interrupt_priority {
        if flags & u8(intr) != 0 {
            return intr, true
        }
    }

    return {}, false
}

set_interrupt :: proc(cpu: ^CPU, intr: Interrupt, val: bool) {
    flags := read_mem(cpu, IF_ADDR)
    flags |= u8(intr)
    write_mem(cpu, IF_ADDR, flags)
}

trigger_interrupt :: proc(cpu: ^CPU, intr: Interrupt) {
    cpu.halted = true

    if cpu.irq_enabled {
        cpu.irq_enabled = false

        vec := get_interrupt_vector(intr)
        push(cpu, cpu.pc)
        cpu.pc = vec

        set_interrupt(cpu, intr, false)
    }
}
