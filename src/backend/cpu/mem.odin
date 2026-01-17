package cpu


when !ODIN_TEST {
    read_mem :: proc(cpu: ^CPU, addr: u16) -> u8 {
        panic("not implemented")
    }

    write_mem :: proc(cpu: ^CPU, addr: u16, val: u8) {
        panic("not implemented")
    }
} else {
    test_ram: [65536]byte

    read_mem :: proc(cpu: ^CPU, addr: u16) -> u8 {
        return test_ram[addr]
    }

    write_mem :: proc(cpu: ^CPU, addr: u16, val: u8) {
        test_ram[addr] = val
    }
}
