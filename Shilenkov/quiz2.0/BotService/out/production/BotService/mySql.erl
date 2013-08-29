%% Copyright
-module(mySql).
-author("alex").

-include("emysql.hrl").

-define(USER, "root").
-define(PASSWD,"Uero1phafi").
-define(DOMAIN, "xmpp.feelinhome.ru").
-define(DBNAME,"service").
-define(PORT,"3306").

%% API
-export([start/0,stop/0,applyChanges/2]).

start()->
	crypto:start(),
	spawn(application,start,[emysql]),
  	emysql:add_pool(db_pool, 1,	?USER, ?PASSWD, ?DOMAIN, ?PORT,	?DBNAME, utf8),
	io:format("pool initiated~ok",[]).

stop()->
	crypto:stop(),
	application:stop(emysql),
	emysql:remove_pool(db_pool).


applyChanges(From, Args) ->
	io:format("sqlPing",[]),
	%%emysql:execute(db_pool, <<"insert into testtab select null, 'тест'">>),
	emysql:execute(db_pool, lists:concat(["call test_ins('", binary:bin_to_list(From),"')"])).
	

getAllRecords()->
	{ _, _, _, Result, _ }= emysql:execute(db_pool,<<"select * from testtab">>),
	io:format("~n~p~n", [Result]).




