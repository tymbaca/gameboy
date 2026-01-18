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
HEADER ::        "addr | x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 xA xB xC xD xE xF | ascii"

dump_string :: proc(data: []u8, start_addr: int, offset := 0, allocator := context.allocator) -> string {
    b := dump(data, start_addr, offset, allocator)
    return strings.to_string(b)
}


dump_cstring :: proc(data: []u8, start_addr: int, offset := 0, allocator := context.allocator) -> cstring {
    b := dump(data, start_addr, offset, allocator)
    return strings.to_cstring(&b)
}

dump :: proc(data: []u8, start_addr: int, offset := 0, allocator := context.allocator) -> strings.Builder {
    data := data
    offset := offset
    start_addr := start_addr

    builder: strings.Builder
    strings.builder_init(&builder, allocator = allocator)

    i := 0
    first_line := true
    for i < len(data) {
        i += append_line(&builder, data[i:], start_addr, offset, allocator)
        start_addr += 16
        if first_line {
            offset = 0
            first_line = false
        }
    }

    return builder
}

append_line :: proc(b: ^strings.Builder, data: []u8, addr: int, offset: int, allocator := context.allocator) -> (int) {
    chunk := data

    line_size := 16 - offset

    // get first 16 bytes from data
    if len(chunk) > line_size {
        chunk = chunk[:line_size]
    }

    fmt.sbprintf(b, "%3Xx | ", addr>>1)

    pad_left := offset
    pad_right := line_size - len(chunk)

    for _ in 0..<pad_left {
        strings.write_string(b, "   ")
    }

    for ch, i in chunk {
        fmt.sbprintf(b, "%2X", ch)
        strings.write_byte(b, ' ')
    }

    for _ in 0..<pad_right {
        strings.write_string(b, "   ")
    }

    strings.write_string(b, "| ")

    for _ in 0..<pad_left {
        strings.write_string(b, " ")
    }

    for ch in chunk {
        if strings.ascii_set_contains(printables_set, ch) {
            strings.write_byte(b, ch)
        } else {
            strings.write_byte(b, '.')
        }
    }

    for _ in 0..<pad_right {
        strings.write_string(b, " ")
    }

    strings.write_byte(b, '\n')

    return len(chunk)
}
