:- module(peg_syntax, [
              op(1200,xfx,<--),
              op(1105,xfy,/),
              op(700,xf,?),
              op(700,xf,*),
              op(700,xf,+),
              peg_translate_rule/2
          ]).

:- '$hide'((<--)/2).

peg_translate_rule((A <-- B), [A --> Body|T]) :-
    functor(A, NA, _),
    peg_expansion(NA, B, Body, 0, _, T-[]).

peg_expansion(Name, (A, B), (ABody,BBody), M0, M2, Head-Tail1) :-
    !,
    peg_expansion(Name, A, ABody, M0, M1, Head-Tail0),
    peg_expansion(Name, B, BBody, M1, M2, Tail0-Tail1).

peg_expansion(Name, (A +), Plus, M0, M1, Out) :-
    !,
    plus_expansion(Name, A, Plus, M0, M1, Out).

peg_expansion(Name, (A ?), Body, M0, M1, Out) :-
    !,
    peg_expansion(Name, (A / []), Body, M0, M1, Out).

peg_expansion(Name, (A *), Star, M0, M1, Out) :-
    !,
    star_expansion(Name, A, Star, M0, M1, Out).

peg_expansion(Name, (A / B), (ABody, !; BBody), M0, M2, Head-Tail1) :-
    !,
    peg_expansion(Name, A, ABody, M0, M1, Head-Tail0),
    peg_expansion(Name, B, BBody, M1, M2, Tail0-Tail1).

peg_expansion(_, Body, Body, M, M, X-X).

plus_expansion(Name, A, Plus, M0, M4, [(PlusPairs --> One, ManyTail),
                                       (ManyPairs --> One, !, ManyTail),
                                       (ManyNil --> []),
                                       (One --> Body)|Tail0]-Tail1):-
    !,
    atomic_concat(Name, M0, NPlus),
    succ(M0, M1),
    atomic_concat(Name, M1, NMany),
    succ(M1, M2),
    atomic_concat(Name, M2, NOne),
    succ(M2, M3),
    term_variables(A, Vars),
    maplist([[],P,H,T]>>(P=[H|T]), Nils, Pairs, Vars, Tails),
    One =.. [NOne|Vars],
    Plus =.. [NPlus|Vars],
    PlusPairs =.. [NPlus|Pairs],
    ManyPairs =.. [NMany|Pairs],
    ManyTail =.. [NMany|Tails],
    ManyNil =.. [NMany|Nils],
    peg_expansion(Name, A, Body, M3, M4, Tail0-Tail1).

star_expansion(Name, A, Many, M0, M3, [(ManyPairs --> One, !, ManyTail),
                                       (ManyNil --> []),
                                       (One --> Body)|Tail0]-Tail1):-
    !,
    atomic_concat(Name, M0, NMany),
    succ(M0, M1),
    atomic_concat(Name, M1, NOne),
    succ(M1, M2),
    term_variables(A, Vars),
    maplist([[],P,H,T]>>(P=[H|T]), Nils, Pairs, Vars, Tails),
    One =.. [NOne|Vars],
    Many =.. [NMany|Vars],
    ManyPairs =.. [NMany|Pairs],
    ManyTail =.. [NMany|Tails],
    ManyNil =.. [NMany|Nils],
    peg_expansion(Name, A, Body, M2, M3, Tail0-Tail1).

:- multifile term_expansion/2.

system:term_expansion(In, Out) :-
    peg_syntax:peg_translate_rule(In, Out).


