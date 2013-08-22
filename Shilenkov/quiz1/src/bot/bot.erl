%% Copyright
-module(bot).
-author("alex").
%% 
 -include("exmpp.hrl").
 -include("exmpp_client.hrl").

 -define(LOGIN, "exmppdebug@jabber.ru").
 -define(PASSWD, "data794613").

%% API
-export([start/0, start/2, stop/1]).
-export([init/2]).

start() ->

  start(?LOGIN, ?PASSWD).

start(JID, Password) ->
  spawn(?MODULE, init, [JID, Password]).

stop(EchoClientPid) ->
  EchoClientPid ! stop.

init(JID, Password) ->
  application:start(exmpp),

  MySession = exmpp_session:start(),

  [User, Server] = string:tokens(JID, "@"),
  MyJID = exmpp_jid:make(User, Server, random),

  exmpp_session:auth_basic_digest(MySession, MyJID, Password),

  {ok, _StreamId} = exmpp_session:connect_TCP(MySession, Server, 5222),
  session(MySession, MyJID, Password).

session(MySession, _MyJID, Password) ->
  try exmpp_session:login(MySession)
  catch
    throw:{auth_error, 'not-authorized'} ->
      io:format("Register~n", []),
      exmpp_session:register_account(MySession, Password),
      exmpp_session:login(MySession)
  end,
  exmpp_session:send_packet(MySession,
    exmpp_presence:set_status(
      exmpp_presence:available(), "ready")),
  bot_msg:loop(MySession).


