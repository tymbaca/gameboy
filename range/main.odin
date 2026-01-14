package range

import "core:fmt"
import "../src/backend/cpu"

main :: proc() {
    f: cpu.Flag_Reg
    f.z = true
    f.n = true
    f.h = true
    f.c = true

    fmt.printf("size: %d, bin: %b", size_of(f), transmute(byte)f)
}
