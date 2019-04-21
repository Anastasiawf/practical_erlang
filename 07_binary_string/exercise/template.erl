-module(template).
-export([parse/2, init/0]).

init() -> In = <<"User {{name}} won {{wins}} games and got {{points}} points">>,
Data = #{<<"name">> => "Kate", <<"wins">> => 55, <<"points">> => 777},
{In, Data}.

parse(Str, Data) when is_binary(Str) ->
Split_List = binary:split(Str, [<<"{{">>], [global]),
Change_List = lists:map(fun(Split_List_2) ->
case binary:split(Split_List_2, [<<"}}">>]) of
[Change_N] -> Change_N;
[Change | Rest] -> case maps:find(Change, Data) of
error -> Rest;
{ok, Value} when is_binary(Value) orelse is_list(Value) -> [Value, Rest];
{ok, Value} when is_integer(Value) -> [integer_to_binary(Value), Rest]
end
end
end,
Split_List),
unicode:characters_to_binary(Change_List).
