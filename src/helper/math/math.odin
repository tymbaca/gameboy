package helper_math

import "core:math/bits"
import "core:testing"

MAX_U16 :: 65535 
MAX_U8 :: 255 

merge_u16 :: proc(high, low: u8) -> u16 {
    val: u16
    val |= u16(low)
    val |= u16(high) << 8
    return val
}

@(test)
merge_u16_test :: proc(t: ^testing.T) {
    testing.expect_value(t, merge_u16(0x43, 0x21), 0x4321)
    testing.expect_value(t, merge_u16(0x00, 0x21), 0x0021)
    testing.expect_value(t, merge_u16(0x43, 0x00), 0x4300)
}

split_u16 :: proc(val: u16) -> (high, low: u8) {
    low = u8(val & 0x00FF)
    high = u8(val & 0xFF00 >> 8)
    return high, low
}

@(test)
split_u16_test :: proc(t: ^testing.T) {
    left, right := split_u16(0x4321)
    testing.expect_value(t, left, 0x43)
    testing.expect_value(t, right, 0x21)
}

will_carry :: proc(a, b: u8) -> bool {
    _, carry := bits.overflowing_add(a, b)
    return carry
}

will_carry_u16 :: proc(a, b: u16) -> bool {
    _, carry := bits.overflowing_add(a, b)
    return carry
}

@(test)
will_carry_test :: proc(t: ^testing.T) {
    testing.expect(t, will_carry(255, 1) == true)
    testing.expect(t, will_carry(1, 255) == true)
    testing.expect(t, will_carry(200, 56) == true)

    testing.expect(t, will_carry(254, 1) == false)
    testing.expect(t, will_carry(0, 1) == false)
    testing.expect(t, will_carry(255, 0) == false)
    testing.expect(t, will_carry(0, 255) == false)
}

@(test)
will_carry_u16_test :: proc(t: ^testing.T) {
    testing.expect(t, will_carry_u16(65535, 1) == true)
    testing.expect(t, will_carry_u16(1, 65535) == true)
    testing.expect(t, will_carry_u16(65534, 1) == false)
    testing.expect(t, will_carry_u16(0, 1) == false)
    testing.expect(t, will_carry_u16(65535, 0) == false)
    testing.expect(t, will_carry_u16(0, 65535) == false)
}

will_borrow :: proc(a, b: u8) -> bool {
    _, borrow := bits.overflowing_sub(a, b)
    return borrow
}

will_borrow_u16 :: proc(a, b: u16) -> bool {
    _, borrow := bits.overflowing_sub(a, b)
    return borrow
}

@(test)
will_borrow_test :: proc(t: ^testing.T) {
    testing.expect(t, will_borrow(0, 1) == true)
    testing.expect(t, will_borrow(1, 2) == true)
    testing.expect(t, will_borrow(254, 255) == true)

    testing.expect(t, will_borrow(0, 0) == false)
    testing.expect(t, will_borrow(2, 2) == false)
    testing.expect(t, will_borrow(255, 255) == false)
    testing.expect(t, will_borrow(255, 1) == false)
}

@(test)
will_borrow_u16_test :: proc(t: ^testing.T) {
    testing.expect(t, will_borrow_u16(0, 1) == true)
    testing.expect(t, will_borrow_u16(1, 2) == true)
    testing.expect(t, will_borrow_u16(65534, 65535) == true)
    testing.expect(t, will_borrow_u16(65535, 65535) == false)
    testing.expect(t, will_borrow_u16(1, 65535) == true)
    testing.expect(t, will_borrow_u16(65535, 1) == false)
}

will_half_carry :: proc(a, b: u8) -> bool {
    a_lower := a & 0x0F
    b_lower := b & 0x0F
    return (a_lower + b_lower) & 0xF0 != 0
}

will_half_carry_u16 :: proc(a, b: u16) -> bool {
    a_lower := a & 0x0FFF
    b_lower := b & 0x0FFF
    return (a_lower + b_lower) & 0xF000 != 0
}

@(test)
will_half_carry_test :: proc(t: ^testing.T) {
    testing.expect(t, will_half_carry(0b00001111, 1) == true)
    testing.expect(t, will_half_carry(0b11101111, 1) == true)
    testing.expect(t, will_half_carry(0b00011111, 1) == true)
    testing.expect(t, will_half_carry(0b00010001, 0b00001111) == true)

    testing.expect(t, will_half_carry(0b00001110, 1) == false)
    testing.expect(t, will_half_carry(0b00001111, 0) == false)
    testing.expect(t, will_half_carry(0b11101110, 1) == false)
    testing.expect(t, will_half_carry(0b00010000, 0b00001111) == false)
}

@(test)
will_half_carry_u16_test :: proc(t: ^testing.T) {
    testing.expect(t, will_half_carry_u16(0b00001111_00000000, 0x0100) == true)
    testing.expect(t, will_half_carry_u16(0b11101111_00000000, 0x0100) == true)
    testing.expect(t, will_half_carry_u16(0b00011111_00000000, 0x0100) == true)
    testing.expect(t, will_half_carry_u16(0b00010001_00000000, 0b00001111_00000000) == true)

    testing.expect(t, will_half_carry_u16(0b00001110_00000000, 1) == false)
    testing.expect(t, will_half_carry_u16(0b11101110_00000000, 1) == false)
    testing.expect(t, will_half_carry_u16(0b00010000_00000000, 0b00001111_00000000) == false)
}

will_half_borrow :: proc(a, b: u8) -> bool {
    a_lower := a & 0x0F
    b_lower := b & 0x0F
    _, borrow := bits.overflowing_sub(a_lower, b_lower)
    return borrow
}

will_half_borrow_u16 :: proc(a, b: u16) -> bool {
    a_lower := a & 0x0FFF
    b_lower := b & 0x0FFF
    _, borrow := bits.overflowing_sub(a_lower, b_lower)
    return borrow
}

@(test)
will_half_borrow_test :: proc(t: ^testing.T) {
    testing.expect(t, will_half_borrow(0b00010000, 1) == true)
    testing.expect(t, will_half_borrow(0b00110000, 1) == true)
    testing.expect(t, will_half_borrow(0b11110000, 1) == true)

    testing.expect(t, will_half_borrow(0b00010000, 0) == false)
    testing.expect(t, will_half_borrow(0b11110000, 0) == false)
    testing.expect(t, will_half_borrow(0b11110000, 0b00010000) == false)
    testing.expect(t, will_half_borrow(0b00010001, 1) == false)
    testing.expect(t, will_half_borrow(0b11110001, 1) == false)
    testing.expect(t, will_half_borrow(0b00011111, 0b00001111) == false)
}

@(test)
will_half_borrow_u16_test :: proc(t: ^testing.T) {
    testing.expect(t, will_half_borrow_u16(0b00010000_00000000, 0x0100) == true)
    testing.expect(t, will_half_borrow_u16(0b00110000_00000000, 0x0100) == true)
    testing.expect(t, will_half_borrow_u16(0b11110000_00000000, 0x0100) == true)

    testing.expect(t, will_half_borrow_u16(0b00010000_00000000, 0) == false)
    testing.expect(t, will_half_borrow_u16(0b11110000_00000000, 0) == false)
    testing.expect(t, will_half_borrow_u16(0b11110000_00000000, 0b00010000_00000000) == false)
    testing.expect(t, will_half_borrow_u16(0b00010001_00000000, 0x0100) == false)
    testing.expect(t, will_half_borrow_u16(0b11110001_00000000, 0x0100) == false)
    testing.expect(t, will_half_borrow_u16(0b00011111_00000000, 0b00001111_00000000) == false)
}
