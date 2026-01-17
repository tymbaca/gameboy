package cpu

import "src:helper/math"

// https://izik1.github.io/gbops/

OPCODES: [256]proc(^CPU) -> u8 = {
//  0x00,            0x01,            0x02,             0x03,            0x04,            0x05,            0x06,            0x07,            0x08,           0x09,             0x0A,             0x0B,         0x0C,      0x0D,      0x0E,            0x0F
    nop_00,          ld_fv_u16(.BC),  ld_ml(.BC,.A, 0), inc_u16(.BC),    inc(.B),         dec(.B),         ld_fv_u8(.B),    todo,            ld_fl_u16(.SP), add_u16(.HL,.BC), ld_mr(.A,.BC, 0), dec_u16(.BC), inc(.C),   dec(.C),   ld_fv_u8(.C),    todo,      // 0x00
    todo,            ld_fv_u16(.DE),  ld_ml(.DE,.A, 0), inc_u16(.DE),    inc(.D),         dec(.D),         ld_fv_u8(.D),    todo,            todo,           add_u16(.HL,.DE), ld_mr(.A,.DE, 0), dec_u16(.DE), inc(.E),   dec(.E),   ld_fv_u8(.E),    todo,      // 0x10
    todo,            ld_fv_u16(.HL),  ld_ml(.HL,.A, 1), inc_u16(.HL),    inc(.H),         dec(.H),         ld_fv_u8(.H),    todo,            todo,           add_u16(.HL,.HL), ld_mr(.A,.HL, 1), dec_u16(.HL), inc(.L),   dec(.L),   ld_fv_u8(.L),    todo,      // 0x20
    todo,            ld_fv_u16(.SP),  ld_ml(.HL,.A,-1), inc_u16(.SP),    inc_34,          dec_35,          ld_fmem(.HL),    todo,            todo,           add_u16(.HL,.SP), ld_mr(.A,.HL,-1), dec_u16(.SP), inc(.A),   dec(.A),   ld_fv_u8(.A),    todo,      // 0x30
    ld(.B,.B),       ld(.B,.C),       ld(.B,.D),        ld(.B,.E),       ld(.B,.H),       ld(.B,.L),       ld_mr(.B,.HL,0), ld(.B,.A),       ld(.C,.B),      ld(.C,.C),        ld(.C,.D),        ld(.C,.E),    ld(.C,.H), ld(.C,.L), ld_mr(.C,.HL,0), ld(.C,.A), // 0x40
    ld(.D,.B),       ld(.D,.C),       ld(.D,.D),        ld(.D,.E),       ld(.D,.H),       ld(.D,.L),       ld_mr(.D,.HL,0), ld(.D,.A),       ld(.E,.B),      ld(.E,.C),        ld(.E,.D),        ld(.E,.E),    ld(.E,.H), ld(.E,.L), ld_mr(.E,.HL,0), ld(.E,.A), // 0x50
    ld(.H,.B),       ld(.H,.C),       ld(.H,.D),        ld(.H,.E),       ld(.H,.H),       ld(.H,.L),       ld_mr(.H,.HL,0), ld(.H,.A),       ld(.L,.B),      ld(.L,.C),        ld(.L,.D),        ld(.L,.E),    ld(.L,.H), ld(.L,.L), ld_mr(.L,.HL,0), ld(.L,.A), // 0x60
    ld_ml(.HL,.B,0), ld_ml(.HL,.C,0), ld_ml(.HL,.D,0),  ld_ml(.HL,.E,0), ld_ml(.HL,.H,0), ld_ml(.HL,.L,0), todo,            ld_ml(.HL,.A,0), ld(.A,.B),      ld(.A,.C),        ld(.A,.D),        ld(.A,.E),    ld(.A,.H), ld(.A,.L), ld_mr(.A,.HL,0), ld(.A,.A), // 0x70
    add(.A,.B),      add(.A,.C),      add(.A,.D),       add(.A,.E),      add(.A,.H),      add(.A,.L),      add_86(.A,.HL),  add(.A,.A),      todo,           todo,             todo,             todo,         todo,      todo,      todo,            todo,      // 0x80
    sub(.A,.B),      sub(.A,.C),      sub(.A,.D),       sub(.A,.E),      sub(.A,.H),      sub(.A,.L),      sub_96(.A,.HL),  sub(.A,.A),      todo,           todo,             todo,             todo,         todo,      todo,      todo,            todo,      // 0x90
    todo,            todo,            todo,             todo,            todo,            todo,            todo,            todo,            todo,           todo,             todo,             todo,         todo,      todo,      todo,            todo,      // 0xA0
    todo,            todo,            todo,             todo,            todo,            todo,            todo,            todo,            todo,           todo,             todo,             todo,         todo,      todo,      todo,            todo,      // 0xB0
    todo,            todo,            todo,             todo,            todo,            todo,            todo,            todo,            todo,           todo,             todo,             todo,         todo,      todo,      todo,            todo,      // 0xC0
    todo,            todo,            todo,             todo,            todo,            todo,            todo,            todo,            todo,           todo,             todo,             todo,         todo,      todo,      todo,            todo,      // 0xD0
    ld_ffu8_l,       ld_ffc_l,        todo,             todo,            todo,            todo,            todo,            todo,            todo,           todo,             ld_fl(.A),        todo,         todo,      todo,      todo,            todo,      // 0xE0
    ld_ffu8_r,       ld_ffc_r,        todo,             todo,            todo,            todo,            todo,            todo,            ld_F8,          ld_u16(.SP,.HL),  ld_fr(.A),        todo,         todo,      todo,      todo,            todo,      // 0xF0
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
        left := get_reg(cpu, left_reg)
        right := get_reg(cpu, right_reg)

        set_flag_z0hc(cpu, left, right)
        set_reg(cpu, left_reg, left + right)

        return 1
    }
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

