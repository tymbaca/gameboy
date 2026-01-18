package dump

import "core:unicode/utf8"
import "core:strings"
import "core:mem"
import "core:fmt"

printables_set: strings.Ascii_Set

@(init)
init :: proc() {
    ascii_set, ok := strings.ascii_set_make("!\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
    assert(ok)
}

LINE_SIZE :: len("0000 | 01 23 45 67 89 AB CD EF 01 23 45 67 89 AB CD EF | 0123456789abcdef")

dump_string :: proc(data: []u8, from := 0, to := 0, allocator := context.allocator) -> string {
    b := dump(data, from, to, allocator)
    return strings.to_string(b)
}

dump_cstring :: proc(data: []u8, from := 0, to := 0, allocator := context.allocator) -> cstring {
    b := dump(data, from, to, allocator)
    return strings.to_cstring(&b)
}

dump :: proc(data: []u8, from := 0, to := 0, allocator := context.allocator) -> strings.Builder {
    data := data
    from := from
    to := to
    if to < 0 || to > len(data) do to = len(data)
    if from <= 0 do from = 0

    data = data[from:to]

    lines := ((to - from) / 16) + 1
    total_alloc_size := lines * LINE_SIZE

    builder: strings.Builder
    strings.builder_init(&builder, 0, total_alloc_size, allocator = allocator)

    for from < to {
        from += append_line(&builder, data, from, allocator)
    }

    return builder
}

append_line :: proc(b: ^strings.Builder, data: []u8, addr: int, allocator := context.allocator) -> (int) {
    chunk := data

    // get first 16 bytes from data
    if len(chunk) > 16 {
        chunk = chunk[:16]
    }

    fmt.sbprintf(b, "%4x | ", addr)

    for ch, i in chunk {
        fmt.sbprintf(b, "%2x", ch)
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
