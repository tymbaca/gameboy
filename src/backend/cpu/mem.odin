package cpu


when !ODIN_TEST {
    read_mem :: proc(cpu: ^CPU, addr: u16) -> u8 {
        panic("not implemented")
    }

    write_mem :: proc(cpu: ^CPU, addr: u16, val: u8) {
        panic("not implemented")
    }
} else {
    // Mock memory for testing
    TEST_MEMORY_SIZE :: 0x10000
    TestMemory :: [TEST_MEMORY_SIZE]u8
    test_memory: TestMemory

    // Override memory functions for testing
    read_mem :: proc(cpu: ^CPU, addr: u16) -> u8 {
        return test_memory[addr]
    }

    write_mem :: proc(cpu: ^CPU, addr: u16, val: u8) {
        test_memory[addr] = val
    }

    // Helper to reset test memory
    reset_test_memory :: proc() {
        for i in 0..<TEST_MEMORY_SIZE {
            test_memory[i] = 0
        }
    }
}
