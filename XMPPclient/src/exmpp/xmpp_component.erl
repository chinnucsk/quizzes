%% @author Shilenkov
%% @doc @todo Add description to xmpp_component.


-module(xmpp_component).

%% ====================================================================
%% API functions
%% ====================================================================
-include_lib("exmpp.hrl").
-include_lib("exmpp_client.hrl").

-export([start/0, stop/1]).
-export([init/0]).

start() ->
    spawn(?MODULE, init, []).

stop(EchoComPid) ->
    EchoComPid ! stop.

init() ->
    application:start(exmpp),
    XmppCom = exmpp_component:start(),
    exmpp_component:auth(XmppCom, "ejabberd@localhost", "public"),
    _StreamId = exmpp_component:connect(XmppCom, "localhost", 5280),
    exmpp_component:handshake(XmppCom),
    loop(XmppCom).

loop(XmppCom) ->
    receive
        stop ->
            exmpp_component:stop(XmppCom);
        %% If we receive a message, we reply with the same message
        Record = #received_packet{packet_type=message, raw_packet=Packet} ->
            io:format("~p~n", [Record]),
            echo_packet(XmppCom, Packet),
            loop(XmppCom);
        Record ->
            io:format("~p~n", [Record]),
            loop(XmppCom)
    end.

%% Send the same packet back for each message received
echo_packet(XmppCom, Packet) ->
    From = exmpp_xml:get_attribute(Packet, <<"from">>, <<"unknown">>),
    To = exmpp_xml:get_attribute(Packet, <<"to">>, <<"user1@Shilenkov">>),
    TmpPacket = exmpp_xml:set_attribute(Packet, <<"from">>, To),
    TmpPacket2 = exmpp_xml:set_attribute(TmpPacket, <<"to">>, From),
    NewPacket = exmpp_xml:remove_attribute(TmpPacket2, <<"id">>),
    exmpp_component:send_packet(XmppCom, NewPacket).