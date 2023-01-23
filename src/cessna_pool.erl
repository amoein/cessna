%%%-------------------------------------------------------------------
%%% @author aleyandro
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Jun 2018 2:53 PM
%%%-------------------------------------------------------------------
-module(cessna_pool).

-author("aleyandro").

-behaviour(gen_server).

%% API
-export([start_link/2, get_info/1]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

-include("cessna.hrl").

-record(state,
        {option :: option(),
         auto :: boolean(),
         open_connection = 0 :: integer(),
         workers = #{},
         lisener_socket :: [inet:socket()]}).
-record(worker_state,
        {count = 0 :: integer(),
         rate = 0 :: float(),
         tilt = none :: none | up | down,
         last = 0 :: integer()}).

%%%===================================================================
%%% API
%%%===================================================================
get_info(Name) ->
    case whereis(Name) of
        undefined ->
            undefined;
        PID ->
            gen_server:cast(PID, info)
    end.

-spec start_link(Name :: atom(), Opts :: option()) -> {ok, pid()}.
start_link(Name, Opts) ->
    gen_server:start_link({local, Name}, ?MODULE, [Opts], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([#option{ips = []} = Option]) ->
    #option{type = Type,
            port = Port,
            socket_option = SocketOpts,
            auto_balance_worker = Auto,
            number_of_worker = WNum} =
        Option,

    {ok, Socket} =
        case Type of
            tcp ->
                listen_tcp(Port, SocketOpts);
            ssl ->
                listen_ssl(Port, SocketOpts);
            _ ->
                error(undefinde_protocol)
        end,

    case Auto of
        true ->
            PID = add_new_worker(Type, Socket, Option),
            [PID];
        false ->
            [add_new_worker(Type, Socket, Option) || _ <- lists:seq(0, WNum)]
    end,

    {ok, #state{option = Option, lisener_socket = [Socket]}};
init([#option{ips = Ips} = Option]) ->
    #option{type = Type,
            port = Port,
            socket_option = SocketOpts,
            auto_balance_worker = Auto,
            number_of_worker = WNum} =
        Option,

    Sockets =
        case Type of
            tcp ->
                [listen_tcp(Port, Ip, SocketOpts) || Ip <- Ips];
            ssl ->
                [listen_ssl(Port, Ip, SocketOpts) || Ip <- Ips];
            _ ->
                error(undefinde_protocol)
        end,

    if Auto == true ->
           [add_new_worker(Type, Socket, Option) || Socket <- Sockets];
       true ->
           F = fun(Socket) -> [add_new_worker(Type, Socket, Option) || _ <- lists:seq(0, WNum)] end,
           [F(Item) || Item <- Sockets]
    end,

    {ok, #state{option = Option, lisener_socket = Sockets}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({worker_start, PID}, #state{workers = WRS} = State) ->
    {noreply, State#state{workers = maps:put(PID, #worker_state{}, WRS)}};
handle_cast({worker_error, PID, Reason}, #state{workers = WRS} = State) ->
    io:format("~n listener worker down ~p ~p~n", [PID, Reason]),

    {noreply, State#state{workers = maps:remove(PID, WRS)}};
handle_cast({notify, PID}, #state{open_connection = OC, workers = WRS} = State) ->
    #worker_state{count = Count,
                  rate = Rate,
                  last = Last} =
        maps:get(PID, WRS, #worker_state{}),

    %%TODO :auto balance worker
    %% check time for accept rate per time
    NewRate = (?NOW() - Last) / 1000,
    NewTilt =
        if Rate == NewRate ->
               none;
           Rate < NewRate ->
               up;
           Rate > NewRate ->
               down
        end,
    NewWorkerState =
        #worker_state{count = Count + 1,
                      rate = NewRate,
                      tilt = NewTilt,
                      last = ?NOW()},

    NewState =
        State#state{open_connection = OC + State#state.option#option.notify_pool_per_accept,
                    workers = maps:put(PID, NewWorkerState, WRS)},
    {noreply, NewState};
handle_cast(info, State) ->
    io:format("~n ~p state => ~p", [?NOW(), State]),
    {noreply, State};
handle_cast(_Request, State) ->
    io:format("~n ~p state => ~p", [_Request, State]),
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
add_new_worker(Type, Socket, Option) ->
    case Type of
        tcp ->
            PID = proc_lib:spawn(cessna_worker_tcp, accept, [Socket, self(), Option]),
            erlang:monitor(process, PID);
        ssl ->
            PID = proc_lib:spawn(cessna_worker_ssl, accept, [Socket, self(), Option]),
            erlang:monitor(process, PID)
    end.

%%%===================================================================
%%% start socket with ip

listen_tcp(Port, Ip, SocketOpts) ->
    {ok, Socket} = gen_tcp:listen(Port, [{ip, Ip} | SocketOpts]),
    Socket.

listen_ssl(Port, Ip, SocketOpts) ->
    {ok, Socket} = ssl:listen(Port, [{ip, Ip} | SocketOpts]),
    Socket.

%%%===================================================================
%%% start socket without ip
listen_tcp(Port, SocketOpts) ->
    {ok, Socket} = gen_tcp:listen(Port, SocketOpts),
    Socket.

listen_ssl(Port, SocketOpts) ->
    {ok, Socket} = ssl:listen(Port, [SocketOpts]),
    Socket.
