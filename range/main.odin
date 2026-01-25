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

    b := false
    sl := u8(b)

    fmt.printf("%8b\n", sl)
}
