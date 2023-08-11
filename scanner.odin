package olox

Scanner :: struct {
    src:     []u8,
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
    skip_whitespace()
    scanner.start = scanner.current

    if is_end() do return make_token(.Eof)

    c := advance()
    
    // odinfmt: disable
    switch c {
    case '(': return make_token(.LeftParen)
    case ')': return make_token(.RightParen)
    case '{': return make_token(.LeftBrace)
    case '}': return make_token(.RightBrace)
    case ';': return make_token(.Semicolon)
    case ',': return make_token(.Comma)
    case '.': return make_token(.Dot)
    case '-': return make_token(.Minus)
    case '+': return make_token(.Plus)
    case '/': return make_token(.Slash)
    case '*': return make_token(.Star)
    case '!': return make_token(match('=') ? .BangEqual : .Bang)
    case '=': return make_token(match('=') ? .EqualEqual : .Equal)
    case '<': return make_token(match('=') ? .LessEqual : .Less)
    case '>': return make_token(match('=') ? .GreaterEqual : .Greater)
    }
    // odinfmt: enable

    return error_token("Unexpected character.")
}

skip_whitespace :: proc() {
    for {
        c := peek()
        switch c {
        case ' ', '\r', '\t':
            advance()
        case '\n':
            scanner.line += 1
            advance()
        case:
            return
        }
    }
}

advance :: proc() -> u8 {
    scanner.current += 1
    return scanner.src[scanner.current]
}

peek :: proc() -> u8 {
    return scanner.src[scanner.current]
}

// advances if matches
match :: proc(expected: u8) -> bool {
    if is_end() do return false
    if scanner.src[scanner.current] != expected do return false
    scanner.current += 1
    return true
}

is_end :: proc() -> bool {
    return scanner.current >= len(scanner.src)
}

make_token :: proc(type: TokenType) -> Token {
    return(
        Token{
            type = type,
            start = scanner.start,
            length = scanner.current - scanner.start,
            line = scanner.line,
        } \
    )
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

// odinfmt: disable
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

    Error,
}
// odinfmt: enable

token_lexeme :: proc(token: Token, src: []u8) -> []u8 {
    return src[token.start:][:token.length]
}
