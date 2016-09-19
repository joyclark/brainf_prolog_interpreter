:- use_module(library(plunit)).
:- begin_tests(moveright).
test(r_empty_right) :-
   interpret(right,_,_,_,_,[3,2,1]-4-[],[4,3,2,1]-0-[]).
test(r_empty_left) :-
   interpret(right,_,_,_,_,[]-4-[],[4]-0-[]).
test(el_right) :-
   interpret(right,_,_,_,_,[3,2,1]-4-[5,6],[4,3,2,1]-5-[6]).
:- end_tests(moveright).

:- begin_tests(moveleft).
test(l_empty_right) :-
   interpret(left,_,_,_,_,[3,2,1]-4-[],[2,1]-3-[4]).
test(l_empty_left) :-
   interpret(left,_,_,_,_,[]-4-[],[]-0-[4]).
test(el_left) :-
   interpret(left,_,_,_,_,[3,2,1]-4-[5,6],[2,1]-3-[4,5,6]).
:- end_tests(moveleft).

:- begin_tests(inc).
test(inc) :-
   interpret(inc,_,_,_,_,_-4-_,_-5-_).
:- end_tests(inc).

:- begin_tests(dec).
test(dec) :-
   interpret(dec,_,_,_,_,_-4-_,_-3-_).
:- end_tests(dec).

:- begin_tests(getchar).
test(onechar) :-
    string_to_list("foo", Codes),
    Codes = [H|T],
    interpret(getchar,Codes,T,Out,Out,_BIn,_-H-_).
:- end_tests(getchar).

:- begin_tests(putchar).
test(onechar_empty) :-
   interpret(putchar,StdIn,StdIn,[],[102],L-102-R,L-102-R).
test(onechar_full) :-
   interpret(putchar,StdIn,StdIn,[111],[102,111],L-102-R,L-102-R).
:- end_tests(putchar).

:- begin_tests(plus).
test(empty_cell) :-
    brainf([], Res, "+."), !, Res = "\001\".
test(double_add) :-
    brainf([], Res, "++."), !, Res = "\002\".
:- end_tests(plus).

:- begin_tests(minus).
test(empty_minus, error(type_error(character_code, -1), _Context)) :-
    brainf([], _Res, "-."), !. % There is no ASCII code for -1
:- end_tests(minus).

:- begin_tests(mixed).
test(plus_minus) :-
    brainf([], Res, "+-."), !, Res = "\000\".
test(plus_double_minus, error(type_error(character_code, -1), _Context)) :-
    brainf([], _Res, "+--."), !. % There is no ASCII code for -1
:- end_tests(mixed). 

:- begin_tests(comma).
test(take_char) :-
    brainf("foo", Res, ",."), !, Res = "f".
test(take_all_chars) :-
    brainf("foo", Res, ",.,.,."), !, Res = "foo".
:- end_tests(comma).

:- begin_tests(movement).
test(no_move) :-
    brainf([], Res, "+++++."), !, Res = "\005\".
test(move_right) :-
    brainf([], Res, "+++++>+."), !, Res = "\001\".
test(move_double_right) :-
    brainf([], Res, "+++++>>+."), !, Res = "\001\".
test(first_move_right) :-
    brainf([], Res, ">+."), !, Res = "\001\".
test(move_left) :-
    brainf([], Res, "+++++<+."), !, Res = "\001\".
test(move_double_left) :-
    brainf([], Res, "+++++<<+."), !, Res = "\001\".
test(first_move_left) :-
    brainf([], Res, "<+."), !, Res = "\001\".
test(left_right_and_all_over_again) :-
    brainf([], Res, "++++.>++.<++.<+.>+++.>+++.>+++.<++."), !, Res = "\004\\002\\006\\001\\t\005\\003\\007\".
:- end_tests(movement).

:- begin_tests(loop).
test(loop) :-
    brainf([], Res, "+++[.-]+."), !, Res = "\003\\002\\001\\001\".
:- end_tests(loop).

:- begin_tests(helloworld).
test(helloworld) :-
    brainf("",R,"++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>."),
    R == "Hello World!\n".
test(helloworld2) :-
    brainf("",R,"++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."),
    R == "Hello World!\n".
test(complicated_hw) :-
    brainf("",R,">++++++++[<+++++++++>-]<.>>+>+>++>[-]+<[>[->+<<++++>]<<]>.+++++++..+++.>>+++++++.<<<[[-]<[-]>]<+++++++++++++++.>>.+++.------.--------.>>+.>++++."),
    R == "Hello World!\n".
:- end_tests(helloworld).

test6(R) :- inst_list(R,"++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.",[]).

parse(right) --> ">".
parse(left) --> "<".
parse(inc) --> "+".
parse(dec) --> "-".
parse(putchar) --> ".".
parse(getchar) --> ",".
parse(loop(Instructions)) --> "[", inst_list(Instructions), "]".
inst_list([]) --> "".
inst_list([I|L]) --> parse(I), inst_list(L).

interpret(right,StdIn,StdIn,StdOut,StdOut,L-E-[],[E|L]-0-[]) :- !.
interpret(right,StdIn,StdIn,StdOut,StdOut,L-E-[H|T],[E|L]-H-T).
interpret(left,StdIn,StdIn,StdOut,StdOut,[]-E-L,[]-0-[E|L]) :- !.
interpret(left,StdIn,StdIn,StdOut,StdOut,[H|T]-E-L,T-H-[E|L]).
interpret(inc,StdIn,StdIn,StdOut,StdOut,L-E-R,L-E2-R) :- E2 is E + 1.
interpret(dec,StdIn,StdIn,StdOut,StdOut,L-E-R,L-E2-R) :- E2 is E - 1.
interpret(getchar,[C|Rest],Rest,StdOut,StdOut,L-_-R,L-C-R).
interpret(putchar,StdIn,StdIn,StdOut,[C|StdOut],L-C-R,L-C-R).

interpret(loop(_Instructions),StdIn,StdIn,StdOut,StdOut,L-0-R,L-0-R) :- !.
interpret(loop(Instructions),StdIn,StdInRes,StdOut,StdOutRes,L-E-R,BOut) :-
    E \== 0,
    interpret(Instructions,StdIn,StdIn1,StdOut,StdOut1,L-E-R,BNew),
    interpret(loop(Instructions),StdIn1,StdInRes,StdOut1,StdOutRes,BNew,BOut).

interpret([],StdIn,StdIn,StdOut,StdOut,Band,Band) :- !.
interpret([Inst|T],StdIn,ResStdIn,StdOut,ResStdOut,BandIn,ResBand) :-
    interpret(Inst,StdIn,StdIn1,StdOut,StdOut1,BandIn,Band2),
    interpret(T,StdIn1,ResStdIn,StdOut1,ResStdOut,Band2,ResBand).

:- use_module(library(lists)).
brainf(StdIn,Res,Program) :-
    string_to_list(StdIn,StdInCodes),
    string_to_list(Program,ProgramCodes),
    inst_list(Instructions,ProgramCodes,[]),
    interpret(Instructions,StdInCodes,_StdIn,[],ReversedStdOut,[]-0-[],_BandOut),
    reverse(ReversedStdOut, StdOut),
    string_to_list(Res, StdOut).