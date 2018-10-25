%{
package main

import (
    "bufio"
    "go/token"
    "io"
    "unicode"
    "github.com/cznic/golex/lex"
)

// Allocate Character classes anywhere in [0x80, 0xFF].
const (
	classUnicodeLeter = iota + 0x80
	classUnicodeDigit
	classOther
)

type lexer struct {
	*lex.Lexer
}

func (l *lexer) Error(s string) {
	println(s)
}

func rune2Class(r rune) int {
	if r >= 0 && r < 0x80 { // Keep ASCII as it is.
		return int(r)
	}
	if unicode.IsLetter(r) {
		return classUnicodeLeter
	}
	if unicode.IsDigit(r) {
		return classUnicodeDigit
	}
	return classOther
}

func newLexer(src io.Reader, dst io.Writer, fName string) *lexer {
  file := token.NewFileSet().AddFile(fName, -1, 1<<31-1)
  lx, err := lex.New(file, bufio.NewReader(src), lex.RuneClass(rune2Class))
  if (err != nil) { panic(err) }
  return &lexer{lx}
}

func (l *lexer) Lex(lval *yySymType) int {
  c := l.Enter()
%}

%yyc c
%yyn c = l.Next()
%yym l.Mark()

identifier [a-zA-Z_][0-9a-zA-Z_]*

exponent_part [eE][-+]?[0-9]+
fractional_constant ([0-9]*"."[0-9]+)|([0-9]+".")
floating_constant (({fractional_constant}{exponent_part}?)|([0-9]+{exponent_part}))[FfLl]?

integer_suffix_opt ([uU]?[lL]?)|([lL][uU])
decimal_constant [1-9][0-9]*{integer_suffix_opt}
octal_constant "0"[0-7]*{integer_suffix_opt}
hex_constant "0"[xX][0-9a-fA-F]+{integer_suffix_opt}

simple_escape [abfnrtv'"?\\]
octal_escape  [0-7]{1,3}
hex_escape "x"[0-9a-fA-F]+

escape_sequence [\\]({simple_escape}|{octal_escape}|{hex_escape})
c_char [^'\\\n]|{escape_sequence}
s_char [^"\\\n]|{escape_sequence}


h_tab [\011]
form_feed [\014]
v_tab [\013]
c_return [\015]

horizontal_white [ ]|{h_tab}

%%


{horizontal_white}+
({v_tab}|{c_return}|{form_feed})+
({horizontal_white}|{v_tab}|{c_return}|{form_feed})*\n

auto                return AUTO
break               return BREAK
case                return CASE
char                return CHAR
const               return CONST
continue            return CONTINUE
default             return DEFAULT
define              return DEFINE
defined             return OPDEFINED
do                  return DO
double              return DOUBLE
elif                return ELIF
else                return ELSE
endif               return ENDIF
enum                return ENUM
error               return ERROR
extern              return EXTERN
float               return FLOAT
for                 return FOR
goto                return GOTO
if                  return IF
ifdef               return IFDEF
ifndef              return IFNDEF
include             return INCLUDE
int                 return INT
line                return LINE
long                return LONG
pragma              return PRAGMA
register            return REGISTER
return              return RETURN
short               return SHORT
signed              return SIGNED
sizeof              return SIZEOF
static              return STATIC
struct              return STRUCT
switch              return SWITCH
typedef             return TYPEDEF
undef               return UNDEF
union               return UNION
unsigned            return UNSIGNED
void                return VOID
volatile            return VOLATILE
while               return WHILE


class               return CLASS
delete              return DELETE
friend              return FRIEND
inline              return INLINE
new                 return NEW
operator            return OPERATOR
overload            return OVERLOAD
protected           return PROTECTED
private             return PRIVATE
public              return PUBLIC
this                return THIS
virtual             return VIRTUAL

{identifier}        return IDENTIFIER

{decimal_constant}  return INTEGERconstant
{octal_constant}    return OCTALconstant
{hex_constant}      return HEXconstant
{floating_constant} return FLOATINGconstant
"L"?[']{c_char}+['] return CHARACTERconstant
"L"?["]{s_char}*["] return STRINGliteral

"("                 return '('
")"                 return ')'
","                 return ','
"#"                 return '#'
"##"                return POUNDPOUND

"{"                 return '{'
"}"                 return '}'
"["                 return '['
"]"                 return ']'
"."                 return '.'
"&"                 return '&'
"*"                 return '*'
"+"                 return '+'
"-"                 return '-'
"~"                 return '~'
"!"                 return '!'
"/"                 return '/'
"%"                 return '%'
"<"                 return '<'
">"                 return '>'
"^"                 return '^'
"|"                 return '|'
"?"                 return '?'
":"                 return ':'
";"                 return ';'
"="                 return '='

".*"                return DOTstar
"::"                return CLCL
"->"                return ARROW
"->*"               return ARROWstar
"++"                return ICR
"--"                return DECR
"<<"                return LS
">>"                return RS
"<="                return LE
">="                return GE
"=="                return EQ
"!="                return NE
"&&"                return ANDAND
"||"                return OROR
"*="                return MULTassign
"/="                return DIVassign
"%="                return MODassign
"+="                return PLUSassign
"-="                return MINUSassign
"<<="               return LSassign
">>="               return RSassign
"&="                return ANDassign
"^="                return ERassign
"|="                return ORassign
"..."               return ELLIPSIS

\/\/.*\n
\/\*(.|\n)*\*\/

%%
	if c, ok := l.Abort(); ok { return int(c) }
	goto yyAction
}
