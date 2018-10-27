//go:generate goyacc -l -o parser.go cpp5.y
//go:generate golex -o scanner.go cpp5.l

package main

import (
	"bufio"
	"bytes"
	"flag"
	"fmt"
	"io"
	"os"
)

const src = `

void A() {  // Just an example
  a = help_me(42, pi()) / 2;
}

`

func parseArgs() (string, bool) {
	var filename string
	flag.StringVar(&filename, "f", "", "Specify the file name to be compiled")
	flag.Parse()

	if filename == "" {
		fmt.Printf("filename=%s\n", filename)
		return filename, false
	}
	fmt.Printf("filename=%s\n", filename)
	return filename, true
}

func main() {
	yyDebug = 3
	yyErrorVerbose = true
	var reader io.Reader
	var name string
	if filename, ok := parseArgs(); ok {
		if fp, err := os.Open(filename); err == nil {
			reader = bufio.NewReader(fp)
			name = "file.name"
		} else {
			fmt.Fprintln(os.Stderr, err.Error())
		}
	} else {
		reader = bytes.NewBufferString(src)
		name = "file.name"
	}
	l := newLexer(reader, os.Stdout, name)
	yyParse(l)
}
