package dump

import "core:unicode/utf8"
import "core:strings"
import "core:mem"
import "core:fmt"

printables_set: strings.Ascii_Set

@(init)
init :: proc() {
    ok: bool
    printables_set, ok = strings.ascii_set_make("!\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
    assert(ok)
}

LINE_SIZE :: len("0000 | 01 23 45 67 89 AB CD EF 01 23 45 67 89 AB CD EF | 0123456789abcdef")

dump_string :: proc(data: []u8, start_addr: int, allocator := context.allocator) -> string {
    b := dump(data, start_addr, allocator)
    return strings.to_string(b)
}

dump_cstring :: proc(data: []u8, start_addr: int, allocator := context.allocator) -> cstring {
    b := dump(data, start_addr, allocator)
    return strings.to_cstring(&b)
}

dump :: proc(data: []u8, start_addr: int, allocator := context.allocator) -> strings.Builder {
    data := data

    builder: strings.Builder
    strings.builder_init(&builder, allocator = allocator)

    i := 0
    for i < len(data) {
        i += append_line(&builder, data[i:], start_addr+i, allocator)
    }

    return builder
}

append_line :: proc(b: ^strings.Builder, data: []u8, addr: int, allocator := context.allocator) -> (int) {
    chunk := data

    // get first 16 bytes from data
    if len(chunk) > 16 {
        chunk = chunk[:16]
    }

    fmt.sbprintf(b, "%4X | ", addr)

    for ch, i in chunk {
        fmt.sbprintf(b, "%2X", ch)
        strings.write_byte(b, ' ')
    }

    if len(chunk) < 16 {
        for _ in 0..<(16 - len(chunk)) {
            strings.write_string(b, "   ")
        }
    }

    strings.write_string(b, "| ")

    for ch in chunk {
        if strings.ascii_set_contains(printables_set, ch) {
            strings.write_byte(b, ch)
        } else {
            strings.write_byte(b, '.')
        }
    }

    if len(chunk) < 16 {
        for _ in 0..<(16 - len(chunk)) {
            strings.write_string(b, " ")
        }
    }

    strings.write_byte(b, '\n')

    return len(chunk)
}
