package cpu

import "core:testing"
import "src:helper/math"

test_cpu :: proc() -> CPU {
	return CPU{}
}

@(test)
inc_test :: proc(t: ^testing.T) {
	cpu := test_cpu()
	f_at_start := cpu.f
	inc_a := inc(.A)

	cpu.a = 1

	inc_a(&cpu)
	testing.expect(t, cpu.a == 2)
	testing.expect(t, cpu.f == f_at_start)

	inc_a(&cpu)
	testing.expect(t, cpu.a == 3)
	testing.expect(t, cpu.f == f_at_start)

	cpu.a = 0b00001111
	inc_a(&cpu)
	testing.expect(t, cpu.a == 0b00010000)
	testing.expect(t, cpu.f.h == true) // half-carry

	inc_a(&cpu)
	testing.expect(t, cpu.a == 0b00010001)
	testing.expect(t, cpu.f == f_at_start)

	cpu.a = 254
	inc_a(&cpu)
	testing.expect(t, cpu.a == math.MAX_U8)
	testing.expect(t, cpu.f == f_at_start)

	inc_a(&cpu)
	testing.expect(t, cpu.a == 0)
	testing.expect(t, cpu.f.z == true) // zero
}

@(test)
inc_u16_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    f_at_start := cpu.f
    inc_hl := inc_u16(.HL)

    set_reg_u16(&cpu, .HL, 1)

    inc_hl(&cpu)
    testing.expect(t, get_reg_u16(&cpu, .HL) == 2)

    inc_hl(&cpu)
    testing.expect(t, get_reg_u16(&cpu, .HL) == 3)

    set_reg_u16(&cpu, .HL, math.MAX_U16)

    inc_hl(&cpu)
    testing.expect(t, get_reg_u16(&cpu, .HL) == 0)
}

@(test)
add_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    f_at_start := cpu.f
    add_ab := add(.A, .B)

    cpu.a = 1
    cpu.b = 2

    add_ab(&cpu)
    testing.expect(t, cpu.a == 3)
    testing.expect(t, cpu.b == 2)
    testing.expect(t, cpu.f == f_at_start)

    add_ab(&cpu)
    testing.expect(t, cpu.a == 5)
    testing.expect(t, cpu.b == 2)
    testing.expect(t, cpu.f == f_at_start)

    cpu.a = 0x0F
    cpu.b = 1
    add_ab(&cpu)
    testing.expect(t, cpu.a == 0x10)
    testing.expect(t, cpu.b == 1)
    testing.expect(t, cpu.f.z == false)
    testing.expect(t, cpu.f.c == false)
    testing.expect(t, cpu.f.h == true)

    cpu.a = 255
    cpu.b = 2
    add_ab(&cpu)
    testing.expect(t, cpu.a == 1)
    testing.expect(t, cpu.b == 2)
    testing.expect(t, cpu.f.z == false)
    testing.expect(t, cpu.f.c == true)
    testing.expect(t, cpu.f.h == true)

    cpu.a = 255
    cpu.b = 1
    add_ab(&cpu)
    testing.expect(t, cpu.a == 0)
    testing.expect(t, cpu.b == 1)
    testing.expect(t, cpu.f.z == true)
    testing.expect(t, cpu.f.c == true)
    testing.expect(t, cpu.f.h == true)
}

// WARNING: AI SLOP

// TODO: remove?
// @(test)
// inc_test :: proc(t: ^testing.T) {
//     cpu := test_cpu()
//     f_at_start := cpu.f
//    
//     // Test INC A
//     cpu.a = 0x0F
//     inc_a := inc(.A)
//     cycles := inc_a(&cpu)
//    
//     testing.expect(t, cpu.a == 0x10, "INC A result mismatch")
//     testing.expect(t, cpu.f.h == true, "Half-carry flag not set")
//     testing.expect(t, cpu.f.n == false, "Negative flag incorrectly set")
//     testing.expect(t, cycles == 1, "INC r cycles mismatch")
//    
//     // Test zero flag
//     cpu.a = math.MAX_U8
//     inc_a(&cpu)
//     testing.expect(t, cpu.a == 0, "INC A overflow mismatch")
//     testing.expect(t, cpu.f.z == true, "Zero flag not set on overflow")
// }

