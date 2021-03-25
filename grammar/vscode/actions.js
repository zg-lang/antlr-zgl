"use strict";

// Quoted from:
// https://github.com/mike-lischke/vscode-antlr4/blob/master/doc/grammar-debugging.md
//
// Actions and Semantic Predicates
//
// Grammars sometimes contain code in the target language of the generated
// lexer/parser. That can be support code in named actions (e.g. import or
// #include statements), other code within rules to support the parsing
// process or semantic predicates, to guide the parser. However, because this
// extension uses the interpreters for debugging it is not possible to run any
// of this code directly (even if the predicates are written in JS, let alone
// other languages). And since named and unnamed actions are usually to
// support the generated parser (and mostly not relevant for debugging), they
// are ignored by the extension debugger. However, for predicates there's an
// approach to simulate what the generated lexer/parser would do.
//
// This is possible by using a Javascript file, which contains code to
// evaluate semantic predicates (see the Setup section for how to enable it).
// That means however, the predicates must be written in valid JS code. Since
// predicates are usually short and use simple expressions (like {version <
// 1000} or {doesItBlend()} it should be easy to use what's originally written
// for another language (JS, C++, TS, Java etc. which all share a very similar
// expression syntax) without changes in the grammar. If an expression doesn't
// work in JS, you will have to change it however, temporarily.
//
// ...
