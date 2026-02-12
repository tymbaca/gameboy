package range

import "core:fmt"

main :: proc() {
    // f: cpu.Flag_Reg
    // f.z = true
    // f.n = true
    // f.h = true
    // f.c = true
    //
    // val: cpu.Reg_u16
    // fmt.printf("size: %d, bin: %b\n", size_of(f), u8(f))
    // fmt.printf("regs: %d %d %d\n", cpu.Reg_u16.PC, cpu.Reg_u16.SP, val)

    // for r in cpu.Reg_u16 {
    //     fmt.println(r)
    // }

    v: u8 = 0b00110011
    fmt.printf("%8b\n", ~v)
}
