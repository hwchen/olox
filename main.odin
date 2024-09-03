package olox

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:testing"

DEBUG_TRACE_EXECUTION :: #config(DEBUG_TRACE_EXECUTION, false)

main :: proc() {
	if len(os.args) == 1 {
		repl()
	} else if len(os.args) == 2 {
		//run_file(os.args[1])
		fmt.eprintln("Files not yet supported")
		os.exit(128)
	} else {
		fmt.eprintln("Usage: olox [path]")
		os.exit(64)
	}
}

repl :: proc() {
	vm: Vm

	rdr: bufio.Reader
	buf: [1024]u8
	bufio.reader_init_with_buf(&rdr, os.stream_from_handle(os.stdin), buf[:])

	for {
		fmt.print("> ")

		line, err := bufio.reader_read_slice(&rdr, '\n');if err != nil do break
		chunk := compile(line)
		vm_interpret(&vm, chunk)
	}
}

run_file :: proc(path: string) {
	vm: Vm
	src, _ := os.read_entire_file(path)
	chunk := compile(src)
	result := vm_interpret(&vm, chunk)

	switch result {
	case .CompilerError:
		os.exit(65)
	case .RuntimeError:
		os.exit(70)
	case .Ok:
	}
}
