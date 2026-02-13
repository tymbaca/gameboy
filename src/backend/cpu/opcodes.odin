package cpu

import "core:fmt"
import "core:math/bits"
import "src:helper/math"

// https://izik1.github.io/gbops/

OPCODES: [256]proc(^CPU) -> u8 = {
//  0x00,              0x01,            0x02,             0x03,            0x04,               0x05,            0x06,            0x07,            0x08,             0x09,             0x0A,             0x0B,         0x0C,               0x0D,       0x0E,            0x0F
    nop_00,            ld_fv_u16(.BC),  ld_ml(.BC,.A, 0), inc_u16(.BC),    inc(.B),            dec(.B),         ld_fv_u8(.B),    rlca_07,         ld_fl_u16(.SP),   add_u16(.HL,.BC), ld_mr(.A,.BC, 0), dec_u16(.BC), inc(.C),            dec(.C),    ld_fv_u8(.C),    rrca_0F,    // 0x00
    todo,              ld_fv_u16(.DE),  ld_ml(.DE,.A, 0), inc_u16(.DE),    inc(.D),            dec(.D),         ld_fv_u8(.D),    rla_17,          jr_18,            add_u16(.HL,.DE), ld_mr(.A,.DE, 0), dec_u16(.DE), inc(.E),            dec(.E),    ld_fv_u8(.E),    rra_1F,     // 0x10
    jr_if(.Z, false),  ld_fv_u16(.HL),  ld_ml(.HL,.A, 1), inc_u16(.HL),    inc(.H),            dec(.H),         ld_fv_u8(.H),    todo,            jr_if(.Z, true),  add_u16(.HL,.HL), ld_mr(.A,.HL, 1), dec_u16(.HL), inc(.L),            dec(.L),    ld_fv_u8(.L),    cpl_2F,     // 0x20
    jr_if(.C, false),  ld_fv_u16(.SP),  ld_ml(.HL,.A,-1), inc_u16(.SP),    inc_34,             dec_35,          ld_fmem(.HL),    scf_37,          jr_if(.C, true),  add_u16(.HL,.SP), ld_mr(.A,.HL,-1), dec_u16(.SP), inc(.A),            dec(.A),    ld_fv_u8(.A),    ccf_3F,     // 0x30
    ld(.B,.B),         ld(.B,.C),       ld(.B,.D),        ld(.B,.E),       ld(.B,.H),          ld(.B,.L),       ld_mr(.B,.HL,0), ld(.B,.A),       ld(.C,.B),        ld(.C,.C),        ld(.C,.D),        ld(.C,.E),    ld(.C,.H),          ld(.C,.L),  ld_mr(.C,.HL,0), ld(.C,.A),  // 0x40
    ld(.D,.B),         ld(.D,.C),       ld(.D,.D),        ld(.D,.E),       ld(.D,.H),          ld(.D,.L),       ld_mr(.D,.HL,0), ld(.D,.A),       ld(.E,.B),        ld(.E,.C),        ld(.E,.D),        ld(.E,.E),    ld(.E,.H),          ld(.E,.L),  ld_mr(.E,.HL,0), ld(.E,.A),  // 0x50
    ld(.H,.B),         ld(.H,.C),       ld(.H,.D),        ld(.H,.E),       ld(.H,.H),          ld(.H,.L),       ld_mr(.H,.HL,0), ld(.H,.A),       ld(.L,.B),        ld(.L,.C),        ld(.L,.D),        ld(.L,.E),    ld(.L,.H),          ld(.L,.L),  ld_mr(.L,.HL,0), ld(.L,.A),  // 0x60
    ld_ml(.HL,.B,0),   ld_ml(.HL,.C,0), ld_ml(.HL,.D,0),  ld_ml(.HL,.E,0), ld_ml(.HL,.H,0),    ld_ml(.HL,.L,0), todo,            ld_ml(.HL,.A,0), ld(.A,.B),        ld(.A,.C),        ld(.A,.D),        ld(.A,.E),    ld(.A,.H),          ld(.A,.L),  ld_mr(.A,.HL,0), ld(.A,.A),  // 0x70
    add(.A,.B),        add(.A,.C),      add(.A,.D),       add(.A,.E),      add(.A,.H),         add(.A,.L),      add_86(.A,.HL),  add(.A,.A),      adc(.A,.B),       adc(.A,.C),       adc(.A,.D),       adc(.A,.E),   adc(.A,.H),         adc(.A,.L), adc_8E(.A,.HL),  adc(.A,.A), // 0x80
    sub(.A,.B),        sub(.A,.C),      sub(.A,.D),       sub(.A,.E),      sub(.A,.H),         sub(.A,.L),      sub_96(.A,.HL),  sub(.A,.A),      sbc(.A,.B),       sbc(.A,.C),       sbc(.A,.D),       sbc(.A,.E),   sbc(.A,.H),         sbc(.A,.L), sbc_9E(.A,.HL),  sbc(.A,.A), // 0x90
    and(.A,.B),        and(.A,.C),      and(.A,.D),       and(.A,.E),      and(.A,.H),         and(.A,.L),      and_A6(.A,.HL),  and(.A,.A),      xor(.A,.B),       xor(.A,.C),       xor(.A,.D),       xor(.A,.E),   xor(.A,.H),         xor(.A,.L), xor_AE(.A,.HL),  xor(.A,.A), // 0xA0
    or(.A,.B),         or(.A,.C),       or(.A,.D),        or(.A,.E),       or(.A,.H),          or(.A,.L),       or_B6(.A,.HL),   or(.A,.A),       cp(.A,.B),        cp(.A,.C),        cp(.A,.D),        cp(.A,.E),    cp(.A,.H),          cp(.A,.L),  cp_BE(.A,.HL),   cp(.A,.A),  // 0xB0
    ret_if(.Z, false), pop_reg(.BC),    jp_if(.Z, false), jp_C3,           call_if(.Z, false), push_reg(.BC),   add_C6(.A),      rst(0),          ret_if(.Z, true), ret_c9,           jp_if(.Z, true),  prefix_cb,    call_if(.Z, false), call_cd,    adc_CE(.A),      rst(1),     // 0xC0
    ret_if(.C, false), pop_reg(.DE),    jp_if(.C, false), todo,            call_if(.C, false), push_reg(.DE),   sub_D6(.A),      rst(2),          ret_if(.C, true), todo,             jp_if(.C, true),  todo,         call_if(.C, false), todo,       sbc_DE(.A),      rst(3),     // 0xD0
    ld_ffu8_l,         pop_reg(.HL),    ld_ffc_l,         todo,            todo,               push_reg(.HL),   and_E6(.A),      rst(4),          add_E8,           jp_E9,            ld_fl(.A),        todo,         todo,               todo,       and_E6(.A),      rst(5),     // 0xE0
    ld_ffu8_r,         pop_reg(.AF),    ld_ffc_r,         todo,            todo,               push_reg(.AF),   or_F6(.A),       rst(6),          ld_F8,            ld_u16(.SP,.HL),  ld_fr(.A),        todo,         todo,               todo,       or_F6(.A),       rst(7),     // 0xF0
}

