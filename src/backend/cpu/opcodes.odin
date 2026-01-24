package cpu

import "core:math/bits"
import "src:helper/math"

// https://izik1.github.io/gbops/

OPCODES: [256]proc(^CPU) -> u8 = {
//  0x00,              0x01,            0x02,             0x03,            0x04,               0x05,            0x06,            0x07,            0x08,             0x09,             0x0A,             0x0B,         0x0C,               0x0D,       0x0E,            0x0F
    nop_00,            ld_fv_u16(.BC),  ld_ml(.BC,.A, 0), inc_u16(.BC),    inc(.B),            dec(.B),         ld_fv_u8(.B),    todo,            ld_fl_u16(.SP),   add_u16(.HL,.BC), ld_mr(.A,.BC, 0), dec_u16(.BC), inc(.C),            dec(.C),    ld_fv_u8(.C),    todo,       // 0x00
    todo,              ld_fv_u16(.DE),  ld_ml(.DE,.A, 0), inc_u16(.DE),    inc(.D),            dec(.D),         ld_fv_u8(.D),    todo,            jr_18,            add_u16(.HL,.DE), ld_mr(.A,.DE, 0), dec_u16(.DE), inc(.E),            dec(.E),    ld_fv_u8(.E),    todo,       // 0x10
    jr_if(.Z, false),  ld_fv_u16(.HL),  ld_ml(.HL,.A, 1), inc_u16(.HL),    inc(.H),            dec(.H),         ld_fv_u8(.H),    todo,            jr_if(.Z, true),  add_u16(.HL,.HL), ld_mr(.A,.HL, 1), dec_u16(.HL), inc(.L),            dec(.L),    ld_fv_u8(.L),    todo,       // 0x20
    jr_if(.C, false),  ld_fv_u16(.SP),  ld_ml(.HL,.A,-1), inc_u16(.SP),    inc_34,             dec_35,          ld_fmem(.HL),    todo,            jr_if(.C, true),  add_u16(.HL,.SP), ld_mr(.A,.HL,-1), dec_u16(.SP), inc(.A),            dec(.A),    ld_fv_u8(.A),    todo,       // 0x30
    ld(.B,.B),         ld(.B,.C),       ld(.B,.D),        ld(.B,.E),       ld(.B,.H),          ld(.B,.L),       ld_mr(.B,.HL,0), ld(.B,.A),       ld(.C,.B),        ld(.C,.C),        ld(.C,.D),        ld(.C,.E),    ld(.C,.H),          ld(.C,.L),  ld_mr(.C,.HL,0), ld(.C,.A),  // 0x40
    ld(.D,.B),         ld(.D,.C),       ld(.D,.D),        ld(.D,.E),       ld(.D,.H),          ld(.D,.L),       ld_mr(.D,.HL,0), ld(.D,.A),       ld(.E,.B),        ld(.E,.C),        ld(.E,.D),        ld(.E,.E),    ld(.E,.H),          ld(.E,.L),  ld_mr(.E,.HL,0), ld(.E,.A),  // 0x50
    ld(.H,.B),         ld(.H,.C),       ld(.H,.D),        ld(.H,.E),       ld(.H,.H),          ld(.H,.L),       ld_mr(.H,.HL,0), ld(.H,.A),       ld(.L,.B),        ld(.L,.C),        ld(.L,.D),        ld(.L,.E),    ld(.L,.H),          ld(.L,.L),  ld_mr(.L,.HL,0), ld(.L,.A),  // 0x60
    ld_ml(.HL,.B,0),   ld_ml(.HL,.C,0), ld_ml(.HL,.D,0),  ld_ml(.HL,.E,0), ld_ml(.HL,.H,0),    ld_ml(.HL,.L,0), todo,            ld_ml(.HL,.A,0), ld(.A,.B),        ld(.A,.C),        ld(.A,.D),        ld(.A,.E),    ld(.A,.H),          ld(.A,.L),  ld_mr(.A,.HL,0), ld(.A,.A),  // 0x70
    add(.A,.B),        add(.A,.C),      add(.A,.D),       add(.A,.E),      add(.A,.H),         add(.A,.L),      add_86(.A,.HL),  add(.A,.A),      adc(.A,.B),       adc(.A,.C),       adc(.A,.D),       adc(.A,.E),   adc(.A,.H),         adc(.A,.L), adc_8E(.A,.HL),  adc(.A,.A), // 0x80
    sub(.A,.B),        sub(.A,.C),      sub(.A,.D),       sub(.A,.E),      sub(.A,.H),         sub(.A,.L),      sub_96(.A,.HL),  sub(.A,.A),      sbc(.A,.B),       sbc(.A,.C),       sbc(.A,.D),       sbc(.A,.E),   sbc(.A,.H),         sbc(.A,.L), sbc_9E(.A,.HL),  sbc(.A,.A), // 0x90
    and(.A,.B),        and(.A,.C),      and(.A,.D),       and(.A,.E),      and(.A,.H),         and(.A,.L),      and_A6(.A,.HL),  and(.A,.A),      xor(.A,.B),       xor(.A,.C),       xor(.A,.D),       xor(.A,.E),   xor(.A,.H),         xor(.A,.L), xor_AE(.A,.HL),  xor(.A,.A), // 0xA0
    or(.A,.B),         or(.A,.C),       or(.A,.D),        or(.A,.E),       or(.A,.H),          or(.A,.L),       or_B6(.A,.HL),   or(.A,.A),       cp(.A,.B),        cp(.A,.C),        cp(.A,.D),        cp(.A,.E),    cp(.A,.H),          cp(.A,.L),  cp_BE(.A,.HL),   cp(.A,.A),  // 0xB0
    ret_if(.Z, false), pop_reg(.BC),    jp_if(.Z, false), jp_C3,           call_if(.Z, false), push_reg(.BC),   add_C6(.A),      todo,            ret_if(.Z, true), ret_c9,           jp_if(.Z, true),  todo,         call_if(.Z, false), call_cd,    adc_CE(.A),      todo,       // 0xC0
    ret_if(.C, false), pop_reg(.DE),    jp_if(.C, false), todo,            call_if(.C, false), push_reg(.DE),   sub_D6(.A),      todo,            ret_if(.C, true), todo,             jp_if(.C, true),  todo,         call_if(.C, false), todo,       sbc_DE(.A),      todo,       // 0xD0
    ld_ffu8_l,         pop_reg(.HL),    ld_ffc_l,         todo,            todo,               push_reg(.HL),   and_E6(.A),      todo,            add_E8,           jp_E9,            ld_fl(.A),        todo,         todo,               todo,       and_E6(.A),      todo,       // 0xE0
    ld_ffu8_r,         pop_reg(.AF),    ld_ffc_r,         todo,            todo,               push_reg(.AF),   or_F6(.A),       todo,            ld_F8,            ld_u16(.SP,.HL),  ld_fr(.A),        todo,         todo,               todo,       or_F6(.A),       todo,       // 0xF0
}

