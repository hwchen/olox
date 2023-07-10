package olox

import "core:fmt"
import "core:testing"

main :: proc() {}

@(test)
test_main :: proc(t: ^testing.T) {
    testing.expect_value(t, 1 + 1, 2)
}
