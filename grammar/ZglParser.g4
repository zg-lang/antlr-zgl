/** ANTLR4 parser grammar for the Z Graph Language, ZGL. */
parser grammar ZglParser;

options {
    tokenVocab = ZglLexer;
}

/** document: A document consists of semicolon (;) separated items. */
file: (item Semicolon)* EOF;

/**
item: An item is a direct child of a document.  It may be a statement or
expression.
*/
item: statement | expression;

/** 
statement: A statement causes a side effect.  It can not be evaluated; it
does not have a return value. 
*/
statement: alias | bind | use;

/**
expr: All expressions evaluate to a value.  An expression is either:
(1) a graph expression (aka GE or `graph` in the grammar) or
(2) a non-graph expression (aka NGE or `nonGraph` in the grammar)
*/
expression: graph | nonGraph[false];

/**
non-graph expression (aka NGE): An expression that is not a graph.

If its parent is a GE, a NGE may contain a GE.  (Why? See below.)  
In the grammar, this condition is controlled by a
[semantic predicate][sp]: `{$pg}?`. 

[sp]: https://github.com/antlr/antlr4/blob/master/doc/predicates.md

Note: Below, the argument `pg` means "parent is graph expression".

Why "If its parent is a GE, a NGE may contain a GE"?  To rephrase,
why can't all NGE's contain a GE?  Here is an example of syntax we
want to be an **invalid** expression: `(a b c)`.  On the other hand,
here is a **valid** expression: `(a b c) d e`.
*/
nonGraph[boolean pg]
    : entity                            // #1 entity
    | variable[pg]                      // #2 variable
    | literal                           // #3 literal
    | list                              // #4 list
    | map                               // #5 map
    | set                               // #6 set
    | {$pg}? LeftParen graph RightParen // #7 graph expression
    ;


entity: Entity;

/**
variable: In most cases, an indentifier serves as variable name. 

If the parent is a graph expression, a variable may be:
1. an identifier prefixed with a plus (+).
2. *only* a plus (+). 

In the second case, a `+` variable serves as an anonymous placeholder.
At run-time, an entity is created and connected to the specified
graph expression; however, that entity will not have a variable
pointing to it.

Note: Below, the argument `pg` means "parent is graph expression".
*/
variable[boolean pg]
    : Id
    | {$pg}? <fail = '+ not allowed'> PlusId
    | {$pg}? <fail = '+ not allowed'> Plus
    ;

/**
graph expression: A graph expression species a directed edge between two nodes.

The grammar here is a subset of a complete graph expression grammar; it trades
off complete coverage but has a shallower parse tree. In practice, I expect it
will be more than enough for practical use cases.
*/

graph
    : eo eo eo
    | ee* eo ee+
    | ee+ eo ee*
    ;

/**
expression having a graph expression parent

The `e` rule is a shorthand to represent a non-graph expression with a graph
expression parent.
*/
e: nonGraph[true];

/** e (even) */
ee
    : (e e)+
    | LeftBrace (e e)+ (Comma (e e)+)* Comma? RightBrace
    ; 

/** e (even) */
eo
    : e (e e)*
    | LeftBrace e (e e)* (Comma e (e e)*)* Comma? RightBrace
    ;

/** An alias statement. */
alias: Alias entity entity;

/** A bind statement. */
bind: Id Equal expression;

/** A use statement. */
use: Use path;

/** A path. */
path: Id | AbsolutePath | RelativePath;

/**
literal

"Literals represent values. These are fixed values -- not variables -- that you
_literally_ provide [e.g. write or type] in the file."

The above is borrowed from the Mozilla docs on JavaScript grammar:
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Grammar_and_types
*/
literal
    : bool           // #1 boolean
    | intNum         // #2 integer
    | floatNum       // #3 floating-point number
    | quantity       // #4 quantity
    | string         // #5 string
    | date           // #6 date
    | dateTime       // #7 datetime
    | url            // #7 URI
    | base64         // #8 base64
    | taggedLiteral  // #8 tagged literal
    ;

/**
list

A list is a heterogenous sequence of expressions. A trailing comma is allowed
for non-empty lists.

Examples: [] ["x"] [2, 3, 5,]

Counter-examples: [,] "knitting" 
*/
list
    : LeftBracket RightBracket
    | LeftBracket expression (Comma expression)* Comma? RightBracket
    ;

/**
set

A set is a heterogenous unordered collection of expressions. A trailing comma is
allowed for non-empty sets.

Examples: #{} #{'a', 2} #{'a', 2,}

Counter-examples: #{,} "knitting"} 
*/
set
    : HashLeftBrace RightBrace
    | HashLeftBrace expression (Comma expression)* Comma? RightBrace
    ;

/**
map

A map is a heterogenous unordered collection of key-value pairs. Keys and values
may be any expression. A trailing comma is allowed for non-empty maps.
 
Examples:
  {}
  {"a": 1,}
  {2: "two", 5: foo }
 
Counter-examples: {3 2 : 1}
*/
map
    : LeftBrace RightBrace
    | LeftBrace expression Colon expression (
        Comma expression Colon expression
    )* Comma? RightBrace
    ;

/** boolean */
bool: True | False;

/** integer */
intNum
    : DecimalInteger
    | BinaryInteger
    | OctalInteger
    | HexInteger
    ;

/** floating-point number */
floatNum: FloatNumber;

/**
quantity, including a unit of measurement

Example: <72 inches> 
*/
quantity
    : LeftAngle (intNum | floatNum) (variable[false] | entity) RightAngle
    ;

/** string */
string: String (Concat String)*;

/** date */
date: Date;

dateTime: DateTime;

/** URI: Uniform Resource Identifier. */
url: Url;

base64: Base64;

/** A tagged literal. */
taggedLiteral: Tag literal;
