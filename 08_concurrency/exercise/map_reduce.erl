-module(map_reduce).
-export([start/1,stat_words/2, pars/2, reduce/3 ]).
start(Files) ->
Root_Pid = self(),
Num_Workers = length(Files),
Reduce_Pid = spawn(?MODULE, reduce, [#{}, Num_Workers, Root_Pid]),
lists:foreach(fun(Name) -> spawn(?MODULE, stat_words, [Reduce_Pid, Name]) end, Files), %for each el  
receive
{reply, Map} -> Map
after
2000 -> {error, no_reply}
end.

stat_words(Reduce_Pid, Name) ->
case file:read_file(Name) of
{error, _} -> io:format("File ~p not found~n", [Name]);
{ok, Text} -> pars(Text, Reduce_Pid)
end.

pars(Text, Reduce_Pid) -> Words = binary:split(Text, [<<" ">>, <<"\n">>], [global]),
Count_Words = lists:foldl(fun
(<<>>, Acc) -> Acc;
(Word, Acc) -> case maps:find(Word, Acc) of
{ok, Count} -> Acc#{Word => Count + 1};
error -> Acc#{Word => 1}
end
end, #{}, Words),
Reduce_Pid ! {count_words, Count_Words}.

reduce(State, Fl, Call_Pid) ->
if Fl > 0 ->
receive
{count_words, New_State} -> Sum = maps:fold( fun(Word, Count, Acc) ->
case maps:find(Word, Acc) of
{ok, Old_Count} -> Acc#{Word := Count + Old_Count};
error -> Acc#{Word => Count} end
end,
State, New_State),
reduce(Sum, Fl -1, Call_Pid)
after 1000 ->  reduce(State,Fl-1, Call_Pid)
end;
true -> Call_Pid ! {reply, State}
end.
