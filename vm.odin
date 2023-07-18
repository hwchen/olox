package olox

import "core:fmt"
import "core:mem"
import "core:reflect"

Vm :: struct {
    // not a pointer; book says pointers are faster, but it's not clear that's the case now.
    // https://stackoverflow.com/questions/2305770/efficiency-arrays-vs-pointers
    ip:    int,
    stack: [dynamic]Value,
}

InterpretResult :: enum {
    Ok,
    CompilerError,
    RuntimeError,
}

vm_interpret :: proc(vm: ^Vm, chunk: Chunk) -> InterpretResult {
    if len(chunk.code) == 0 do return .Ok

    for {
        if DEBUG_TRACE_EXECUTION {
            fmt.printf("     ")
            for v in vm.stack {
                fmt.printf("[ %v ]", v)
            }
            fmt.println()

            instruction_disassemble(chunk, vm.ip)
        }

        opcode := cast(OpCode)chunk.code[vm.ip]
        vm.ip += 1
        switch opcode {
        case .Constant:
            const_idx := chunk.code[vm.ip]
            constant := chunk.constants[const_idx]
            vm.ip += 1
            append(&vm.stack, constant)
        case .Negate:
            constant := pop(&vm.stack)
            append(&vm.stack, -1 * constant)
        case .Add, .Subtract, .Multiply, .Divide:
            b := pop(&vm.stack)
            a := pop(&vm.stack)
            #partial switch opcode {
            case .Add:
                append(&vm.stack, a + b)
            case .Subtract:
                append(&vm.stack, a - b)
            case .Multiply:
                append(&vm.stack, a * b)
            case .Divide:
                append(&vm.stack, a / b)
            }
        case .Return:
            constant := pop(&vm.stack)
            fmt.printf("%v\n", constant)
            return .Ok
        }
    }
}

OpCode :: enum u8 {
    Constant,
    Negate,
    Add,
    Subtract,
    Multiply,
    Divide,
    Return,
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

chunk_write_constant :: proc(chunk: ^Chunk, v: Value, line: int) {
    const_idx := chunk_add_constant(chunk, cast(Value)f64(v))
    chunk_write(chunk, cast(u8)OpCode.Constant, line)
    chunk_write(chunk, cast(u8)const_idx, line)
}

@(private)
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
    case .Constant:
        const_idx := chunk.code[offset + 1]
        const_val := chunk.constants[const_idx]
        fmt.printf("%-16s %4d '%v'\n", opcode, const_idx, const_val)
        return offset + 2
    case .Negate, .Add, .Subtract, .Multiply, .Divide, .Return:
        fmt.printf("%s\n", opcode)
        return offset + 1
    case:
        fmt.printf("Unknown opcode %d\n", opcode)
        return offset + 1
    }
}
