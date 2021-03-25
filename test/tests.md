# Tests

This directory contains:

* `all` : An executable Python 3 script. Runs all tests.
* `all.io_test` : A set of test cases consisting of (input, output) pairs. The format is described below.

## IO Test Format

This is simple custom test case format. It is a file consisting of zero or more test cases.

```io_test
<<< BEGIN >>>

===============
{INPUT}
- - - - - - - -
{OUTPUT}

{...}

<<< END >>>
```

## `<<< BEGIN >>>`

* Must be present and typed exactly as shown, on one line.
* Anything before `<<< BEGIN >>>` is ignored.

## `<<< END >>>`

* Must be present and typed exactly as shown, on one line.
* After `<<< BEGIN >>>` is found, anything after `<<< END >>>` is ignored.

## Test Case

* `=====` (or longer) separates test cases.
* `- - -` (or longer) separates input and output for a particular test case.
* `{...}` means 'repeat'. Do not include in literally.

## `{INPUT}`

* One or more lines may be input.
* Do not include the curly braces.
* This input is provided to the parser as `STDIN`.

## `{OUTPUT}`

* Only only line allowed.
* Do not include the curly braces.
* `{OUTPUT}` is compared against the output of the parser.
  * If `STDERR` has any output, its beginning must match `{OUTPUT}`. (This allows the test file to only specify a prefix of the error message for convenience.)
  * Otherwise, `STDOUT` must completely match `{OUTPUT}`.
