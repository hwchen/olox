package olox

Scanner :: struct {
    start:   int,
    current: int,
    line:    int,
}

scanner: Scanner

scanner_init :: proc() {
    scanner.start = 0
    scanner.current = 0
    scanner.line = 1
}

scan_token :: proc() -> Token {
    token : Token
    return token
}

Token :: struct {
    type:   TokenType,
    start:  int,
    length: int,
    line:   int,
}

TokenType :: enum {
    EOF = 0,

    // single-character tokens
    LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE,
    COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR,

    // one or two character tokens
    BANG, BANG_EQUAL, EQUAL, EQUAL_EQUAL,
    GREATER, GREATER_EQUAL, LESS, LESS_EQUAL,

    // literals
    IDENTIFIER, STRING, NUMBER,

    // keywords
    AND, CLASS, ELSE, FALSE, FOR, FUN, IF, NIL, OR,
    PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE,

    ERROR
}

token_lexeme :: proc(token: Token, src: []u8) -> []u8 {
    return src[token.start:][:token.length]
}
