:- use_module(peg_syntax).

:- begin_tests(simple).

abc <-- a, b, c.

a <-- "a".
b <-- "b".
c <-- "c".

test(abc) :-
    phrase(abc, `abc`, []).

:- end_tests(simple).

:- begin_tests(star).

b_star <-- b* .
b <-- "b".

test(b_star_0) :-
    phrase(b_star, ``, []).

test(b_star_1) :-
    phrase(b_star, `b`, []).

test(b_star_2) :-
    phrase(b_star, `bb`, []).

test(b_star_many) :-
    phrase(b_star, `bbbbbbbbbbbb`, []).

test(b_star_most, S =@= `xbbbbbb`) :-
    phrase(b_star, `bbbbbbxbbbbbb`, S).

:- end_tests(star).

:- begin_tests(list).

b_star(L) <-- b(L)* .
b(b) <-- "b".

test(b_star_0, L =@= []) :-
    phrase(b_star(L), ``, []).

test(b_star_1, L =@= [b]) :-
    phrase(b_star(L), `b`, []).

test(b_star_2, L =@= [b,b]) :-
    phrase(b_star(L), `bb`, []).

test(b_star_many, [L =@= [b,b,b,b,b,b,b,b,b,b,b,b]]) :-
    phrase(b_star(L), `bbbbbbbbbbbb`, []).

test(b_star_most, (L,S) == ([b,b,b,b,b,b],`xbbbbbb`)) :-
    phrase(b_star(L), `bbbbbbxbbbbbb`, S).

:- end_tests(list).

:- begin_tests(option).

b_opt <-- "b"? .
b_opt2 <-- "a", "b"?, "c".
b_opt3 <-- ("a" / "b")? .

test(b_opt_0) :-
    phrase(b_opt, ``, []).

test(b_opt_1) :-
    phrase(b_opt, `b`, []).

test(b_opt2_0) :-
    phrase(b_opt2, `ac`, []).

test(b_opt2_1) :-
    phrase(b_opt2, `abc`, []).

test(b_opt3_0) :-
    phrase(b_opt3, ``, []).

test(b_opt3_1) :-
    phrase(b_opt3, `a`, []).

test(b_opt3_2) :-
    phrase(b_opt3, `b`, []).

:- end_tests(option).

:- begin_tests(var).

b_opt(B) <-- b(B)? .

ab_opt(L) <-- (a(L) / b(L))? .

a(a) <-- "a".
b(b) <-- "b".

test(b_opt_0, true(var(B))) :-
    phrase(b_opt(B), ``, []).

test(b_opt_1, B =@= b) :-
    phrase(b_opt(B), `b`, []).

test(b_opt3_0, true(var(B))) :-
    phrase(ab_opt(B), ``, []).

test(b_opt3_1, B =@= a) :-
    phrase(ab_opt(B), `a`, []).

test(b_opt3_2, B =@= b) :-
    phrase(ab_opt(B), `b`, []).

:- end_tests(var).

:- begin_tests(greedy).

bad <-- "b"*, "b".

good <-- "b", "b"* .

test(bad, fail) :-
    phrase(bad, `bbbbbb`, _).

test(good) :-
    phrase(good, `bbbbbb`, _).

:- end_tests(greedy).
