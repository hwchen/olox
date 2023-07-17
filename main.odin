package olox

import "core:os"
import "core:testing"

DEBUG_TRACE_EXECUTION :: #config(DEBUG_TRACE_EXECUTION, false)

main :: proc() {
    // Prepare chunk
    chunk: Chunk

    chunk_write_constant(&chunk, 1.2, 123)
    chunk_write_constant(&chunk, 3.4, 123)
    chunk_write(&chunk, cast(u8)OpCode.OP_ADD, 123)
    chunk_write_constant(&chunk, 5.6, 123)
    chunk_write(&chunk, cast(u8)OpCode.OP_DIVIDE, 123)
    chunk_write(&chunk, cast(u8)OpCode.OP_NEGATE, 123)
    chunk_write(&chunk, cast(u8)OpCode.OP_RETURN, 123)

    // Disassemble and interpret chunk
    chunk_disassemble(chunk, "test chunk")
    interpret(chunk)
}

@(test)
test_main :: proc(t: ^testing.T) {
    testing.expect_value(t, 1 + 1, 2)
}
