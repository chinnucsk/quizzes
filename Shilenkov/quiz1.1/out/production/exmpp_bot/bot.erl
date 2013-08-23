%% Copyright
-module(bot).
-author("alex").

-include("include/exmpp/exmpp.hrl").
-include("include/exmpp/exmpp_client.hrl").

%% API
-export([start/0, start/2, stop/1]).
-export([init/2]).

start() ->
  start("exmppdebug@jabber.ru", "data794613").

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
      io:format("Register~n",[]),
      exmpp_session:register_account(MySession, Password),
      exmpp_session:login(MySession)
  end,
  exmpp_session:send_packet(MySession,
    exmpp_presence:set_status(
      exmpp_presence:available(), "Echo Ready")),
  loop(MySession).


loop(MySession) ->
  receive
    stop ->
      exmpp_session:stop(MySession);

  %% If we receive a message, we reply with the same message
    Record = #received_packet{packet_type=message,
      raw_packet=Packet,
      type_attr=Type} when Type =/= "error" ->
      io:format("Received Message stanza:~n~p~n~n", [Record]),
      echo_packet(MySession, Packet),
      loop(MySession);
  %% If we receive a presence stanza, handle it

    Record when Record#received_packet.packet_type == 'presence' ->
      io:format("Received Presence stanza:~n~p~n~n", [Record]),
      handle_presence(MySession, Record, Record#received_packet.raw_packet),
      loop(MySession);
    Record ->
      io:format("Received a stanza:~n~p~n~n", [Record]),
      loop(MySession)
  end.

%% Send the same packet back for each message received
echo_packet(MySession, Packet) ->
  From = exmpp_xml:get_attribute(Packet, <<"from">>, <<"unknown">>),
  To = exmpp_xml:get_attribute(Packet, <<"to">>, <<"unknown">>),
  TmpPacket = exmpp_xml:set_attribute(Packet, <<"from">>, To),
  TmpPacket2 = exmpp_xml:set_attribute(TmpPacket, <<"to">>, From),
  NewPacket = exmpp_xml:remove_attribute(TmpPacket2, <<"id">>),
  exmpp_session:send_packet(MySession, NewPacket).

handle_presence(Session, Packet, _Presence) ->
  case exmpp_jid:make(_From = Packet#received_packet.from) of
    JID ->
      case _Type = Packet#received_packet.type_attr of
        "available" ->
          %% handle presence availabl
          ok;
        "unavailable" ->
          %% handle presence unavailable
          ok;
        "subscribe" ->
          presence_subscribed(Session, JID),
          presence_subscribe(Session, JID);
        "subscribed" ->
          presence_subscribed(Session, JID),
          presence_subscribe(Session, JID)
      end
  end.

presence_subscribed(Session, Recipient) ->
  Presence_Subscribed = exmpp_presence:subscribed(),
  Presence = exmpp_stanza:set_recipient(Presence_Subscribed, Recipient),
  exmpp_session:send_packet(Session, Presence).

presence_subscribe(Session, Recipient) ->
  Presence_Subscribe = exmpp_presence:subscribe(),
  Presence = exmpp_stanza:set_recipient(Presence_Subscribe, Recipient),
  exmpp_session:send_packet(Session, Presence).