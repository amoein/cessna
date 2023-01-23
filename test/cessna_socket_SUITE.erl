%%%-------------------------------------------------------------------
%%% @author aleyandro
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Jun 2018 4:07 PM
%%%-------------------------------------------------------------------
-module(cessna_socket_SUITE).

-author("aleyandro").

-include_lib("common_test/include/ct.hrl").

-include("cessna.hrl").

%% Test server callbacks
-export([suite/0, all/0, init_per_suite/1, end_per_suite/1]).
%% Test cases
-export([tcp_test/1, loop_info/1]).

suite() ->
    [].

init_per_suite(Config) ->
    application:ensure_started(cessna),
    Config.

end_per_suite(_Config) ->
    ok.

all() ->
    [tcp_test].

tcp_test(_Config) ->
    Option =
        #option{type = tcp,
                port = 8080,
                ips = [{127, 0, 0, 1}],
                handler_module = cessna_socket_tcp_example,
                handler_func = start_link,
                auto_balance_worker = false,
                number_of_worker = 10,
                notify_pool_per_accept = 10,
                socket_option = [binary, {keepalive, true}, {reuseaddr, true}]},

    cessna:add_listener(test1, Option),

    [cessna_socket_tcp_client_example:start_link() || _ <- lists:seq(1, 10000)],

    erlang:spawn(?MODULE, loop_info, [test1]),
    timer:sleep(10000000),
    ok.

loop_info(Name) ->
    case cessna:get_listener_info(Name) of
        undefined ->
            ok;
        _ ->
            timer:sleep(10000),
            loop_info(Name);
        true ->
            ok
    end.