OPCODES_CB: [256]proc(^CPU) -> u8 = {
//  0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x00
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x10
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x20
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x30
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x40
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x50
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x60
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x70
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x80
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0x90
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0xA0
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0xB0
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0xC0
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0xD0
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0xE0
    todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, todo, // 0xF0
}

todo :: proc(^CPU) -> u8 {
    panic("not implemented")
}

nop_00 :: proc(cpu: ^CPU) -> u8 {
    return 1
}

inc :: proc($reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg(cpu, reg)

        cpu.f.z = (val + 1) == 0
        cpu.f.n = false
        cpu.f.h = math.will_half_carry(val, 1)
        
        set_reg(cpu, reg, val + 1)

        return 1
    }
}

inc_u16 :: proc($reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg_u16(cpu, reg)
        set_reg_u16(cpu, reg, val + 1)

        return 2
    }
}

inc_34 :: proc(cpu: ^CPU) -> u8 {
    addr := get_reg_u16(cpu, .HL)
    val := read_mem(cpu, addr)

    cpu.f.z = (val + 1) == 0
    cpu.f.n = false
    cpu.f.h = math.will_half_carry(val, 1)

    write_mem(cpu, addr, val + 1)

    return 3
}

dec :: proc($reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg(cpu, reg)

        cpu.f.z = (val - 1) == 0
        cpu.f.n = true
        cpu.f.h = math.will_half_borrow(val, 1)
        
        set_reg(cpu, reg, val - 1)

        return 1
    }
}

