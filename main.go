//go:generate goyacc -o parser.go example.y
//go:generate golex -o scanner.go example.l

package main

//
//func main() {
//	yyDebug = 1
//	yyErrorVerbose = true
//	l := newLexer(bytes.NewBufferString(src), os.Stdout, "file.name")
//	yyParse(l)
//}
