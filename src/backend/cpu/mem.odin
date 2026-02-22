package cpu

import "src:backend/bus"

when !ODIN_TEST {
    read_mem :: proc(cpu: ^CPU, addr: u16) -> u8 {
        return bus.read(cpu.bus, addr)
    }

    write_mem :: proc(cpu: ^CPU, addr: u16, val: u8) {
        bus.write(&cpu.bus, addr, val)
    }
} else {
    // Mock memory for testing
    test_memory: [bus.RAM_SIZE]u8

    // Override memory functions for testing
    read_mem :: proc(cpu: ^CPU, addr: u16) -> u8 {
        return test_memory[addr]
    }

    write_mem :: proc(cpu: ^CPU, addr: u16, val: u8) {
        test_memory[addr] = val
    }

    // Helper to reset test memory
    reset_test_memory :: proc() {
        for i in 0..<bus.RAM_SIZE {
            test_memory[i] = 0
        }
    }
}