dec_u16 :: proc($reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg_u16(cpu, reg)
        set_reg_u16(cpu, reg, val - 1)

        return 2
    }
}

dec_35 :: proc(cpu: ^CPU) -> u8 {
    addr := get_reg_u16(cpu, .HL)
    val := read_mem(cpu, addr)

    cpu.f.z = (val - 1) == 0
    cpu.f.n = true
    cpu.f.h = math.will_half_borrow(val, 1)

    write_mem(cpu, addr, val - 1)

    return 3
}

add :: proc($left_reg, $right_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := get_reg(cpu, right_reg)
        add_helper(cpu, left_reg, right, false)

        return 1
    }
}

// ADD A,(HL)
add_86 :: proc($left_reg: Reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := read_mem(cpu, get_reg_u16(cpu, right_reg))
        add_helper(cpu, left_reg, right, false)

        return 2
    }
}

// ADD A,u8
add_C6 :: proc($left_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := fetch(cpu)
        add_helper(cpu, left_reg, right, false)

        return 2
    }
}

// ADD SP,i8
add_E8 :: proc(cpu: ^CPU) -> u8 {
    val := fetch_i8(cpu)
    sp := get_reg_u16(cpu, .SP)

    res, flags := add_u16_i8(sp, val)

    set_reg_u16(cpu, .SP, res)
    cpu.f = flags

    return 4
}

add_u16 :: proc($left_reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        left := get_reg_u16(cpu, left_reg)
        right := get_reg_u16(cpu, right_reg)

        // cpu.f.z untouched
        cpu.f.n = false
        cpu.f.h = math.will_half_carry_u16(left, right)
        cpu.f.c = math.will_carry_u16(left, right)

        set_reg_u16(cpu, left_reg, left + right)

        return 2
    }
}

adc :: proc($left_reg, $right_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := get_reg(cpu, right_reg)
        add_helper(cpu, left_reg, right, true)

        return 1
    }
}

// ADC A,(HL)
adc_8E :: proc($left_reg: Reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := read_mem(cpu, get_reg_u16(cpu, right_reg))
        add_helper(cpu, left_reg, right, true)

        return 2
    }
}

// ADC A,u8
adc_CE :: proc($left_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := fetch(cpu)
        add_helper(cpu, left_reg, right, true)

        return 2
    }
}

add_helper :: proc(cpu: ^CPU, left_reg: Reg, right_val: u8, use_carry: bool) {
    carry: u8 = 0
    if use_carry && cpu.f.c {
        carry = 1
    }

    left_val := get_reg(cpu, left_reg)

    h1 := math.will_half_carry(left_val, right_val)
    c1 := math.will_carry(left_val, right_val)

    left_val += right_val

    h2 := math.will_half_carry(left_val, carry)
    c2 := math.will_carry(left_val, carry)

    left_val += carry

    cpu.f.z = left_val == 0
    cpu.f.n = false
    cpu.f.h = h1 || h2
    cpu.f.c = c1 || c2

    set_reg(cpu, left_reg, left_val)
}

sub :: proc($left_reg, $right_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := get_reg(cpu, right_reg)
        sub_helper(cpu, left_reg, right, false)

        return 1
    }
}

