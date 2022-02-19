:- module(peg_syntax, [
              op(1200,xfx,<--),
              op(1105,xfy,/),
              op(700,xf,?),
              op(700,xf,*),
              op(700,xf,+),
              peg_translate_rule/2
          ]).

peg_translate_rule((A <-- B), [A --> Body|T]) :-
    functor(A, NA, _),
    peg_expansion(NA, B, Body, 0, _, T-[]).

peg_expansion(Name, (A, B), (ABody,BBody), M0, M2, Head-Tail1) :-
    !,
    peg_expansion(Name, A, ABody, M0, M1, Head-Tail0),
    peg_expansion(Name, B, BBody, M1, M2, Tail0-Tail1).

peg_expansion(Name, (A +), (One, Many), M0, M1, Out) :-
    !,
    star_expansion(Name, A, One, Many, M0, M1, Out).

peg_expansion(Name, (A ?), Body, M0, M1, Out) :-
    !,
    peg_expansion(Name, (A / []), Body, M0, M1, Out).

peg_expansion(Name, (A *), Many, M0, M1, Out) :-
    !,
    star_expansion(Name, A, _, Many, M0, M1, Out).

peg_expansion(Name, (A / B), (ABody, !; BBody), M0, M2, Head-Tail1) :-
    !,
    peg_expansion(Name, A, ABody, M0, M1, Head-Tail0),
    peg_expansion(Name, B, BBody, M1, M2, Tail0-Tail1).

peg_expansion(_, Body, Body, M, M, X-X).

star_expansion(Name, A, One, Many, M0, M3, [(Many --> One, !, Many), (Many --> []), (One --> Body)|Tail0]-Tail1):-
    !,
    atomic_concat(Name, M0, Many),
    succ(M0, M1),
    atomic_concat(Name, M1, One),
    succ(M1, M2),
    peg_expansion(Name, A, Body, M2, M3, Tail0-Tail1).

:- multifile term_expansion/2.

system:term_expansion(In, Out) :-
    peg_syntax:peg_translate_rule(In, Out).


