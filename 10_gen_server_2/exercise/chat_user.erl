
-module(chat_user).
-behavior(gen_server).

-export([start_link/0, add_message/3, get_messages/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(message=[]).

start_link() ->
gen_server:start_link(?MODULE, [], []).

init([]) ->
{ok, #state{}}.


add_message(Pid, UserName, Message) ->
gen_server:cast(Pid, {add_message, {UserName, Message}}), ok.

get_messages(Pid) ->
gen_server:call(Pid, get_messages).

%%get
handle_call(get_messages, _From,State) -> #state{messages = Messages} = State,
Reply = lists:reverse(Messages),
{reply, Reply, State}.

%%add
handle_cast({add_message, Data},State ) -> #state{messages = Messages} = State,
{noreply, State#state{messages = [Data | Messages]}}.


handle_info(_Request, State) ->
{noreply, State}.


terminate(_Reason, _State) ->ok.


code_change(_OldVersion, State, _Extra) ->{ok, State}.