@(test)
dec_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test DEC B
    cpu.b = 0x01
    dec_b := dec(.B)
    cycles := dec_b(&cpu)
    
    testing.expect(t, cpu.b == 0, "DEC B result mismatch")
    testing.expect(t, cpu.f.z == true, "Zero flag not set")
    testing.expect(t, cpu.f.n == true, "Negative flag not set")
    testing.expect(t, cycles == 1, "DEC r cycles mismatch")
    
    // Test half-borrow
    cpu.b = 0x10
    dec_b(&cpu)
    testing.expect(t, cpu.b == 0x0F, "DEC B half-borrow mismatch")
    testing.expect(t, cpu.f.h == true, "Half-borrow flag not set")
}

// TODO: remove?
// @(test)
// inc_u16_test :: proc(t: ^testing.T) {
//     cpu := test_cpu()
//    
//     // Test INC HL
//     set_reg_u16(&cpu, .HL, 0x1234)
//     inc_hl := inc_u16(.HL)
//     cycles := inc_hl(&cpu)
//    
//     testing.expect(t, get_reg_u16(&cpu, .HL) == 0x1235, "INC HL mismatch")
//     testing.expect(t, cycles == 2, "INC rr cycles mismatch")
//    
//     // Test overflow
//     set_reg_u16(&cpu, .HL, math.MAX_U16)
//     inc_hl(&cpu)
//     testing.expect(t, get_reg_u16(&cpu, .HL) == 0, "INC HL overflow mismatch")
// }

@(test)
dec_u16_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test DEC BC
    set_reg_u16(&cpu, .BC, 0x1234)
    dec_bc := dec_u16(.BC)
    cycles := dec_bc(&cpu)
    
    testing.expect(t, get_reg_u16(&cpu, .BC) == 0x1233, "DEC BC mismatch")
    testing.expect(t, cycles == 2, "DEC rr cycles mismatch")
    
    // Test underflow
    set_reg_u16(&cpu, .BC, 0x0000)
    dec_bc(&cpu)
    testing.expect(t, get_reg_u16(&cpu, .BC) == math.MAX_U16, "DEC BC underflow mismatch")
}

@(test)
ld_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test LD A,B
    cpu.b = 0x42
    ld_ab := ld(.A, .B)
    cycles := ld_ab(&cpu)
    
    testing.expect(t, cpu.a == 0x42, "LD A,B failed")
    testing.expect(t, cpu.b == 0x42, "Source B modified incorrectly")
    testing.expect(t, cycles == 1, "LD r,r cycles mismatch")
    
    // Test LD C,D
    cpu.d = 0x99
    ld_cd := ld(.C, .D)
    cycles = ld_cd(&cpu)
    
    testing.expect(t, cpu.c == 0x99, "LD C,D failed")
    testing.expect(t, cpu.d == 0x99, "Source D modified incorrectly")
}

@(test)
ld_u16_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test LD HL,DE
    set_reg_u16(&cpu, .DE, 0x1234)
    ld_hl_de := ld_u16(.HL, .DE)
    cycles := ld_hl_de(&cpu)
    
    testing.expect(t, get_reg_u16(&cpu, .HL) == 0x1234, "LD HL,DE mismatch")
    testing.expect(t, cycles == 2, "LD rr,rr cycles mismatch")
}

@(test)
ld_fv_u8_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    cpu.pc = 0x100
    
    // Test LD A,n
    test_memory[0x100] = 0x42
    ld_a_n := ld_fv_u8(.A)
    cycles := ld_a_n(&cpu)
    
    testing.expect(t, cpu.a == 0x42, "LD A,n failed")
    testing.expect(t, cpu.pc == 0x101, "PC not incremented")
    testing.expect(t, cycles == 2, "LD r,n cycles mismatch")
}