// SUB A,(HL)
sub_96 :: proc($left_reg: Reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := read_mem(cpu, get_reg_u16(cpu, right_reg))
        sub_helper(cpu, left_reg, right, false)

        return 2
    }
}

// SUB A,u8
sub_D6 :: proc($left_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := fetch(cpu)
        sub_helper(cpu, left_reg, right, false)

        return 2
    }
}

sbc :: proc($left_reg, $right_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := get_reg(cpu, right_reg)
        sub_helper(cpu, left_reg, right, true)

        return 1
    }
}

// SBC A,(HL)
sbc_9E :: proc($left_reg: Reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := read_mem(cpu, get_reg_u16(cpu, right_reg))
        sub_helper(cpu, left_reg, right, true)

        return 2
    }
}

// SUB A,u8
sbc_DE :: proc($left_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := fetch(cpu)
        sub_helper(cpu, left_reg, right, true)

        return 2
    }
}

sub_helper :: proc(cpu: ^CPU, left_reg: Reg, right_val: u8, use_carry: bool) {
    carry: u8 = 0
    if use_carry && cpu.f.c {
        carry = 1
    }

    left_val := get_reg(cpu, left_reg)

    h1 := math.will_half_borrow(left_val, right_val)
    c1 := math.will_borrow(left_val, right_val)

    left_val -= right_val

    h2 := math.will_half_borrow(left_val, carry)
    c2 := math.will_borrow(left_val, carry)

    left_val -= carry

    cpu.f.z = left_val == 0
    cpu.f.n = true
    cpu.f.h = h1 || h2
    cpu.f.c = c1 || c2

    set_reg(cpu, left_reg, left_val)
}

and :: proc($left_reg, $right_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := get_reg(cpu, right_reg)
        and_helper(cpu, left_reg, right)

        return 1
    }
}

and_A6 :: proc($left_reg: Reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := read_mem(cpu, get_reg_u16(cpu, right_reg))
        and_helper(cpu, left_reg, right)

        return 2
    }
}

and_E6 :: proc($left_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := fetch(cpu)
        and_helper(cpu, left_reg, right)

        return 2
    }
}

and_helper :: proc(cpu: ^CPU, left_reg: Reg, right_val: u8) {
    left_val := get_reg(cpu, left_reg)
    left_val &= right_val
    set_reg(cpu, left_reg, left_val)

    cpu.f.z = left_val == 0
    cpu.f.n = false
    cpu.f.h = true
    cpu.f.c = false
}

or :: proc($left_reg, $right_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := get_reg(cpu, right_reg)
        or_helper(cpu, left_reg, right)

        return 1
    }
}

or_B6 :: proc($left_reg: Reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := read_mem(cpu, get_reg_u16(cpu, right_reg))
        or_helper(cpu, left_reg, right)

        return 2
    }
}

or_F6 :: proc($left_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := fetch(cpu)
        or_helper(cpu, left_reg, right)

        return 2
    }
}

or_helper :: proc(cpu: ^CPU, left_reg: Reg, right_val: u8) {
    left_val := get_reg(cpu, left_reg)
    left_val |= right_val
    set_reg(cpu, left_reg, left_val)

    cpu.f.z = left_val == 0
    cpu.f.n = false
    cpu.f.h = false
    cpu.f.c = false
}

xor :: proc($left_reg, $right_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := get_reg(cpu, right_reg)
        xor_helper(cpu, left_reg, right)

        return 1
    }
}

xor_AE :: proc($left_reg: Reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := read_mem(cpu, get_reg_u16(cpu, right_reg))
        xor_helper(cpu, left_reg, right)

        return 2
    }
}

xor_EE :: proc($left_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := fetch(cpu)
        xor_helper(cpu, left_reg, right)

        return 2
    }
}