OPCODES_CB: [256]proc(^CPU) -> u8 = {
//  0x00,              0x01,              0x02,              0x03,              0x04,              0x05,              0x06,             0x07,              0x08,              0x09,              0x0A,              0x0B,              0x0C,              0x0D,              0x0E,             0x0F
    rl(.B,  true),     rl(.C,  true),     rl(.D,  true),     rl(.E,  true),     rl(.H,  true),     rl(.L,  true),     rl_hl( true),     rl(.A,  true),     rr(.B,  true),     rr(.C,  true),     rr(.D,  true),     rr(.E,  true),     rr(.H,  true),     rr(.L,  true),     rr_hl( true),     rr(.A,  true),     // 0x00
    rl(.B, false),     rl(.C, false),     rl(.D, false),     rl(.E, false),     rl(.H, false),     rl(.L, false),     rl_hl(false),     rl(.A, false),     rr(.B, false),     rr(.C, false),     rr(.D, false),     rr(.E, false),     rr(.H, false),     rr(.L, false),     rr_hl(false),     rr(.A, false),     // 0x10
    sl(.B),            sl(.C),            sl(.D),            sl(.E),            sl(.H),            sl(.L),            sl_hl,            sl(.A),            sr(.B, false),     sr(.C, false),     sr(.D, false),     sr(.E, false),     sr(.H, false),     sr(.L, false),     sr_hl(false),     sr(.A, false),     // 0x20
    swap(.B),          swap(.C),          swap(.D),          swap(.E),          swap(.H),          swap(.L),          swap_hl,          swap(.A),          sr(.B,  true),     sr(.C,  true),     sr(.D,  true),     sr(.E,  true),     sr(.H,  true),     sr(.L,  true),     sr_hl( true),     sr(.A,  true),     // 0x30
    bit(.B, 0),        bit(.C, 0),        bit(.D, 0),        bit(.E, 0),        bit(.H, 0),        bit(.L, 0),        bit_hl(0),        bit(.A, 0),        bit(.B, 1),        bit(.C, 1),        bit(.D, 1),        bit(.E, 1),        bit(.H, 1),        bit(.L, 1),        bit_hl(1),        bit(.A, 1),        // 0x40
    bit(.B, 2),        bit(.C, 2),        bit(.D, 2),        bit(.E, 2),        bit(.H, 2),        bit(.L, 2),        bit_hl(2),        bit(.A, 2),        bit(.B, 3),        bit(.C, 3),        bit(.D, 3),        bit(.E, 3),        bit(.H, 3),        bit(.L, 3),        bit_hl(3),        bit(.A, 3),        // 0x50
    bit(.B, 4),        bit(.C, 4),        bit(.D, 4),        bit(.E, 4),        bit(.H, 4),        bit(.L, 4),        bit_hl(4),        bit(.A, 4),        bit(.B, 5),        bit(.C, 5),        bit(.D, 5),        bit(.E, 5),        bit(.H, 5),        bit(.L, 5),        bit_hl(5),        bit(.A, 5),        // 0x60
    bit(.B, 6),        bit(.C, 6),        bit(.D, 6),        bit(.E, 6),        bit(.H, 6),        bit(.L, 6),        bit_hl(6),        bit(.A, 6),        bit(.B, 7),        bit(.C, 7),        bit(.D, 7),        bit(.E, 7),        bit(.H, 7),        bit(.L, 7),        bit_hl(7),        bit(.A, 7),        // 0x70
    set_bit(.B, 0, 0), set_bit(.C, 0, 0), set_bit(.D, 0, 0), set_bit(.E, 0, 0), set_bit(.H, 0, 0), set_bit(.L, 0, 0), set_bit_hl(0, 0), set_bit(.A, 0, 0), set_bit(.B, 1, 0), set_bit(.C, 1, 0), set_bit(.D, 1, 0), set_bit(.E, 1, 0), set_bit(.H, 1, 0), set_bit(.L, 1, 0), set_bit_hl(1, 0), set_bit(.A, 1, 0), // 0x80
    set_bit(.B, 2, 0), set_bit(.C, 2, 0), set_bit(.D, 2, 0), set_bit(.E, 2, 0), set_bit(.H, 2, 0), set_bit(.L, 2, 0), set_bit_hl(2, 0), set_bit(.A, 2, 0), set_bit(.B, 3, 0), set_bit(.C, 3, 0), set_bit(.D, 3, 0), set_bit(.E, 3, 0), set_bit(.H, 3, 0), set_bit(.L, 3, 0), set_bit_hl(3, 0), set_bit(.A, 3, 0), // 0x90
    set_bit(.B, 4, 0), set_bit(.C, 4, 0), set_bit(.D, 4, 0), set_bit(.E, 4, 0), set_bit(.H, 4, 0), set_bit(.L, 4, 0), set_bit_hl(4, 0), set_bit(.A, 4, 0), set_bit(.B, 5, 0), set_bit(.C, 5, 0), set_bit(.D, 5, 0), set_bit(.E, 5, 0), set_bit(.H, 5, 0), set_bit(.L, 5, 0), set_bit_hl(5, 0), set_bit(.A, 5, 0), // 0xA0
    set_bit(.B, 6, 0), set_bit(.C, 6, 0), set_bit(.D, 6, 0), set_bit(.E, 6, 0), set_bit(.H, 6, 0), set_bit(.L, 6, 0), set_bit_hl(6, 0), set_bit(.A, 6, 0), set_bit(.B, 7, 0), set_bit(.C, 7, 0), set_bit(.D, 7, 0), set_bit(.E, 7, 0), set_bit(.H, 7, 0), set_bit(.L, 7, 0), set_bit_hl(7, 0), set_bit(.A, 7, 0), // 0xB0
    set_bit(.B, 0, 1), set_bit(.C, 0, 1), set_bit(.D, 0, 1), set_bit(.E, 0, 1), set_bit(.H, 0, 1), set_bit(.L, 0, 1), set_bit_hl(0, 1), set_bit(.A, 0, 1), set_bit(.B, 1, 1), set_bit(.C, 1, 1), set_bit(.D, 1, 1), set_bit(.E, 1, 1), set_bit(.H, 1, 1), set_bit(.L, 1, 1), set_bit_hl(1, 1), set_bit(.A, 1, 1), // 0xC0
    set_bit(.B, 2, 1), set_bit(.C, 2, 1), set_bit(.D, 2, 1), set_bit(.E, 2, 1), set_bit(.H, 2, 1), set_bit(.L, 2, 1), set_bit_hl(2, 1), set_bit(.A, 2, 1), set_bit(.B, 3, 1), set_bit(.C, 3, 1), set_bit(.D, 3, 1), set_bit(.E, 3, 1), set_bit(.H, 3, 1), set_bit(.L, 3, 1), set_bit_hl(3, 1), set_bit(.A, 3, 1), // 0xD0
    set_bit(.B, 4, 1), set_bit(.C, 4, 1), set_bit(.D, 4, 1), set_bit(.E, 4, 1), set_bit(.H, 4, 1), set_bit(.L, 4, 1), set_bit_hl(4, 1), set_bit(.A, 4, 1), set_bit(.B, 5, 1), set_bit(.C, 5, 1), set_bit(.D, 5, 1), set_bit(.E, 5, 1), set_bit(.H, 5, 1), set_bit(.L, 5, 1), set_bit_hl(5, 1), set_bit(.A, 5, 1), // 0xE0
    set_bit(.B, 6, 1), set_bit(.C, 6, 1), set_bit(.D, 6, 1), set_bit(.E, 6, 1), set_bit(.H, 6, 1), set_bit(.L, 6, 1), set_bit_hl(6, 1), set_bit(.A, 6, 1), set_bit(.B, 7, 1), set_bit(.C, 7, 1), set_bit(.D, 7, 1), set_bit(.E, 7, 1), set_bit(.H, 7, 1), set_bit(.L, 7, 1), set_bit_hl(7, 1), set_bit(.A, 7, 1), // 0xF0
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
    cpu.pc = pop(cpu)
    return 4
}