@(test)
ld_fv_u16_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    cpu.pc = 0x100
    
    // Test LD BC,nn
    test_memory[0x100] = 0x34  // low byte
    test_memory[0x101] = 0x12  // high byte
    
    ld_bc_nn := ld_fv_u16(.BC)
    cycles := ld_bc_nn(&cpu)
    
    testing.expect(t, get_reg_u16(&cpu, .BC) == 0x1234, "LD BC,nn failed")
    testing.expect(t, cpu.pc == 0x102, "PC not incremented correctly")
    testing.expect(t, cycles == 3, "LD rr,nn cycles mismatch")
}

// TODO: remove?
// @(test)
// add_test :: proc(t: ^testing.T) {
//     cpu := test_cpu()
//    
//     // Test ADD A,B
//     cpu.a = 0x0F
//     cpu.b = 0x01
//    
//     add_ab := add(.A, .B)
//     cycles := add_ab(&cpu)
//    
//     testing.expect(t, cpu.a == 0x10, "ADD A,B result mismatch")
//     testing.expect(t, cpu.f.h == true, "Half-carry flag not set")
//     testing.expect(t, cpu.f.n == false, "Negative flag incorrectly set")
//     testing.expect(t, cycles == 1, "ADD A,r cycles mismatch")
//    
//     // Test carry
//     cpu.a = 0xFF
//     cpu.b = 0x01
//     add_ab(&cpu)
//    
//     testing.expect(t, cpu.a == 0, "ADD A,B overflow mismatch")
//     testing.expect(t, cpu.f.z == true, "Zero flag not set")
//     testing.expect(t, cpu.f.c == true, "Carry flag not set")
// }

@(test)
sub_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test SUB A,C
    cpu.a = 0x10
    cpu.c = 0x01
    
    sub_ac := sub(.A, .C)
    cycles := sub_ac(&cpu)
    
    testing.expect(t, cpu.a == 0x0F, "SUB A,C result mismatch")
    testing.expect(t, cpu.f.n == true, "Negative flag not set")
    testing.expect(t, cycles == 1, "SUB A,r cycles mismatch")
    
    // Test zero
    cpu.a = 0x01
    cpu.c = 0x01
    sub_ac(&cpu)
    
    testing.expect(t, cpu.a == 0, "SUB A,C zero mismatch")
    testing.expect(t, cpu.f.z == true, "Zero flag not set")
}

@(test)
add_u16_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test ADD HL,BC
    set_reg_u16(&cpu, .HL, 0x0FFF)
    set_reg_u16(&cpu, .BC, 0x0001)
    
    add_hl_bc := add_u16(.HL, .BC)
    cycles := add_hl_bc(&cpu)
    
    testing.expect(t, get_reg_u16(&cpu, .HL) == 0x1000, "ADD HL,BC result mismatch")
    testing.expect(t, cpu.f.h == true, "Half-carry flag not set")
    testing.expect(t, cpu.f.c == false, "Carry flag incorrectly set")
    testing.expect(t, cpu.f.n == false, "Negative flag incorrectly set")
    testing.expect(t, cycles == 2, "ADD HL,rr cycles mismatch")
}

@(test)
add_mem_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test ADD A,(HL)
    set_reg_u16(&cpu, .HL, 0x1234)
    test_memory[0x1234] = 0x0F
    cpu.a = 0x01
    
    add_a_hl := add_86(.A, .HL)
    cycles := add_a_hl(&cpu)
    
    testing.expect(t, cpu.a == 0x10, "ADD A,(HL) result mismatch")
    testing.expect(t, cpu.f.h == true, "Half-carry flag not set")
    testing.expect(t, cycles == 2, "ADD A,(HL) cycles mismatch")
}

