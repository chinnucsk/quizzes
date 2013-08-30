%% Copyright
-module(service_callbacks).
-author("alex").

%% API
-export([handle_cast/2]).



%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

handle_cast({start_modules}, State)->
  io:format("service_callbacks: handle_cast{startmodules}"),
  {noreply, State}.
