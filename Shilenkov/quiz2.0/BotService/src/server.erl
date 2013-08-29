%% Copyright
-module(server).
-behaviour(gen_server).
-author("alex").

-define(CALLMODULE, service_callbacks).

%% API
-export([start_link/0]).
-export([start_modules/0, ping_callback/0, ping_async/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([msg/0]).

%%@doc init
start_link()->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []). %%service_callbacks, [], []).

 start_modules()->
   gen_server:call(?CALLMODULE, start_modules).

init([]) ->
  io:format("serverStarted~n",[]),
  ets:new(?MODULE,[]),
  {ok, msg()}.

ping_async(Msg)->
  gen_server:cast(?MODULE, {cast_req, Msg}).


ping_callback()->
   gen_server:call(?MODULE, ping_callback).

msg()->
  io:format("msg func in server~n",[]).



handle_info(connect, State)->{noreply, State}.

handle_cast({cast_req, Param}, State)->
  io:format("async !!1111 param= ~p~n",[Param]),
  {noreply, State}.

handle_call(ping_callback, _From, State)->
  io:format("!!!!!!!!!!!!!",[]),
  {noreply, State}.




terminate(_Reason, State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.