@(test)
sub_mem_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test SUB A,(HL)
    set_reg_u16(&cpu, .HL, 0x1234)
    test_memory[0x1234] = 0x01
    cpu.a = 0x10
    
    sub_a_hl := sub_96(.A, .HL)
    cycles := sub_a_hl(&cpu)
    
    testing.expect(t, cpu.a == 0x0F, "SUB A,(HL) result mismatch")
    testing.expect(t, cpu.f.n == true, "Negative flag not set")
    testing.expect(t, cycles == 2, "SUB A,(HL) cycles mismatch")
}

@(test)
ld_ml_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test LD (HL+),A (step = 1)
    set_reg_u16(&cpu, .HL, 0x1234)
    cpu.a = 0x42
    
    ld_hli_a := ld_ml(.HL, .A, 1)
    cycles := ld_hli_a(&cpu)
    
    testing.expect(t, test_memory[0x1234] == 0x42, "LD (HL+),A memory write failed")
    testing.expect(t, get_reg_u16(&cpu, .HL) == 0x1235, "HL not incremented")
    testing.expect(t, cycles == 2, "LD (HL+),A cycles mismatch")
    
    // Test LD (HL-),B (step = -1)
    set_reg_u16(&cpu, .HL, 0x5678)
    cpu.b = 0x99
    
    ld_hld_b := ld_ml(.HL, .B, -1)
    cycles = ld_hld_b(&cpu)
    
    testing.expect(t, test_memory[0x5678] == 0x99, "LD (HL-),B memory write failed")
    testing.expect(t, get_reg_u16(&cpu, .HL) == 0x5677, "HL not decremented")
}

@(test)
ld_mr_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test LD A,(HL+) (step = 1)
    set_reg_u16(&cpu, .HL, 0x1234)
    test_memory[0x1234] = 0x55
    
    ld_a_hli := ld_mr(.A, .HL, 1)
    cycles := ld_a_hli(&cpu)
    
    testing.expect(t, cpu.a == 0x55, "LD A,(HL+) memory read failed")
    testing.expect(t, get_reg_u16(&cpu, .HL) == 0x1235, "HL not incremented")
    testing.expect(t, cycles == 2, "LD A,(HL+) cycles mismatch")
}

@(test)
ld_fmem_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    cpu.pc = 0x100
    
    // Test LD (HL),n
    set_reg_u16(&cpu, .HL, 0x1234)
    test_memory[0x100] = 0x42
    
    ld_hl_n := ld_fmem(.HL)
    cycles := ld_hl_n(&cpu)
    
    testing.expect(t, test_memory[0x1234] == 0x42, "LD (HL),n failed")
    testing.expect(t, cpu.pc == 0x101, "PC not incremented")
    testing.expect(t, cycles == 3, "LD (HL),n cycles mismatch")
}

@(test)
ld_fl_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    cpu.pc = 0x100
    
    // Test LD (nn),A
    test_memory[0x100] = 0x34  // low byte
    test_memory[0x101] = 0x12  // high byte
    cpu.a = 0x42
    
    ld_nn_a := ld_fl(.A)
    cycles := ld_nn_a(&cpu)
    
    testing.expect(t, test_memory[0x1234] == 0x42, "LD (nn),A failed")
    testing.expect(t, cpu.pc == 0x102, "PC not incremented correctly")
    testing.expect(t, cycles == 4, "LD (nn),A cycles mismatch")
}

@(test)
ld_fr_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    cpu.pc = 0x100
    
    // Test LD A,(nn)
    test_memory[0x100] = 0x34  // low byte
    test_memory[0x101] = 0x12  // high byte
    test_memory[0x1234] = 0x99
    cpu.a = 0
    
    ld_a_nn := ld_fr(.A)
    cycles := ld_a_nn(&cpu)
    
    testing.expect(t, cpu.a == 0x99, "LD A,(nn) failed")
    testing.expect(t, cpu.pc == 0x102, "PC not incremented correctly")
    testing.expect(t, cycles == 4, "LD A,(nn) cycles mismatch")
}

