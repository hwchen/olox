package olox

import "core:fmt"

OpCode :: enum u8 {
    OP_RETURN,
}

Chunk :: distinct [dynamic]u8
