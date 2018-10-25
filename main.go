//go:generate goyacc -l -o parser.go cpp5.y
//go:generate golex -o scanner.go cpp5.l

package main

import (
	"bytes"
	"os"
)

const src = `

void A() {  // Just an example
  a = help_me(42, pi()) / 2;
}

`

func main() {
	yyDebug = 10
	yyErrorVerbose = true
	l := newLexer(bytes.NewBufferString(src), os.Stdout, "file.name")
	yyParse(l)
}
