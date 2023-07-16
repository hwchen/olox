package olox

import "core:fmt"
import "core:reflect"

OpCode :: enum u8 {
    OP_CONSTANT,
    OP_NEGATE,
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

chunk_disassemble :: proc(chunk: Chunk, label: string) {
    fmt.printf("== %s ==\n", label)
    for offset := 0; offset < len(chunk.code); {
        offset = instruction_disassemble(chunk, offset)
    }
}

instruction_disassemble :: proc(chunk: Chunk, offset: int) -> int {
    fmt.printf("%04d ", offset)

    // don't show line if previous instruction has the same line num
    if offset > 0 && chunk.lines[offset] == chunk.lines[offset - 1] {
        fmt.printf("   | ")
    } else {
        fmt.printf("%4d ", chunk.lines[offset])
    }

    opcode := cast(OpCode)chunk.code[offset]
    switch opcode {
    case .OP_CONSTANT:
        const_idx := chunk.code[offset + 1]
        const_val := chunk.constants[const_idx]
        fmt.printf("%-16s %4d '%v'\n", opcode, const_idx, const_val)
        return offset + 2
    case .OP_NEGATE, .OP_RETURN:
        fmt.printf("%s\n", opcode)
        return offset + 1
    case:
        fmt.printf("Unknown opcode %d\n", opcode)
        return offset + 1
    }
}
