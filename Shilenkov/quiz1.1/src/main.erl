%% @author alex
%% @doc @todo Add description to main.


-module(main).

%-include_lib("bot_qwerasdf3e").
%% ====================================================================
%% API functions
%% ====================================================================
-export([main/0]).



%% ====================================================================
%% Internal functions
%% ====================================================================


main()->
	%spawn(mySql, init, []),
	mySql:init(),
	bot:start(),
	ok.



