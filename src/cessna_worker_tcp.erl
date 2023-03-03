-module(cessna_worker_tcp).

-author("amoein").

-export([accept/3]).

-include("cessna.hrl").

-record(state, {pool_pid :: pid(), number_of_accept = 0 :: integer(), option :: option()}).

-spec accept(ListenerSocket :: inet:socket(), PoolPid :: pid(), Option :: option()) -> ok.
accept(ListenerSocket, PoolPid, Option) ->
    ?LOG_DEBUG("~n Acceptor Start ", []),
    gen_server:cast(PoolPid, {worker_start, self()}),

    accept_loop(ListenerSocket, #state{pool_pid = PoolPid, option = Option}).

%%%===================================================================
%%% Internal functions
%%%===================================================================
-spec accept_loop(inet:socket(), #state{}) -> ok.
accept_loop(Socket, State) ->
    #state{pool_pid = PID, option = #option{handler_module = Module, handler_func = Func}} =
        State,

    case inet_tcp:accept(Socket) of
        {ok, ClientSocket} ->
            {ok, NewProcess} = Module:Func([ClientSocket, PID]),
            ok = inet_tcp:controlling_process(ClientSocket, NewProcess),

            accept_loop(Socket, update_state(State));
        {error, Reason} ->
            gen_server:cast(PID, {worker_error, self(), Reason})
    end.

-spec update_state(#state{}) -> #state{}.
update_state(
    #state{
        number_of_accept = AN,
        option = #option{notify_pool_per_accept = NP},
        pool_pid = PID
    } =
        State
) ->
    ?LOG_DEBUG("AN : ~p , NP :~p", [AN, NP]),
    if
        (AN + 1) rem NP == 0 ->
            gen_server:cast(PID, {notify, self()});
        true ->
            ok
    end,

    State#state{number_of_accept = AN + 1}.
