# PEG Syntax for the Prolog

This package implement **[PEG]** syntax in [swi-prolog] by [`term_expansion/2`].

This package adds new operators:

| Precedence | Type  | Name  | Description    |
|:----------:|:-----:|:-----:|:-------------- |
|    1200    | `xfx` | `<--` | Rule           |
|    1105    | `xfy` |  `/`  | Ordered choice |
|    700     | `xf`  |  `?`  | Zero-or-more   |
|    700     | `xf`  |  `*`  | One-or-more    |
|    700     | `xf`  |  `+`  | Optional       |
|    700     | `fx`  |  `&`  | And-predicate  |
|    700     | `fx`  |  `!`  | Not-predicate  |

## Examples

Write **PEG** like **[DCG]** clauses in prolog, but use `<--/2` instead of `-->/2`. The `/`, `?`, `*` and `+` operators and the DCG operators (like `{}`, `,`, `|`) are allowed in the body of the PEG clause. (If you use the `|` operator it create choice points like DCG).

### Example 1

#### Program

```prolog
:- use_module(library(peg_syntax)).

gram <-- "#", ("a" / "b")*, c+, "#"? .
c <-- "c".
```

**Note**: The space between the `?` and `.` characters is necessary! 

#### Executions

```prolog
?- phrase(gram, `#abbacc`, T).
T = [].

?- phrase(gram, `#abba`, T).
false.

?- phrase(gram, `#abba#`, T).
false.

?- phrase(gram, `#ccc#`, T).
T = [].
```

**Note**: Each execution should have no choice points.

### Example 2

Using the star `*` and the plus `+` operators change the semantic of variables inside these operators. As bellow, the `H` var inside the star operator describes an element of a list, but outside of the star operator describe that list.

#### Program

```prolog
:- use_module(library(peg_syntax)).

bs(H) <-- (a(H) / b(H))* .
a(a) <-- "a".
b(b) <-- "b".
```

#### Executions

```prolog
?- phrase(bs(V), `bbabxy`, T).
V = [b, b, a, b],
T = [120, 121].

?- phrase(bs(V), ``, T).
V = T, T = [].
```


### Example 3

For each variable in a `*` operator is creating a separate list. Each element of the list is default uninitialized.

#### Program
```prolog
:- use_module(library(peg_syntax)).

pars(lists(A,B)) <-- (a(A)/ b(B))* .
a(a) <-- "a".
b(b) <-- "b".
```

#### Execution

```prolog
?- phrase(pars(P), `abba`, T).
P = lists([a, _, _, a], [_, b, b, _]),
T = [].
```

### Example 4

If you want to have a different aggregator, add it by `{}` as below.

#### Program
```prolog
:- use_module(library(peg_syntax)).

pars(P) <-- ((a(A)/ b(B)), {P = pair(A, B)})* .
a(a) <-- "a".
b(b) <-- "b".
```
#### Execution
```prolog
?- phrase(pars(P), `abba`, T).
P = [pair(a, _), pair(_, b), pair(_, b), pair(a, _)],
T = [].

```

### Example 5

Variables in the option operator if not used are uninitialized. 

#### Program
```prolog
:- use_module(library(peg_syntax)).

bopt(B) <-- b(B)? .
b(b) <-- "b".
```
#### Execution
```prolog
?- phrase(bopt(X), `b`, []).
X = b.

?- phrase(bopt(X), ``, []).
true.
```

### Example 6

The PEG grammar is [greedy] so the below `bad//0` clause will not parse anything.

#### Program

```prolog
:- use_module(library(peg_syntax)).

bad <-- "b"*, "b".

good <-- "b", "b"* .
```

#### Execution

```prolog
?- phrase(bad, `bb`, []).
false.

?- phrase(good, `bb`, []).
true.
```

### Example 7

Expressions inside the `&` and `!` operators never consumes any input.

#### Program

```prolog
:- use_module(library(peg_syntax)).

diff_list(X) <-- (& (char(A), !char(A)), char(X))* .

char(A) <-- [C], {char_code(A, C)}.
```

**Note**: The space between the `&` and `(` characters is necessary! 

#### Execution

```prolog
?- phrase(diff_list(X), `ababa`, T).
X = [a, b, a, b, a],
T = [].

?- phrase(diff_list(X), `ababba`, T).
X = [a, b, a],
T = [98, 98, 97].
```

## Installation

To install this package write the bellow term in the swipl REPL.

```prolog
?- pack_install(peg_syntax).
```


[PEG]: https://en.wikipedia.org/wiki/Parsing_expression_grammar
[`term_expansion/2`]: https://www.swi-prolog.org/pldoc/doc_for?object=term_expansion/2
[swi-prolog]: https://www.swi-prolog.org/
[DCG]: https://eu.swi-prolog.org/pldoc/man?section=DCG
[greedy]: https://en.wikipedia.org/wiki/Greedy_algorithm
