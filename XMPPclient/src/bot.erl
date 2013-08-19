%% @author Shilenkov
%% @doc @todo Add description to bot.


-module(bot).

%% ====================================================================
%% API functions
%% ====================================================================
%%-export([start/0,stop/1,init/0]).
-compile(export_all).



%% ====================================================================
%% Internal functions
%% ====================================================================

start() ->
    spawn(?MODULE, init, []).

stop(EchoClientPid) ->
    EchoClientPid ! stop.


init() ->
    application:start(exmpp),
    %% Start XMPP session: Needed to start service (Like
    %% exmpp_stringprep):
    MySession = exmpp_session:start(),
    %% Create XMPP ID (Session Key):
    MyJID = exmpp_jid:make("user1", "Shilenkov", random),
    %% Create a new session with basic (digest) authentication:
    exmpp_session:auth_basic_digest(MySession, MyJID, "pass"),
    %% Connect in standard TCP:
    _StreamId = exmpp_session:connect_TCP(MySession, "localhost", 5280),
    session(MySession, MyJID).

%% We are connected. We now log in (and try registering if authentication fails)
session(MySession, _MyJID) ->
    %% Login with defined JID / Authentication:
    try exmpp_session:login(MySession)
    catch
	throw:{auth_error, 'not-authorized'} ->
	    %% Try creating a new user:
	    io:format("Register~n",[]),
	    %% In a real life client, we should trap error case here
	    %% and print the correct message.
	    exmpp_session:register_account(MySession, "pass"),
	    %% After registration, retry to login:
	    exmpp_session:login(MySession)
    end,
    %% We explicitly send presence:
    exmpp_session:send_packet(MySession,
			      exmpp_presence:set_status(
				exmpp_presence:available(), "Echo Ready")),
	io:format("EchoReady",[]),
    loop(MySession).

%% Process exmpp packet:
loop(MySession) ->
    receive
        stop ->
            exmpp_session:stop(MySession);
        %% If we receive a message, we reply with the same message
        Record = #received_packet{packet_type=message, raw_packet=Packet} ->
            io:format("~p~n", [Record]),
            echo_packet(MySession, Packet),
            loop(MySession);
        Record ->
            io:format("~p~n", [Record]),
            loop(MySession)
    end.

%% Send the same packet back for each message received
echo_packet(MySession, Packet) ->
    From = exmpp_xml:get_attribute(Packet, from, <<"unknown">>),
    To = exmpp_xml:get_attribute(Packet, to, <<"unknown">>),
    TmpPacket = exmpp_xml:set_attribute(Packet, from, To),
    TmpPacket2 = exmpp_xml:set_attribute(TmpPacket, to, From),
    NewPacket = exmpp_xml:remove_attribute(TmpPacket2, id),
    exmpp_session:send_packet(MySession, NewPacket).
