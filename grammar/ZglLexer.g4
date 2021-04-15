/** ANTLR4 lexer grammar for the Z Graph Language, ZGL. */
lexer grammar ZglLexer;

channels {
    WS_CHAN,
    COMMENT_CHAN,
    CONTINUE_CHAN
}

/*
How does ANTLR decide which lexer rule to apply?

1. The primary goal is to match the lexer rule that recognizes the most input
   characters.

2. If more than one lexer rule matches the same input sequence, the priority
   goes to the rule occurring first in the grammar file.

3. Nongreedy subrules match the fewest number of characters that still allows
   the surrounding lexical rule to match.

Source: https://stackoverflow.com/a/66035710/109618
*/

/**
A block comment (possibly multi-line).
Must occur before Whitespace and LineComment.
*/
BlockComment: '/*' .*? '*/' -> channel(COMMENT_CHAN);

/**
A single-line comment.
Must occur before Whitespace.
*/
LineComment
    : '//' ~[\r\n]* '\r'? '\n' -> channel(COMMENT_CHAN)
    ;

/**
A base64 literal; e.g. b64"YmFk".
Must occur before String and Whitespace.
*/
Base64: [bB] '64"' [A-Za-z0-9+/]* [=]* '"';

/**
A string literal; e.g. "foo".
Must occur before WS and LC.
*/
String: StringPrefix? StringGroup;

/**
A URL
URL = scheme:[//authority]path[?query][#fragment]
This grammar supports these schemes: http, https.
*/
Url: 'http' 's'? '://' UrlChars;

/**
An entity
Examples:
  /country/Ireland
  /person/Bono
Counter-examples
  country/Ireland
  Bono
*/
Entity: ('/' Segment)+;

/**
An absolute path.
Examples:
  ::core
  ::country::Finland
  ::org::United_Nations
Counter-examples:
  ::org::"United Nations"
*/
AbsolutePath: ('::' Segment)+;

/**
A relative (module) path.
Technically, a plain (one segment) path is a relative path. However, this
lexer rule does match a plain path because of the lexical overlap with a
variable.
Examples:
  here::there
  x::y::z
Counter-examples:
  core
  ::main
  ::math::constants
  no::"quotes"
  "no way"
  /person/Bono
*/
RelativePath: Segment ('::' Segment)+;

/** The :alias keyword. */
Alias: ':alias';

/** The :use keyword. */
Use: ':use';

/** A tag. */
Tag: '#' Segment;

/**
An RFC 3339 datetime.
Generally follows this pattern:
YYYY-MM-DDTHH:MM:SS<fraction><offset>

Examples: 2012-12-31T13:34:00Z
Counter-examples: 2012-12-31 1776-07-04
*/
DateTime: YMD 'T' HMS Offset;

/**
An RFC 3339 YYYY-MM-DD date.
Examples: 2012-12-31 1776-07-04
Counter-examples: 1950-Jan-2 yesterday tomorrow Apr-2020
*/
Date: YMD;

/** A decimal (base 10) integer. A literal. */
DecimalInteger: [-+]? WholeNumber Exponent?;

/** One or more binary digits. A literal. Numeric. */
BinaryInteger: '0b' [01]+;

/** One or more octal digits. A literal. Numeric. */
OctalInteger: '0o' [0-7]+;

/** One or more hexadecimal digits. A literal. Numeric. */
HexInteger: '0x' HexDigit+;

/**
A floating point number. A literal. Numeric.
Examples:
  2.2
  1024.
  1_024.
  365.256_363_004
  +2.2
  1.2e3
  2.34e+4
  0.1e-2
  -5.
  1.e2
Counter-examples:
  6
  .1
  .
  04
  04.
*/
FloatNumber
    : [-+]? WholeNumber '.' WholeNumber? Exponent?
    | [-+]? '.' WholeNumber Exponent?
    ;

// == Boolean tokens ==
// Must occur before the identifier rules.

True: 'true';

False: 'false';

// == One-character tokens ==
// Generally, these belong at the bottom.
// Otherwise, these would conflict with the `Uri` rule.

// == Various delimiters ==
// Must occur after comments and strings.

/** Comma. */
Comma: ',';

/** Colon. */
Colon: ':';

/** Semicolon. */
Semicolon: ';';

/** Plus. */
Concat: '++';

/** Plus. */
Plus: '+';

// == Grouping tokens ==
// Must occur after comments and strings.

/** Left parenthesis / round bracket. */
LeftParen: '(';

/** Right parenthesis / round bracket. */
RightParen: ')';

/** Left square bracket. */
LeftBracket: '[';

/** Right square bracket. */
RightBracket: ']';

/**
The left set delimiter.
The right set delimeter is }, see RightBrace.
*/
HashLeftBrace: '#{';

