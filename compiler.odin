package olox

import "core:fmt"

compile :: proc(src: []u8) -> Chunk {
    // scanner uses file-level global variable
    scanner_init()

    // temporary to drive the scanner
    line := -1
    for {
        token := scan_token()
        if token.line != line {
            fmt.printf("%4d ", token.line)
            line = token.line
        } else {
            fmt.print("   |")
        }
        fmt.printf("%v '%s'\n", token.type, token_lexeme(token, src))

        if token.type == .EOF do break
    }

    chunk: Chunk
    return chunk
}
