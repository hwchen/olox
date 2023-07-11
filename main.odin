package olox

import "core:os"
import "core:testing"

DEBUG_TRACE_EXECUTION :: #config(DEBUG_TRACE_EXECUTION, false)

main :: proc() {
    chunk: Chunk

    const_idx := chunk_add_constant(&chunk, cast(Value)f64(1.2))
    chunk_write(&chunk, cast(u8)OpCode.OP_CONSTANT, 123)
    chunk_write(&chunk, cast(u8)const_idx, 123)

    chunk_write(&chunk, cast(u8)OpCode.OP_RETURN, 123)

    chunk_disassemble(chunk, "test chunk")

    interpret(chunk)
}

@(test)
test_main :: proc(t: ^testing.T) {
    testing.expect_value(t, 1 + 1, 2)
}
