%% @author alex
%% @doc @todo Add description to bot_msg.


-module(bot_msg).
 -include("exmpp.hrl").
 -include("exmpp_client.hrl").
%% ====================================================================
%% API functions
%% ====================================================================
-export([loop/1, send_packet/2]).



%% ====================================================================
%% Internal functions
%% ====================================================================

loop(MySession) ->
  receive
    stop ->
      exmpp_session:stop(MySession);

  %% If we receive a message, we reply with the same message
    Record = #received_packet{packet_type = message,
      raw_packet = Packet,
      type_attr = Type} when Type =/= "error" ->
      io:format("Received Message stanza:~n~p~n~n", [Record]),
      send_packet(MySession, Packet),
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


send_packet(MySession, Packet) ->
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