xor_helper :: proc(cpu: ^CPU, left_reg: Reg, right_val: u8) {
    left_val := get_reg(cpu, left_reg)
    left_val ~= right_val
    set_reg(cpu, left_reg, left_val)

    cpu.f.z = left_val == 0
    cpu.f.n = false
    cpu.f.h = false
    cpu.f.c = false
}

cp :: proc($left_reg, $right_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := get_reg(cpu, right_reg)
        cp_helper(cpu, left_reg, right)

        return 1
    }
}

cp_BE :: proc($left_reg: Reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := read_mem(cpu, get_reg_u16(cpu, right_reg))
        cp_helper(cpu, left_reg, right)

        return 2
    }
}

cp_FE :: proc($left_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        right := fetch(cpu)
        cp_helper(cpu, left_reg, right)

        return 2
    }
}

cp_helper :: proc(cpu: ^CPU, left_reg: Reg, right_val: u8) {
    left_val := get_reg(cpu, left_reg)
    h := math.will_half_borrow(left_val, right_val)
    c := math.will_borrow(left_val, right_val)
    left_val -= right_val

    cpu.f.z = left_val == 0
    cpu.f.n = true
    cpu.f.h = h
    cpu.f.c = c
}

ld :: proc($left_reg, $right_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg(cpu, right_reg)
        set_reg(cpu, left_reg, val)

        return 1
    }
}

ld_u16 :: proc($left_reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg_u16(cpu, right_reg)
        set_reg_u16(cpu, left_reg, val)

        return 2
    }
}

// load memory into left
ld_ml :: proc($left_reg: Reg_u16, $right_reg: Reg, $step: i8) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg(cpu, right_reg)
        write_mem(cpu, get_reg_u16(cpu, left_reg), val)

        add_reg_u16(cpu, left_reg, step)

        return 2
    }
}

// load memory from right
ld_mr :: proc($left_reg: Reg, $right_reg: Reg_u16, $step: i8) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := read_mem(cpu, get_reg_u16(cpu, right_reg))
        set_reg(cpu, left_reg, val)

        add_reg_u16(cpu, right_reg, step)

        return 2
    }
}

// load fetched value into reg
ld_fv_u8 :: proc($reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := fetch(cpu)
        set_reg(cpu, reg, val)

        return 2
    }
}

// load fetched value into u16 reg
ld_fv_u16 :: proc($reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := fetch_u16(cpu)
        set_reg_u16(cpu, reg, val)

        return 3
    }
}

// load fetched value into (reg) address
ld_fmem :: proc($reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := fetch(cpu)
        addr := get_reg_u16(cpu, reg)
        write_mem(cpu, addr, val)

        return 3
    }
}

// load into fetched address
ld_fl :: proc($reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg(cpu, reg)
        addr := fetch_u16(cpu)
        write_mem(cpu, addr, val)

        return 4
    }
}

// load Reg_u16 into fetched address
ld_fl_u16 :: proc($reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg_u16(cpu, reg)
        high, low := math.split_u16(val)

        addr := fetch_u16(cpu)
        write_mem(cpu, addr, low)
        write_mem(cpu, addr+1, high)

        return 5
    }
}

// load from fetched address
ld_fr :: proc($reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        addr := fetch_u16(cpu)
        val := read_mem(cpu, addr)
        set_reg(cpu, reg, val)

        return 4
    }
}

// LD HL,SP+i8
ld_F8 :: proc(cpu: ^CPU) -> u8 {
    val := fetch_i8(cpu)
    sp := get_reg_u16(cpu, .SP)

    res, flags := add_u16_i8(sp, val)
    
    set_reg_u16(cpu, .HL, res)
    cpu.f = flags

    return 3
}

// LD (FF00+u8),A - 0xE0
ld_ffu8_l :: proc(cpu: ^CPU) -> u8 {
    addr_low := fetch(cpu)
    addr := 0xFF00 + u16(addr_low)

    val := get_reg(cpu, .A)
    write_mem(cpu, addr, val)

    return 3
}

