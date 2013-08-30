%% Copyright
-module(server_app).
%-behaviour(application).
-author("alex").

%% API
-export([start/0, stop/1]).
-export([sc/0]).

start()->
  %application:start(exmpp),
  %application:start(emysql),
  server_sup:start_link(),
  io:format("server_app:started").

stop(_State)->ok.

sc()->
  ping_callback(),
  ok.


ping_callback()->
  io:format("LOGGG server_app~n",[]),
  server:ping_async("messagee~n"),
  ok.
