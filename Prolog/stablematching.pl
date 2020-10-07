
% 6602848 Manlin Guo
% use case : findStableMatch("coop_e_10x10.csv", "coop_s_10x10.csv").
% basic helper functions

cmpToList([], _) :- fail.

cmpToList([HEAD | TAIL], V) :- not(V = HEAD),
                               cmpToList(TAIL, V).

cmpToList([HEAD|_], V) :- V = HEAD, true.

findByKey([ [] | _ ], _, _) :- fail.

findByKey([ [First | Second] | _ ], First , Second) :- !.

findByKey([ [_ | _] | Others], Key, F) :- findByKey(Others, Key, F).

findByValue([], _, _) :- fail.

findByValue([ [] | _ ], _, _) :- fail.

findByValue([ [First | Second] | _ ], S, F) :- cmpToList(Second, S),
                                               appendList([First], [], F), !.

findByValue([ [_ | Second] | Others], S, F) :- not(cmpToList(Second, S)),
                                                   findByValue(Others, S, T),
                                                   appendList(T, [], F), !.
% assume the longest list is 1000000000
indexOf([], _, 1000000000) :- !.
indexOf([Element | _], Element, 0) :- !.
indexOf([ _ | Tail], Element, Index) :- indexOf(Tail, Element, IndexOfNext),
                                        Index is IndexOfNext + 1.

appendList([], Y, Y).
appendList([A|B], Y, [A|W]) :- appendList(B, Y, W).

appendToMatches(Matches, Pair, L) :- append(Matches, [Pair], L).

getListHead([], _) :- fail.
getListHead([Head | _], Head).

getListTail([], _) :- fail.
getListTail([_|Tail], Tail).

replace(_, _, [], []).
replace(O, R, [O|T], [R|T2]) :- replace(O, R, T, T2).
replace(O, R, [H|T], [H|T2]) :- H \= O,
                                replace(O, R, T, T2).

% stable matching help functions

matched(Person, Matches) :- not(findByValue(Matches, Person, _)),
                            findByKey(Matches, Person, _), !.
matched(Person, Matches) :- findByValue(Matches, Person, _), !.

isMyPreferenceList(Head, [Head | _]) :- true.

findPreferedStudent(_, [], _) :- fail. 

findPreferedStudent(Employer, [Head | _], Student) :- isMyPreferenceList(Employer, Head),
                                                      getListTail(Head, Students),
                                                      getListHead(Students, Student), !.

findPreferedStudent(Employer, [Head | Tail], Student) :- not(isMyPreferenceList(Employer, Head)),
                                                         findPreferedStudent(Employer, Tail, Student).

addToMatches(Employer, Student, Matches, NewMatches) :- appendList(Matches, [[Employer, Student]], NewMatches).

removeFromMatches(Matches, Pair, L) :- delete(Matches, Pair, L).

getCurrentEmployer(Student, Matches, Employer) :- findByValue(Matches, Student, L),
                                                  getListHead(L, Employer).


getPreferenceListByEmployer(Employer, [Preferences | OtherPreferences ], SubList) :- not(isMyPreferenceList(Employer, Preferences)),
                                                                                     getPreferenceListByEmployer(Employer, OtherPreferences, SubList), !.

getPreferenceListByEmployer(Employer, [Preferences | _ ], Preferences) :- isMyPreferenceList(Employer, Preferences), !.                                                                         

removeFromEmployersPreference(Employer, Student, EmployersPreferences, NewEmployerPreferences) :- getPreferenceListByEmployer(Employer, EmployersPreferences, Preferences),
                                                                                                  delete(Preferences, Student, L2),
                                                                                                  replace(Preferences, L2, EmployersPreferences, NewEmployerPreferences).
prefered(_, _, _, []) :- fail.

prefered(Student, E1, E2, [Preferences | _]) :- isMyPreferenceList(Student, Preferences),
                                                getListTail(Preferences, L),
                                                indexOf(L, E1, Index1),
                                                indexOf(L, E2, Index2),
                                                Index1 < Index2, !.

prefered(Student, E1, E2, [Preferences | OtherPreferences]) :- not(isMyPreferenceList(Student, Preferences)),
                                                               prefered(Student, E1, E2, OtherPreferences).

replaceMatch(Student, Eold, Enew, Matches, NewMatches) :- removeFromMatches(Matches, [Eold, Student], L),
                                                          addToMatches(Enew, Student, L, NewMatches).

getFirstUnmatched([], _, _) :- fail.