ret_if :: proc($flag: Flag_Kind, $is: bool) -> proc(^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        if get_flag(cpu, flag) == is {
            cpu.pc = pop(cpu)
            return 5
        } else {
            return 2
        }
    }
}

rst :: proc($step: int) -> proc(^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        addr := 0x0000
        addr += 0x8 * step
        cpu.pc = u16(addr)
        return 4
    }
}

reti_d9 :: proc(cpu: ^CPU) -> u8 {
    cpu.pc = pop(cpu)
    cpu.irq_enabled = true
    return 4
}

di_f3 :: proc(cpu: ^CPU) -> u8 {
    cpu.irq_enabled = false
    return 4
}

ei_fb :: proc(cpu: ^CPU) -> u8 {
    cpu.irq_enabled = true
    return 4
}

stop_10 :: proc(cpu: ^CPU) -> u8 {
    // not implemented
    return 1
}

halt_76 :: proc(cpu: ^CPU) -> u8 {
    cpu.halted = true
    return 1
}

prefix_cb :: proc(cpu: ^CPU) -> u8 {
    op := fetch(cpu)
    return OPCODES_CB[op](cpu)
}

rlca_07 :: proc(cpu: ^CPU) -> u8 {
    _ = rl(.A, true)(cpu)
    cpu.f.z = false
    return 1
}

