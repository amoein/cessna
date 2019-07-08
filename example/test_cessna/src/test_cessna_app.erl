%%%-------------------------------------------------------------------
%% @doc test_cessna public API
%% @end
%%%-------------------------------------------------------------------

-module(test_cessna_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-include_lib("cessna/include/cessna.hrl").
%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    application:ensure_started(cessna),
    {ok, IPS} = application:get_env(test_cessna, ips),
    {ok, Workers} = application:get_env(test_cessna, workers),
    Option = #option{type = tcp,
                     port = 5222,
                     handler_module = test_cessna_socket,
                     handler_func = start_link,
                     auto_balance_worker = false,
                     number_of_worker = Workers,
                     notify_pool_per_accept = 10,
                     ips = IPS,
                     socket_option = [binary, {keepalive, false}, {reuseaddr, true}]
                    },
    {ok, _P} = cessna_pool_sup:add_new_pool(test1, Option),

    test_cessna_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