getFirstUnmatched([EmployerPreference | _ ], Matches, E) :- getListHead(EmployerPreference, Employer),
                                                                              not(matched(Employer, Matches)),
                                                                              appendList([Employer], [], E), !.

getFirstUnmatched([EmployerPreference | EmployersPreferences], Matches, E) :- getListHead(EmployerPreference, Employer),
                                                                              matched(Employer, Matches),
                                                                              getFirstUnmatched(EmployersPreferences, Matches, E).

% main engine
% example of employer prference structure [[Thales,Olivia,Jackson,Sophia], [Canada Post,Sophia,Jackson,Olivia], [Cisco,Olivia,Sophia,Jackson]]
% example of student prference structure [[Olivia,Thales,Canada Post,Cisco], [Jackson,Thales,Canada Post,Cisco], [Sophia,Cisco,Thales,Canada Post]]

offer(E, Matches, _, _, _, _) :-
  matched(E, Matches).

offer(E, Matches, EmployersPreference, StudentsPreference, NewEmployersPrference, NewMatches) :-
  not(matched(E, Matches)),
  findPreferedStudent(E, EmployersPreference, Student),
  evaluate(E, Student, Matches, EmployersPreference, StudentsPreference, NewEmployersPrference, NewMatches).

offer(E, Matches, _, _, _, _) :- 
  matched(E, Matches).

evaluate(E, Student, Matches, EmployersPreference, _, NewEmployersPrference, NewMatches) :-
  not(matched(Student, Matches)),
  addToMatches(E, Student, Matches, NewMatches),
  removeFromEmployersPreference(E, Student, EmployersPreference, NewEmployersPrference).

evaluate(E, Student, Matches, EmployersPreference, StudentsPreference, NewEmployersPrference, NewMatches) :-
  matched(Student, Matches),
  getCurrentEmployer(Student, Matches, E1),
  prefered(Student, E, E1, StudentsPreference),
  replaceMatch(Student, E1, E, Matches, L1),
  removeFromEmployersPreference(E, Student, EmployersPreference, L2),
  offer(E1, L1, L2, StudentsPreference, NewEmployersPrference, NewMatches).

evaluate(E, Student, Matches, EmployersPreference, StudentsPreference, NewEmployersPrference, NewMatches) :-
  matched(Student, Matches),
  getCurrentEmployer(Student, Matches, E1),
  not(prefered(Student, E, E1, StudentsPreference)),
  removeFromEmployersPreference(E, Student, EmployersPreference, L2),
  offer(E, Matches, L2, StudentsPreference, NewEmployersPrference, NewMatches).

stableMatchingInternal(EmployersPreferences, _, Matches, NewMatches) :-
  appendList(Matches, [], Lmatches),
  not(getFirstUnmatched(EmployersPreferences, Lmatches, _)),
  appendList(Matches, [], NewMatches), !.

stableMatchingInternal(EmployersPreferences, StudentsPreference, Matches, NewMatches) :-
  appendList(Matches, [], Lmatches),
  getFirstUnmatched(EmployersPreferences, Lmatches, E),
  getListHead(E, E1),
  offer(E1, Lmatches, EmployersPreferences, StudentsPreference, T, M),
  stableMatchingInternal(T, StudentsPreference, M, NewMatches).

read_file(Stream,[], ListOfList, NewList) :-
  at_end_of_stream(Stream),
  append(ListOfList, [], NewList).

read_file(Stream,[X|L], ListOfList, NewList) :-
  not(at_end_of_stream(Stream)),
  read_line_to_codes(Stream,Codes),
  atom_chars(X, Codes),
  split_string(X, ",", "", ListOfItems),
  appendList(ListOfList, [], P),
  appendList([ListOfItems], P, T),
  read_file(Stream,L, T, NewList),!.

readFileToList(File, NewList) :-
  open(File, read, Str),
  read_file(Str,_, [], NewList), !.

writeListToFile([], _).

writeListToFile([X|L], Stream) :-
  write(Stream, X), nl(Stream),
  writeListToFile(L, Stream).

stableMatching(EmployersPreference, StudentsPreference, Matches) :-
  stableMatchingInternal(EmployersPreference, StudentsPreference, [], Matches), 
  write(Matches), !.

findStableMatch(Efile, Sfile) :-
  readFileToList(Efile, EmployersPreference),
  readFileToList(Sfile, StudentsPreference),
  stableMatching(EmployersPreference, StudentsPreference, Matches),
  open("matches_prolog_10x10.csv", write, Stream),
  writeListToFile(Matches, Stream),
  close(Stream).