add_86 :: proc($left_reg: Reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        left := get_reg(cpu, left_reg)
        right := read_mem(cpu, get_reg_u16(cpu, right_reg))

        set_flag_z0hc(cpu, left, right)
        set_reg(cpu, left_reg, left + right)

        return 2
    }
}

sub :: proc($left_reg, $right_reg: Reg) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        left := get_reg(cpu, left_reg)
        right := get_reg(cpu, right_reg)

        set_flag_z1hc(cpu, left, right)
        set_reg(cpu, left_reg, left - right)

        return 1
    }
}

sub_96 :: proc($left_reg: Reg, $right_reg: Reg_u16) -> proc(cpu: ^CPU) -> u8 {
    return proc(cpu: ^CPU) -> u8 {
        left := get_reg(cpu, left_reg)
        right := read_mem(cpu, get_reg_u16(cpu, right_reg))

        set_flag_z1hc(cpu, left, right)
        set_reg(cpu, left_reg, left - right)

        return 2
    }
}

set_flag_z0hc :: proc(cpu: ^CPU, left, right: u8) {
    cpu.f.z = (left + right) == 0
    cpu.f.n = false
    cpu.f.h = math.will_half_carry(left, right)
    cpu.f.c = math.will_carry(left, right)
}

set_flag_z1hc :: proc(cpu: ^CPU, left, right: u8) {
    cpu.f.z = (left - right) == 0
    cpu.f.n = true
    cpu.f.h = math.will_half_borrow(left, right)
    cpu.f.c = math.will_borrow(left, right)
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

ld_F8 :: proc(cpu: ^CPU) -> u8 {
    val := transmute(i8)(fetch(cpu))
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

add_u16_i8 :: proc(a: u16, b: i8) -> (res: u16, flags: Flag_Reg) {
    res = a
    flags.z = false
    flags.n = false

    if b >= 0 {
        abs_b := u16(b)
        flags.h = math.will_half_carry_u16(a, abs_b)
        flags.c = math.will_carry_u16(a, abs_b)
        res += abs_b
    } else {
        abs_b := u16(abs(b))
        flags.h = math.will_half_borrow_u16(a, abs_b)
        flags.c = math.will_borrow_u16(a, abs_b)
        res -= abs_b
    }

    return res, flags
}
