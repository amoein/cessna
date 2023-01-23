%%%-------------------------------------------------------------------
%%% @author aleyandro
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Jun 2018 3:29 PM
%%%-------------------------------------------------------------------
-author("aleyandro").

-define(NOW(), erlang:system_time(milli_seconds)).

-record(option,
        {type = tcp :: server_type(),
         handler_module :: atom(),
         handler_func :: atom(),
         auto_balance_worker = false :: boolean(),
         number_of_worker :: integer(),
         port :: integer(),
         socket_option = [] :: list(),
         notify_pool_per_accept = 200 :: integer(),
         ips = [] :: list()}).

-type option() :: #option{}.
-type server_type() :: tcp | ssl.
