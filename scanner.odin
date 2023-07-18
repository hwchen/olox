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
    Eof = 0,

    // single-character tokens
    LeftParen, RightParen, LeftBrace, RightBrace,
    Comma, Dot, Minus, Plus, Semicolon, Slash, Star,

    // one or two character tokens
    Bang, BangEqual, Equal, EqualEqual,
    Greater, GreaterEqual, Less, LessEqual,

    // literals
    Identifier, String, Number,

    // keywords
    And, Class, Else, False, For, Fun, If, Nil, Or,
    Print, Return, Super, This, True, Var, While,

    Error
}

token_lexeme :: proc(token: Token, src: []u8) -> []u8 {
    return src[token.start:][:token.length]
}