rla_17 :: proc(cpu: ^CPU) -> u8 {
    _ = rl(.A, false)(cpu)
    cpu.f.z = false
    return 1
}

rrca_0F :: proc(cpu: ^CPU) -> u8 {
    _ = rr(.A, true)(cpu)
    cpu.f.z = false
    return 1
}

rra_1F :: proc(cpu: ^CPU) -> u8 {
    _ = rr(.A, false)(cpu)
    cpu.f.z = false
    return 1
}

rl :: proc($reg: Reg, $carry: bool) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg(cpu, reg)
        val = rl_helper(cpu, val, carry)
        set_reg(cpu, reg, val)
        return 2
    }
}

rl_hl :: proc($carry: bool) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := read_mem(cpu, get_reg_u16(cpu, .HL))
        val = rl_helper(cpu, val, carry)
        write_mem(cpu, get_reg_u16(cpu, .HL), val)
        return 4
    }
}

rl_helper :: proc(cpu: ^CPU, val: u8, carry: bool) -> u8 {
    res, overflow := math.rotate_left(val)

    if carry {
        res = math.set_bit(res, 0, cpu.f.c)
    }
    
    cpu.f.z = res == 0
    cpu.f.n = false
    cpu.f.h = false
    cpu.f.c = overflow

    return res
}

rr :: proc($reg: Reg, $carry: bool) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg(cpu, reg)
        val = rr_helper(cpu, val, carry)
        set_reg(cpu, reg, val)
        return 2
    }
}

