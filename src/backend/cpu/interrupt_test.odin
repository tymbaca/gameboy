package cpu

import "core:testing"
@(test)
interrupts_test :: proc(t: ^testing.T) {
    testing.expect(t, Interrupts{} == 0b00000000)
    testing.expect(t, Interrupts{.VBLANK} == 0b00000001)
    testing.expect(t, Interrupts{.STAT} == 0b00000010)
    testing.expect(t, Interrupts{.TIMER} == 0b00000100)
    testing.expect(t, Interrupts{.SERIAL} == 0b00001000)
    testing.expect(t, Interrupts{.JOYPAD} == 0b00010000)

    testing.expect(t, Interrupts{.VBLANK, .JOYPAD} == 0b00010001)
    testing.expect(t, Interrupts{.VBLANK, .TIMER, .JOYPAD} == 0b00010101)
}