@(test)
ld_fl_u16_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    cpu.pc = 0x100
    
    // Test LD (nn),SP
    set_reg_u16(&cpu, .SP, 0x1234)
    test_memory[0x100] = 0x34  // low byte
    test_memory[0x101] = 0x12  // high byte
    
    ld_nn_sp := ld_fl_u16(.SP)
    cycles := ld_nn_sp(&cpu)
    
    testing.expect(t, test_memory[0x1234] == 0x34, "LD (nn),SP low byte failed")
    testing.expect(t, test_memory[0x1235] == 0x12, "LD (nn),SP high byte failed")
    testing.expect(t, cpu.pc == 0x102, "PC not incremented correctly")
    testing.expect(t, cycles == 5, "LD (nn),SP cycles mismatch")
}

@(test)
ld_ff_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    cpu.pc = 0x100
    
    // Test LD (FF00+u8),A
    test_memory[0x100] = 0x80  // offset
    cpu.a = 0x42
    
    ld_ffu8_l(&cpu)
    
    testing.expect(t, test_memory[0xFF80] == 0x42, "LD (FF00+u8),A failed")
    testing.expect(t, cpu.pc == 0x101, "PC not incremented")
    
    // Test LD (FF00+C),A
    cpu.c = 0x90
    cpu.a = 0x99
    
    ld_ffc_l(&cpu)
    
    testing.expect(t, test_memory[0xFF90] == 0x99, "LD (FF00+C),A failed")
    
    // Test LD A,(FF00+u8)
    cpu.pc = 0x100
    test_memory[0x100] = 0xA0
    test_memory[0xFFA0] = 0x55
    
    ld_ffu8_r(&cpu)
    
    testing.expect(t, cpu.a == 0x55, "LD A,(FF00+u8) failed")
    
    // Test LD A,(FF00+C)
    cpu.c = 0xB0
    test_memory[0xFFB0] = 0x77
    
    ld_ffc_r(&cpu)
    
    testing.expect(t, cpu.a == 0x77, "LD A,(FF00+C) failed")
}

@(test)
ld_F8_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    cpu.pc = 0x100
    
    // Test LD HL,SP+e8 with positive offset
    cpu.sp = 0x0FFF
    test_memory[0x100] = 0x01  // +1 as i8
    
    ld_F8(&cpu)
    
    testing.expect(t, get_reg_u16(&cpu, .HL) == 0x1000, "LD HL,SP+1 failed")
    testing.expect(t, cpu.f.h == true, "Half-carry flag not set")
    testing.expect(t, cpu.f.c == false, "Carry flag incorrectly set")
    testing.expect(t, cpu.pc == 0x101, "PC not incremented")
}

@(test)
inc_mem_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test INC (HL)
    set_reg_u16(&cpu, .HL, 0x1234)
    test_memory[0x1234] = 0x0F
    
    cycles := inc_34(&cpu)
    
    testing.expect(t, test_memory[0x1234] == 0x10, "INC (HL) failed")
    testing.expect(t, cpu.f.h == true, "Half-carry flag not set")
    testing.expect(t, cpu.f.n == false, "Negative flag incorrectly set")
    testing.expect(t, cycles == 3, "INC (HL) cycles mismatch")
}

@(test)
dec_mem_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test DEC (HL)
    set_reg_u16(&cpu, .HL, 0x1234)
    test_memory[0x1234] = 0x01
    
    cycles := dec_35(&cpu)
    
    testing.expect(t, test_memory[0x1234] == 0x00, "DEC (HL) failed")
    testing.expect(t, cpu.f.z == true, "Zero flag not set")
    testing.expect(t, cpu.f.n == true, "Negative flag not set")
    testing.expect(t, cycles == 3, "DEC (HL) cycles mismatch")
}

@(test)
nop_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    cycles := nop_00(&cpu)
    
    testing.expect(t, cycles == 1, "NOP cycles mismatch")
    // NOP should not modify CPU state
}

