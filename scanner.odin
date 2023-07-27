package olox

Scanner :: struct {
    src: []u8,
    start:   int,
    current: int,
    line:    int,

    err_msg: Maybe(string),
}

scanner: Scanner

scanner_init :: proc() {
    scanner.start = 0
    scanner.current = 0
    scanner.line = 1
}

scan_token :: proc() -> Token {
    scanner.start = scanner.current;

    if is_end() do return make_token(.Eof);

    return error_token("Unexpected character.")
}

is_end :: proc() -> bool {
    return scanner.current >= len(scanner.src)
}

make_token :: proc(type: TokenType) -> Token {
    return Token {
        type = type,
        start = scanner.start,
        length = scanner.current - scanner.start,
        line = scanner.line,
    };
}

// Hack for storing error messages. In clox, these are defined inline as string literals,
// and then start is set to that pointer. Here, we'll store the err msg in the scanner and
// retrieve it in a separate step.
//
// TODO: not sure if clox scanner does early return on errors, will have to restructure if not.
error_token :: proc(msg: string) -> Token {
    scanner.err_msg = msg

    return make_token(.Error)
}

// === Tokens ===

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
