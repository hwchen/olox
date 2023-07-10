package olox

import "core:fmt"

chunk_disassemble :: proc(chunk: Chunk, label: string) {
    fmt.printf("== %s ==\n", label)
    for offset := 0; offset < len(chunk); {
        offset = instruction_disassemble(chunk, offset)
    }
}

instruction_disassemble :: proc(chunk: Chunk, offset: int) -> int {
    fmt.printf("%04d ", offset)

    opcode := cast(OpCode)chunk[offset]
    switch opcode {
    case .OP_RETURN:
        return instruction_simple("OP_RETURN", offset)
    case:
        fmt.printf("Unknown opcode %d\n", opcode)
        return offset + 1
    }
}

instruction_simple :: proc(name: string, offset: int) -> int {
    fmt.printf("%s\n ", name)
    return offset + 1
}