// LD (FF00+C),A - 0xE2
ld_ffc_l :: proc(cpu: ^CPU) -> u8 {
    addr_low := get_reg(cpu, .C)
    addr := 0xFF00 + u16(addr_low)

    val := get_reg(cpu, .A)
    write_mem(cpu, addr, val)

    return 2
}

// LD A,(FF00+u8) - 0xF0
ld_ffu8_r :: proc(cpu: ^CPU) -> u8 {
    addr_low := fetch(cpu)
    addr := 0xFF00 + u16(addr_low)

    val := read_mem(cpu, addr)
    set_reg(cpu, .A, val)

    return 3
}

// LD A,(FF00+C) - 0xF2
ld_ffc_r :: proc(cpu: ^CPU) -> u8 {
    addr_low := get_reg(cpu, .C)
    addr := 0xFF00 + u16(addr_low)

    val := read_mem(cpu, addr)
    set_reg(cpu, .A, val)

    return 2
}

pop_reg :: proc($reg: Reg_u16) -> proc(^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := pop(cpu)
        set_reg_u16(cpu, reg, val)

        return 3
    }
}

push_reg :: proc($reg: Reg_u16) -> proc(^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg_u16(cpu, reg)
        push(cpu, val)

        return 4
    }
}

jp_if :: proc($flag: Flag_Kind, $is: bool) -> proc(^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        addr := fetch_u16(cpu)

        if get_flag(cpu, flag) == is {
            set_reg_u16(cpu, .PC, addr)
            return 4
        } else {
            return 3
        }
    }
}

jp_C3 :: proc(cpu: ^CPU) -> u8 {
    addr := fetch_u16(cpu)
    set_reg_u16(cpu, .PC, addr)
    return 4
}

jp_E9 :: proc(cpu: ^CPU) -> u8 {
    addr := get_reg_u16(cpu, .HL)
    set_reg_u16(cpu, .PC, addr)
    return 1
}

jr_if :: proc($flag: Flag_Kind, $is: bool) -> proc(^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        offset := fetch_i8(cpu)

        addr := get_reg_u16(cpu, .PC)
        if get_flag(cpu, flag) == is {
            addr, _ = add_u16_i8(addr, offset)
            set_reg_u16(cpu, .PC, addr)
            return 3
        } else {
            return 2
        }
    }
}

jr_18 :: proc(cpu: ^CPU) -> u8 {
    offset := fetch_i8(cpu)
    addr := get_reg_u16(cpu, .PC)
    addr, _ = add_u16_i8(addr, offset)
    set_reg_u16(cpu, .PC, addr)
    return 3
}

call_cd :: proc(cpu: ^CPU) -> u8 {
    addr := fetch_u16(cpu)
    push(cpu, cpu.pc)
    cpu.pc = addr
    return 6
}

call_if :: proc($flag: Flag_Kind, $is: bool) -> proc(^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        addr := fetch_u16(cpu)

        if get_flag(cpu, flag) == is {
            push(cpu, cpu.pc)
            cpu.pc = addr
            return 6
        } else {
            return 3
        }
    }
}

ret_c9 :: proc(cpu: ^CPU) -> u8 {
    addr := pop(cpu)
    cpu.pc = addr
    return 4
}

ret_if :: proc($flag: Flag_Kind, $is: bool) -> proc(^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        if get_flag(cpu, flag) == is {
            addr := pop(cpu)
            cpu.pc = addr
            return 5
        } else {
            return 2
        }
    }
}

prefix_cb :: proc(cpu: ^CPU) -> u8 {
    op := fetch(cpu)
    return OPCODES_CB[op](cpu)
}

rl :: proc($reg: Reg, $carry: bool) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg(cpu, reg)
        res, overflow := math.rotate_left(val)

        if carry {
            res |= get_flag(cpu, .C)
        }
        
        cpu.f.z = res == 0
        cpu.f.n = 0
        cpu.f.h = 0
        cpu.f.c = overflow
    }
}
