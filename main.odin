package olox

import "core:testing"

main :: proc() {
    chunk: Chunk
    append(&chunk, cast(u8)OpCode.OP_RETURN)
    chunk_disassemble(chunk, "test chunk")
}

@(test)
test_main :: proc(t: ^testing.T) {
    testing.expect_value(t, 1 + 1, 2)
}
