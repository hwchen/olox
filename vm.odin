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
    stack: [dynamic]Value

    for {
        if DEBUG_TRACE_EXECUTION {
            fmt.printf("     ")
            for v in stack {
                fmt.printf("[ %v ]", v)
            }
            fmt.println()

            instruction_disassemble(chunk, ip)
        }

        opcode := cast(OpCode)chunk.code[ip]
        ip += 1
        switch opcode {
        case .OP_CONSTANT:
            const_idx := chunk.code[ip]
            constant := chunk.constants[const_idx]
            ip += 1
            append(&stack, constant)
        case .OP_NEGATE:
            constant := pop(&stack)
            append(&stack, -1 * constant)
        case .OP_ADD, .OP_SUBTRACT, .OP_MULTIPLY, .OP_DIVIDE:
            b := pop(&stack)
            a := pop(&stack)
            #partial switch opcode {
            case .OP_ADD:
                append(&stack, a + b)
            case .OP_SUBTRACT:
                append(&stack, a - b)
            case .OP_MULTIPLY:
                append(&stack, a * b)
            case .OP_DIVIDE:
                append(&stack, a / b)
            }
        case .OP_RETURN:
            constant := pop(&stack)
            fmt.printf("%v\n", constant)
            return .INTERPRET_OK
        }
    }
}