@(test)
flag_reg_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test individual flag setting/clearing
    cpu.f.z = true
    cpu.f.n = true
    cpu.f.h = true
    cpu.f.c = true
    
    testing.expect(t, cpu.f.z == true, "Z flag not set")
    testing.expect(t, cpu.f.n == true, "N flag not set")
    testing.expect(t, cpu.f.h == true, "H flag not set")
    testing.expect(t, cpu.f.c == true, "C flag not set")
    
    // Test as u8
    flags := u8(cpu.f)
    // Bits: Z=7, N=6, H=5, C=4 (1-indexed from left)
    expected: u8 = 0b11110000
    testing.expect(t, flags == expected, "Flag bitfield mismatch")
    
    // Test setting from u8
    cpu.f = Flag_Reg(0b10100000)  // Z and H set
    testing.expect(t, cpu.f.z == true, "Z flag not set from u8")
    testing.expect(t, cpu.f.n == false, "N flag incorrectly set from u8")
    testing.expect(t, cpu.f.h == true, "H flag not set from u8")
    testing.expect(t, cpu.f.c == false, "C flag incorrectly set from u8")
}

@(test)
add_reg_u16_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test positive delta
    set_reg_u16(&cpu, .HL, 0x1234)
    add_reg_u16(&cpu, .HL, 5)
    testing.expect(t, get_reg_u16(&cpu, .HL) == 0x1239, "add_reg_u16 positive delta failed")
    
    // Test negative delta
    add_reg_u16(&cpu, .HL, -3)
    testing.expect(t, get_reg_u16(&cpu, .HL) == 0x1236, "add_reg_u16 negative delta failed")
}

@(test)
set_flag_functions_test :: proc(t: ^testing.T) {
    cpu := test_cpu()
    
    // Test set_flag_z0hc (for addition)
    cpu.a = 0x0F
    cpu.b = 0x01
    set_flag_z0hc(&cpu, cpu.a, cpu.b)
    
    testing.expect(t, cpu.f.z == false, "set_flag_z0hc: Zero flag incorrect")
    testing.expect(t, cpu.f.n == false, "set_flag_z0hc: Negative flag should be false")
    testing.expect(t, cpu.f.h == true, "set_flag_z0hc: Half-carry flag not set")
    
    // Test set_flag_z1hc (for subtraction)
    cpu.a = 0x10
    cpu.b = 0x01
    set_flag_z1hc(&cpu, cpu.a, cpu.b)
    
    testing.expect(t, cpu.f.z == false, "set_flag_z1hc: Zero flag incorrect")
    testing.expect(t, cpu.f.n == true, "set_flag_z1hc: Negative flag should be true")
    testing.expect(t, cpu.f.h == true, "set_flag_z1hc: Half-borrow flag not set")
}

@(test)
add_u16_i8_function_test :: proc(t: ^testing.T) {
    // Test the standalone add_u16_i8 function
    // Positive offset
    result, flags := add_u16_i8(0x0FFF, 1)
    testing.expect(t, result == 0x1000, "add_u16_i8 positive offset failed")
    testing.expect(t, flags.h == true, "add_u16_i8: Half-carry flag not set")
    testing.expect(t, flags.n == false, "add_u16_i8: Negative flag should be false")
    testing.expect(t, flags.z == false, "add_u16_i8: Zero flag should be false")
    
    // Negative offset
    result, flags = add_u16_i8(0x1000, -1)
    testing.expect(t, result == 0x0FFF, "add_u16_i8 negative offset failed")
    testing.expect(t, flags.h == true, "add_u16_i8: Half-borrow flag not set")
    
    // Zero offset
    result, flags = add_u16_i8(0x1234, 0)
    testing.expect(t, result == 0x1234, "add_u16_i8 zero offset failed")
    testing.expect(t, flags.h == false, "add_u16_i8: Half-carry should be false")
    testing.expect(t, flags.c == false, "add_u16_i8: Carry should be false")
}
