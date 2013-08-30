-module(kv).

-behaviour(gen_server).

-export([start/0
         , set/2
         , get/1]).

%%gen_server callbacks
-export([init/1
         , handle_call/3
         , handle_cast/2
         , handle_info/2
         , terminate/2
         , code_change/3]).

start() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).
set(K, V) ->
    gen_server:call({global, ?MODULE}, {set, K, V}).
get(K) ->
    gen_server:call({global, ?MODULE}, {get, K}).

init([]) ->
    State = dict:new(),
    {ok, State}.
handle_call({set, K, V}, _From, State) ->
    Update = dict:store(K, V, State),
    {reply, ok, Update};
handle_call({get, K}, _From, State) ->
    Ack = dict:find(K, State),
    {reply, Ack, State};
handle_call(_Message, _From, State) ->
    {reply, undefined, State}.

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Msg, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVersion, State, _Extra) -> {ok, State}.
