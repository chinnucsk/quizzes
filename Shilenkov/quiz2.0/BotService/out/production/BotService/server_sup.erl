%% Copyright
-module(server_sup).
-behaviour(supervisor).
-author("alex").

%% API
-export([start_link/0]).
-export([init/1]).

start_link()->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args)->
  io:format("server_sup"),
  {ok,{{one_for_one,5,10},
    [
    %%presence_sup,{?MODULE, start_link, [precence_sup]},
    %%                             permanent, 5000, supervisor,[?MODULE]},
      { server, {server,start_link,[]},
        permanent, 5000, worker, [server]}
  ]}}.

