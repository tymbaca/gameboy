package range

import "core:fmt"
import "../src/backend/cpu"

main :: proc() {
    f: cpu.Flag_Reg
    f.z = true
    f.n = true
    f.h = true
    f.c = true

    val: cpu.Reg_u16
    fmt.printf("size: %d, bin: %b\n", size_of(f), u8(f))
    fmt.printf("regs: %d %d %d\n", cpu.Reg_u16.PC, cpu.Reg_u16.SP, val)
}
