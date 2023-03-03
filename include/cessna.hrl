-author("amoein").

-define(NOW(), erlang:system_time(milli_seconds)).

-record(option, {
    type = tcp :: server_type(),
    handler_module :: atom(),
    handler_func :: atom(),
    number_of_worker :: integer(),
    port :: integer(),
    socket_option = [] :: list(),
    notify_pool_per_accept = 200 :: integer(),
    ips = [{127, 0, 0, 1}] :: list()
}).

-type option() :: #option{}.
% TODO: ssl
-type server_type() :: tcp.

-ifdef(TEST).

-define(LOG_ERROR(Format, Args), ct:print(default, 10, Format, Args)).
-define(LOG_INFO(Format, Args), ct:print(default, 30, Format, Args)).
-define(LOG_DEBUG(Format, Args), ct:print(default, 50, Format, Args)).

-else.

-define(LOG_ERROR(Format, Args), logger:log(error, Format, Args)).
-define(LOG_INFO(Format, Args), logger:log(info, Format, Args)).
-define(LOG_DEBUG(Format, Args), logger:log(debug, Format, Args)).

-endif.
