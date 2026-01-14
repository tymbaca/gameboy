package cpu

import "core:testing"

@(test)
merge_u16_test :: proc(t: ^testing.T) {
    testing.expect_value(t, merge_u16(0x43, 0x21), 0x4321)
    testing.expect_value(t, merge_u16(0x00, 0x21), 0x0021)
    testing.expect_value(t, merge_u16(0x43, 0x00), 0x4300)
}

@(test)
split_u16_test :: proc(t: ^testing.T) {
    high, low := split_u16(0x4321)
    testing.expect_value(t, high, 0x43)
    testing.expect_value(t, low, 0x21)
}
