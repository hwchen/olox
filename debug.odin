package olox

import "core:fmt"

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
        fmt.printf("%-16s %4d '%v'\n", "OP_CONSTANT", const_idx, const_val)
        return offset + 2
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