/** Left curly brace. */
LeftBrace: '{';

/** Right curly brace. */
RightBrace: '}';

/** Left angle bracket / chevron. */
LeftAngle: '<';

/** Right angle bracket / chevron. */
RightAngle: '>';

/** Equal sign. */
Equal: '=';

PlusId: '+' Segment;

/**
A (generic) identifier.
Examples:
  x
  USA
Counter-examples:
  ::foo
  hi::there
  /country/Mexico
*/
Id: Segment;

// Invalid: ~[ \r\t\n;,+()[\]{}<>#]+;
Invalid: ~[ \r\t\n;:,()[\]{}<>#]+;

/**
Whitespace.
Must occur after comments and strings.
*/
Whitespace: [ \r\t\n]+ -> channel(WS_CHAN);

// == Fragment Rules ==
//
// The ordering of fragment rule declarations does _not_ matter;
// however, the order in which they are referenced _does_.

fragment ASCII_Escape
    : '\\x' [0-7] HexDigit
    | '\\n'
    | '\\r'
    | '\\t'
    | '\\\\'
    | '\\0'
    ;

/** Character escape (inside a string).
Examples: \t \n \r \" \' \\
Counter-examples: \b \q \x
*/
fragment CharacterEscape: '\\' [tnr"'\\];

/**
Two digit day of month.
Examples: 01 02 03 08 09 10 11 23 28 30 31
Counter-examples: 0 32 33
*/
fragment Day: [0-2] [1-9] | '3' [0-1];

/**
An exponent suffix.
Examples: E3 E+3 e-2 e0
Counter-examples: exp7 +3
*/
fragment Exponent: [Ee] [-+]? WholeNumber;

/**
A hexadecimal digit.
Examples: 0 3 9 b C D f
Counter-examples: g G z Z x X
*/
fragment HexDigit: [0-9a-fA-F];

fragment HMS: Hour ':' Minute ':' Second ('.' WholeNumber)?;
/**
Time offest
Examples: -05:00
Counter-examples: +15:00

Regex:
(?:Z
  |[-+](?:00|01|02|03|04|05|06|07|08|09|10|11|12|13|14)
   :
   (?:00|15|30|45))
*/
fragment Offset
    : 'Z'
    | [-+] ('0' [0-9] | '1' [0-4]) ':' ('00' | '15' | '30' | '45')
    ;

/*
A two digit hour.
Examples: 00 04 12 13 21 23
Counter-examples: 24 25
*/
fragment Hour: [0-1] [0-9] | '2' [0-3];

/*
A two digit minute.
Examples: 00 08 32 59
Counter-examples: 60 61 99
*/
fragment Minute: [0-5][0-9];

/*
A two digit month number (01 to 12).
Examples: 01 04 09 11 12
Counter-examples: 00 0 1 3 4 13
*/
fragment Month: '0' [1-9] | '1' [0-2];

fragment QuoteEscape: '\\\'' | '\\"' ;

/*
A two digit second.
Examples: 00 08 32 59
Counter-examples: 60 61 99
*/
fragment Second: [0-5][0-9];

/**
A segment.
May be a part of some identifiers and some paths.
Examples: Abe _x Cafe7 hot-dog h0t_dawg
Counter-examples: - _ 71 2nd "xyz"
*/
fragment Segment: [\p{ID_Start}] [\p{ID_Continue}]*;

/**
A string prefix.
Examples: "-e" "-eca" "-ace"
*/
fragment StringPrefix: '-' [ecltaz]+;

fragment StringGroup
    : '"' .*? '"'
    | '#' StringGroup '#'
    ;

/**
An escape sequence for use in strings.
Examples: \t \n \r \" \' \\ \u2020
Counter-examples: \q \x
*/
fragment StringEscape: ASCII_Escape | QuoteEscape | UnicodeEscape;

/**
A unicode escape code.
Examples: \u2020
Counter-examples: \uFFF \unicorn unit
*/
fragment UnicodeEscape
    : '\\u{' HexDigit (HexDigit (HexDigit (HexDigit (HexDigit HexDigit? )? )? )? )? '}'
    ;

/** Valid URI characters. */
fragment UrlChars: ~[ \r\t\n]+;

/**
A whole number; i.e. zero or greater.
Examples: 0 1 2 3 8 9 10 11 101 2009
Counter-examples: 00 01 02 0x12
More general than: DayOfMonth, Month, Year
*/
fragment WholeNumber: '0' | [1-9] [_0-9]*;

/** 
A four-digit year.
Examples: 1492 1776 2016 2020
Counter-examples: 721 0123 40 0000
More specific than: WholeNum
*/
fragment Year: [1-9] [0-9] [0-9] [0-9];

fragment YMD: Year '-' Month '-' Day;
