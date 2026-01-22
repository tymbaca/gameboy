package cpu

import "base:runtime"
import "core:fmt"
import "core:testing"


@(test)
get_set_reg_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test 8-bit registers with one example each
    set_reg(&cpu, .A, 0x12)
    testing.expect(t, get_reg(&cpu, .A) == 0x12, "A register mismatch")
    
    set_reg(&cpu, .B, 0x34)
    testing.expect(t, get_reg(&cpu, .B) == 0x34, "B register mismatch")
    
    set_reg(&cpu, .F, 0xF0)
    testing.expect(t, get_reg(&cpu, .F) == 0xF0, "F register mismatch")
}

@(test)
get_set_reg_u16_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    set_reg_u16(&cpu, .PC, 0x1234)
    testing.expect(t, get_reg_u16(&cpu, .PC) == 0x1234, "PC mismatch")
    
    set_reg_u16(&cpu, .SP, 0x5678)
    testing.expect(t, get_reg_u16(&cpu, .SP) == 0x5678, "SP mismatch")
    
    set_reg_u16(&cpu, .AF, 0x5678)
    testing.expect(t, cpu.a == 0x78, "A from AF mismatch")
    testing.expect(t, u8(cpu.f) == 0x56, "F from AF mismatch")
    testing.expect(t, get_reg_u16(&cpu, .AF) == 0x5678, "AF get mismatch")
    
    testing.expect(t, cpu.b == 0xBC, "B from BC mismatch")
    testing.expect(t, cpu.c == 0x9A, "C from BC mismatch")
}

@(test)
fetch_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    cpu.pc = 0x1234
    
    // Test fetch
    write_mem(&cpu, 0x1234, 0x42)
    val := fetch(&cpu)
    
    testing.expect(t, val == 0x42, "fetch value mismatch")
    testing.expect(t, cpu.pc == 0x1235, "PC not incremented after fetch")
    
    // Test fetch_u16
    cpu.pc = 0x1234
    write_mem(&cpu, 0x1234, 0x34)
    write_mem(&cpu, 0x1235, 0x12)
    
    val16 := fetch_u16(&cpu)
    
    testing.expect(t, val16 == 0x1234, "fetch_u16 value mismatch")
    testing.expect(t, cpu.pc == 0x1236, "PC not incremented correctly after fetch_u16")
}

@(test)
pop_push_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    push(&cpu, 0x1234)
    push(&cpu, 0x2345)
    push(&cpu, 0x3456)
    testing.expect(t, pop(&cpu) == 0x3456)
    testing.expect(t, pop(&cpu) == 0x2345)
    testing.expect(t, pop(&cpu) == 0x1234)
}

@(test)
jp_jr_test :: proc(t: ^testing.T) {
    cpu := test_cpu()

    cpu.pc = 0x0000
    write_mem(&cpu, 0x0000, 0xC3) // JP 0x1234
    write_mem(&cpu, 0x0001, 0x34)
    write_mem(&cpu, 0x0002, 0x12)

    execute(&cpu)
    testing.expect_value(t, cpu.pc, 0x1234)

    write_mem(&cpu, 0x1234, 0xC2) // JP NZ 0x2200
    write_mem(&cpu, 0x1235, 0x00)
    write_mem(&cpu, 0x1236, 0x22)

    execute(&cpu)
    testing.expect_value(t, cpu.pc, 0x2200)

    cpu.f.z = true
    write_mem(&cpu, 0x2200, 0xC2) // JP NZ 0x3300
    write_mem(&cpu, 0x2201, 0x00)
    write_mem(&cpu, 0x2202, 0x33)

    execute(&cpu)
    testing.expect_value(t, cpu.pc, 0x2203)

    write_mem(&cpu, 0x2203, 0x18) // JR +36
    write_mem(&cpu, 0x2204, 36)

    execute(&cpu)
    testing.expect_value(t, cpu.pc, 0x2225) // 0x2205 + 0x0020 (36)

    write_mem(&cpu, 0x2225, 0x18) // JR C -16
    write_mem(&cpu, 0x2226, transmute(u8)i8(-16))

    execute(&cpu)
    testing.expect_value(t, cpu.pc, 0x2227) // didn't happen

    cpu.pc = 0x2225
    cpu.f.c = true
    execute(&cpu)
    testing.expect_value(t, cpu.pc, 0x2217) // 0x2225 - 0x0010 (16)
}
