%% @author Shilenkov
%% @doc @todo Add description to sevice.


-module(xmpp_sevice).

-include_lib("include/exmpp/exmpp.hrl").
-include_lib("include/exmpp/exmpp_client.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0, stop/1]).
-export([init/0]).

%% ====================================================================
%% Internal functions
%% ====================================================================

starrt()->
	spawn()
