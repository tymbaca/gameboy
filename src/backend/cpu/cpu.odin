package cpu

CPU :: struct {
    pc, sp: u16,
    a: u8, 
    f: Flag_Reg, 
    b, c: u8, 
    d, e: u8,
    h, l: u8,
}

Flag_Reg :: bit_field u8 {
    _: bool | 4, // 0-3 reserved, not used
    c: bool | 1, // 4
    h: bool | 1, // 5
    n: bool | 1, // 6
    z: bool | 1, // 7
}
