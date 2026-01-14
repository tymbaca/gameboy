package helper_math

import "core:math/bits"
import "core:testing"

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
    high, low := split_u16(0x4321)
    testing.expect_value(t, high, 0x43)
    testing.expect_value(t, low, 0x21)
}

will_add_carry :: proc(a, b: u8) -> bool {
    _, carry := bits.overflowing_add(a, b)
    return carry
}

will_add_carry_u16 :: proc(a, b: u16) -> bool {
    _, carry := bits.overflowing_add(a, b)
    return carry
}

@(test)
will_add_carry_test :: proc(t: ^testing.T) {
    testing.expect(t, will_add_carry(255, 1) == true)
    testing.expect(t, will_add_carry(1, 255) == true)
    testing.expect(t, will_add_carry(200, 56) == true)

    testing.expect(t, will_add_carry(254, 1) == false)
    testing.expect(t, will_add_carry(0, 1) == false)
    testing.expect(t, will_add_carry(255, 0) == false)
    testing.expect(t, will_add_carry(0, 255) == false)
}

@(test)
will_add_carry_u16_test :: proc(t: ^testing.T) {
    testing.expect(t, will_add_carry_u16(65535, 1) == true)
    testing.expect(t, will_add_carry_u16(1, 65535) == true)
    testing.expect(t, will_add_carry_u16(65534, 1) == false)
    testing.expect(t, will_add_carry_u16(0, 1) == false)
    testing.expect(t, will_add_carry_u16(65535, 0) == false)
    testing.expect(t, will_add_carry_u16(0, 65535) == false)
}

will_sub_borrow :: proc(a, b: u8) -> bool {
    _, borrow := bits.overflowing_sub(a, b)
    return borrow
}

will_sub_borrow_u16 :: proc(a, b: u16) -> bool {
    _, borrow := bits.overflowing_sub(a, b)
    return borrow
}

@(test)
will_sub_borrow_test :: proc(t: ^testing.T) {
    testing.expect(t, will_sub_borrow(0, 1) == true)
    testing.expect(t, will_sub_borrow(1, 2) == true)
    testing.expect(t, will_sub_borrow(254, 255) == true)

    testing.expect(t, will_sub_borrow(0, 0) == false)
    testing.expect(t, will_sub_borrow(2, 2) == false)
    testing.expect(t, will_sub_borrow(255, 255) == false)
    testing.expect(t, will_sub_borrow(255, 1) == false)
}

@(test)
will_sub_borrow_u16_test :: proc(t: ^testing.T) {
    testing.expect(t, will_sub_borrow_u16(0, 1) == true)
    testing.expect(t, will_sub_borrow_u16(1, 2) == true)
    testing.expect(t, will_sub_borrow_u16(65534, 65535) == true)
    testing.expect(t, will_sub_borrow_u16(65535, 65535) == false)
    testing.expect(t, will_sub_borrow_u16(1, 65535) == true)
    testing.expect(t, will_sub_borrow_u16(65535, 1) == false)
}
