package ppu

MEM_START :: 0x8000
MEM_END :: 0xA000

TILE_SET_START :: 0x8000
TILE_SET_STOP  :: 0x9800
TILE_MAP_START :: 0x9800
TILE_MAP_STOP  :: 0xA000


TILE_COUNT :: 384

PPU :: struct {
    tiles: [TILE_COUNT]Tile,
}

new :: proc() -> PPU {
    return {}
}

read_vram :: proc(ppu: PPU, addr: u16) -> u8 {
    switch {
    case addr >= TILE_SET_START && addr < TILE_SET_STOP:
        panic("not implemented")
    case addr >= TILE_MAP_START && addr < TILE_MAP_STOP:
        panic("not implemented")
    case:
        panic("unreachable")
    }
}

write_vram :: proc(ppu: ^PPU, addr: u16, val: u8) {
    switch {
    case addr >= TILE_SET_START && addr < TILE_SET_STOP:
        panic("not implemented")
    case addr >= TILE_MAP_START && addr < TILE_MAP_STOP:
        panic("not implemented")
    case:
        panic("unreachable")
    }
}
