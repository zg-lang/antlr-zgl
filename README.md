# README

This is an [ANTLR v4] grammar for the [Z Graph Language (ZGL)][ZGL].

## Using the Grammar

This repository provides zsh scripts in the `bin` directory that generate Java code.

1. Download ANTLR for Java from https://www.antlr.org/download.html.

2. Set the `JAR_ANTLR4` environment variable to point to your ANTLR JAR. For example, on macOS, I use `/Users/username/lib/antlr-4.9-complete.jar`.

3. Run `bin/gen` to generate Java classes and compile them.

4. Use the `bin/parse` or `bin/gui` script to parse input. The first generates textual output. The second generates a visual parse tree.

## Example

For example, we'll use the `example.zgl` file:

```zgl
claim = /country/USA is_a /label/struggling_democracy;
Bjornlund_20210107 = https://foreignpolicy.com/2021/01/07/u-s-struggling-democracy-pro-trump-insurrection-capitol/ ;
claim according_to Bjornlund_20210107;
```

Then parse the file with:

```sh
cat example.zgl | bin/parse
```

The output parse tree should be:

<samp>
(file (item (statement (bind claim = (expression (graph (eo (e (nonGraph (entity /country/USA)))) (eo (e (nonGraph (variable is_a)))) (eo (e (nonGraph (entity /label/struggling_democracy))))))))) ; (item (statement (bind Bjornlund_20210107 = (expression (nonGraph (literal (url https://foreignpolicy.com/2021/01/07/u-s-struggling-democracy-pro-trump-insurrection-capitol/))))))) ; (item (expression (graph (eo (e (nonGraph (variable claim)))) (eo (e (nonGraph (variable according_to)))) (eo (e (nonGraph (variable Bjornlund_20210107))))))) ; <EOF>)
</samp>

## Editor-Based Development

For development and testing the grammar, I recommend:

1. Microsoft [VS Code] with this [ANTLR extension]
2. A JetBrains IDE, such as [IntelliJ IDEA], with this [ANTLR plugin]

[ANTLR plugin]: https://plugins.jetbrains.com/plugin/7358-antlr-v4
[ANTLR extension]: https://marketplace.visualstudio.com/items?itemName=mike-lischke.vscode-antlr4
[ANTLR v4]: https://www.antlr.org/about.html
[IntelliJ IDEA]: https://www.jetbrains.com/idea/
[VS Code]: https://code.visualstudio.com
[ZGL]: https://www.zg-lang.org