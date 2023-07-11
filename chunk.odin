package olox

import "core:fmt"

OpCode :: enum u8 {
    OP_CONSTANT,
    OP_RETURN,
}

Value :: distinct f64

Chunk :: struct {
    code:      [dynamic]u8,
    // All constant values stored in the list, to simplify things
    constants: [dynamic]Value,
    lines:     [dynamic]int,
}

chunk_write :: proc(chunk: ^Chunk, byte: u8, line: int) {
    append(&chunk.code, byte)
    append(&chunk.lines, line)
}

chunk_add_constant :: proc(chunk: ^Chunk, value: Value) -> int {
    append(&chunk.constants, value)
    return len(chunk.constants) - 1
}