rr_hl :: proc($carry: bool) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := read_mem(cpu, get_reg_u16(cpu, .HL))
        val = rr_helper(cpu, val, carry)
        write_mem(cpu, get_reg_u16(cpu, .HL), val)
        return 4
    }
}

rr_helper :: proc(cpu: ^CPU, val: u8, carry: bool) -> u8 {
    res, overflow := math.rotate_right(val)

    if carry {
        res = math.set_bit(res, 7, cpu.f.c)
    }
    
    cpu.f.z = res == 0
    cpu.f.n = false
    cpu.f.h = false
    cpu.f.c = overflow

    return res
}

sl :: proc($reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := sl_helper(cpu, get_reg(cpu, reg))
        set_reg(cpu, reg, val)
        return 2
    }
}

sl_hl :: proc(cpu: ^CPU) -> u8 {
    val := read_mem(cpu, get_reg_u16(cpu, .HL))
    val = sl_helper(cpu, val)
    write_mem(cpu, get_reg_u16(cpu, .HL), val)
    return 4
}

sl_helper :: proc(cpu: ^CPU, val: u8) -> u8 {
    carry := math.get_bit(val, 7)
    val := val << 1

    cpu.f.z = val == 0
    cpu.f.n = false
    cpu.f.h = false
    cpu.f.c = carry

    return val
}

sr :: proc($reg: Reg, $arith: bool) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := sr_helper(cpu, get_reg(cpu, reg), arith)
        set_reg(cpu, reg, val)
        return 2
    }
}

sr_hl :: proc($arith: bool) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := read_mem(cpu, get_reg_u16(cpu, .HL))
        val = sr_helper(cpu, val, arith)
        write_mem(cpu, get_reg_u16(cpu, .HL), val)
        return 4
    }
}

sr_helper :: proc(cpu: ^CPU, val: u8, arith: bool) -> u8 {
    sign_bit := math.get_bit(val, 7)
    carry := math.get_bit(val, 0)
    val := val >> 1
    
    if arith {
        val = math.set_bit(val, 7, sign_bit)
    }

    cpu.f.z = val == 0
    cpu.f.n = false
    cpu.f.h = false
    cpu.f.c = carry

    return val
}

swap :: proc($reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := swap_helper(cpu, get_reg(cpu, reg))
        set_reg(cpu, reg, val)
        return 2
    }
}

swap_hl :: proc(cpu: ^CPU) -> u8 {
    val := read_mem(cpu, get_reg_u16(cpu, .HL))
    val = swap_helper(cpu, val)
    write_mem(cpu, get_reg_u16(cpu, .HL), val)
    return 4
}

swap_helper :: proc(cpu: ^CPU, val: u8) -> u8 {
    high := val & 0xF0
    low := val & 0x0F

    res := low << 4
    res |= high >> 4

    cpu.f.z = res == 0
    cpu.f.n = false
    cpu.f.h = false
    cpu.f.c = false
    return res
}

bit :: proc($reg: Reg, $bit: uint) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg(cpu, reg)
        bit_helper(cpu, val, bit)

        return 2
    }
}

bit_hl :: proc($bit: uint) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := read_mem(cpu, get_reg_u16(cpu, .HL))
        bit_helper(cpu, val, bit)

        return 3
    }
}

bit_helper :: proc(cpu: ^CPU, val: u8, bit: uint) {
    bit_val := u8(math.get_bit(val, bit))
    cpu.f.z = bit_val == 0
    cpu.f.n = false
    cpu.f.h = true

    return
}

set_bit :: proc($reg: Reg, $bit: uint, $set: uint) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := get_reg(cpu, reg)
        val = math.set_bit(val, bit, set != 0)
        set_reg(cpu, reg, val)

        return 2
    }
}

set_bit_hl :: proc($bit: uint, $set: uint) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        val := read_mem(cpu, get_reg_u16(cpu, .HL))
        val = math.set_bit(val, bit, set != 0)
        write_mem(cpu, get_reg_u16(cpu, .HL), val)

        return 4
    }
}

scf_37 :: proc(cpu: ^CPU) -> u8 {
    cpu.f.n = false
    cpu.f.h = false
    cpu.f.c = true
    return 1
}

ccf_3F :: proc(cpu: ^CPU) -> u8 {
    cpu.f.n = false
    cpu.f.h = false
    cpu.f.c = !cpu.f.c
    return 1
}

cpl_2F :: proc(cpu: ^CPU) -> u8 {
    val := get_reg(cpu, .A)
    set_reg(cpu, .A, ~val)
    cpu.f.n = true
    cpu.f.h = true
    return 1
}
