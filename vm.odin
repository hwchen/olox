package olox

import "core:fmt"
import "core:mem"

InterpretResult :: enum {
    INTERPRET_OK,
    INTERPRET_COMPILER_ERROR,
    INTERPRET_RUNTIME_ERROR,
}

interpret :: proc(chunk: Chunk) -> InterpretResult {
    // not a pointer; book says pointers are faster, but it's not clear that's the case now.
    // https://stackoverflow.com/questions/2305770/efficiency-arrays-vs-pointers
    ip := 0

    for {
        opcode := cast(OpCode)chunk.code[ip]
        ip += 1
        switch opcode {
        case .OP_RETURN:
            return .INTERPRET_OK
        case .OP_CONSTANT:
            const_idx := chunk.code[ip]
            constant := chunk.constants[const_idx]
            ip += 1
            fmt.printf("%v", constant)
        }
    }
}
