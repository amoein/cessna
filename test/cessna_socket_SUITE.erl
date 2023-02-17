-module(cessna_socket_SUITE).

-author("amoein").

-include_lib("common_test/include/ct.hrl").

-include("cessna.hrl").

%% Test server callbacks
-export([suite/0, all/0, init_per_suite/1, end_per_suite/1]).
%% Test cases
-export([tcp_test/1]).

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
        #option{
            type = tcp,
            port = 8080,
            ips = [{127, 0, 0, 1}],
            handler_module = cessna_tcp_test_server,
            handler_func = start_link,
            number_of_worker = 10,
            notify_pool_per_accept = 10,
            socket_option = [{mode, binary}, {reuseaddr, true}, {keepalive, false}]
        },
    cessna:add_listener(test1, Option),
    [cessna_tcp_test_client:start_link() || _ <- lists:seq(1, 5)],
    timer:sleep(10000),
    ok.
