package ppu

MEM_START :: 0x8000
MEM_END :: 0xA000

PPU :: struct {
    vram: [8192]u8,
}

new :: proc() -> PPU {
    return {}
}

read_vram :: proc(ppu: PPU, addr: u16) -> u8 {
    panic("not implemented")
}

write_vram :: proc(ppu: ^PPU, addr: u16, val: u8) {
    panic("not implemented")
}
