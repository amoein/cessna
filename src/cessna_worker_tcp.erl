-module(cessna_worker_tcp).
-author("aleyandro").

-export([accept/3]).

-include("cessna.hrl").

-record(state, {pool_pid :: pid(),
                number_of_accept = 0 :: integer(),
                notify_per_accept :: integer(),
                option :: option()}).

-spec accept(inet:socket(), pid(), option()) -> ok.
accept(Socket, Pid, #option{notify_pool_per_accept = NNum} = Option) ->

    State = #state{pool_pid = Pid,
                   notify_per_accept = NNum,
                   option = Option},

    gen_server:cast(Pid, {worker_start, self()}),

    accept_loop(Socket, State).

%%%===================================================================
%%% Internal functions
%%%===================================================================
-spec accept_loop(inet:socket(), #state{}) -> ok.
accept_loop(Socket, #state{pool_pid = PID,
                           option = #option{handler_module = Module,
                                            handler_func = Func}} = State) ->

    case inet_tcp:accept(Socket) of
        {ok, Client_Socket} ->
            {ok, NewProcess} = Module:Func([Client_Socket, PID]),
            ok = inet_tcp:controlling_process(Client_Socket, NewProcess),
            StateNew = update_state(State),
            accept_loop(Socket, StateNew);

        {error, Reason} ->
            gen_server:cast(PID, {worker_error, self(), Reason})
    end.


update_state(#state{number_of_accept = AN,
                    notify_per_accept = NP,
                    pool_pid = PID} = State) ->

    case AN == NP of
        true ->
%%          ct:print("AN : ~p , NP :~p", [AN, NP]),
            gen_server:cast(PID, {notify, self()}),
            State#state{number_of_accept = 0};
        false ->
            State#state{number_of_accept = (AN + 1)}
    end.
