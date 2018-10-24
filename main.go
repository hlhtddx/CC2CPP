//go:generate goyacc -l -o parser.go cpp5.y
//go:generate golex -o scanner.go cpp5.l

package main

import (
	"bytes"
	"os"
)

func main() {
	yyDebug = 1
	yyErrorVerbose = true
	l := newLexer(bytes.NewBufferString(src), os.Stdout, "file.name")
	yyParse(l)
}
