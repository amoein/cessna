-module(cessna_pool).

-author("amoein").

-behaviour(gen_server).

-include("cessna.hrl").

%% API
-export([start_link/2]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

-record(state, {option :: option(), listener_socket :: [map()]}).

%%%===================================================================
%%% API
%%%===================================================================
-spec start_link(Name :: atom(), Opts :: option()) -> {ok, pid()}.
start_link(Name, Opts) ->
    gen_server:start_link({local, Name}, ?MODULE, [Opts], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
-spec init(Option :: option()) -> {ok, #state{}}.
init([#option{ips = Ips,
              type = Type,
              port = Port,
              socket_option = SocketOpts,
              number_of_worker = WNum} =
          Option]) ->
    ?LOG_DEBUG("~nPool started~n", []),
    ListenerSockets =
        case Type of
            tcp ->
                [listen_tcp(Port, Ip, SocketOpts) || Ip <- Ips];
            ssl ->
                [listen_ssl(Port, Ip, SocketOpts) || Ip <- Ips]
        end,

    % WorkerReference =
    lists:foldl(fun(Socket, Acc) ->
                   MonitorRefs = [add_new_worker(Type, Socket, Option) || _ <- lists:seq(0, WNum)],
                   {ok, [#{socket => Socket, refs => MonitorRefs} | Acc]}
                end,
                [],
                ListenerSockets),
    {ok, #state{option = Option, listener_socket = ListenerSockets}}.

-spec handle_call(Request :: term(), From :: {pid(), term()}, State :: #state{}) ->
                     {reply, Reply :: term(), NewState :: #state{}}.
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

-spec handle_cast(Request :: term(), State :: #state{}) ->
                     {noreply, NewState :: #state{}}.
handle_cast({worker_start, PID}, State) ->
    ?LOG_DEBUG("~n listener worker start ~p ~n", [PID]),

    {noreply, State};
handle_cast({worker_error, PID, Reason}, State) ->
    ?LOG_ERROR("~n listener worker down ~p ~p~n", [PID, Reason]),

    {noreply, State};
handle_cast(info, State) ->
    ?LOG_INFO("~n ~p state => ~p", [?NOW(), State]),
    {noreply, State};
handle_cast(_Request, State) ->
    ?LOG_INFO("~n ~p state => ~p", [_Request, State]),
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
-spec add_new_worker(Type :: atom(), Socket :: atom(), Option :: option()) -> pid().
add_new_worker(tcp, Socket, Option) ->
    PID = proc_lib:spawn(cessna_worker_tcp, accept, [Socket, self(), Option]),
    erlang:monitor(process, PID);
%% TODO: ssl
add_new_worker(ssl, _Socket, _Option) ->
    %PID = proc_lib:spawn(cessna_worker_ssl, accept, [Socket, Option]),
    %erlang:monitor(process, PID).
    self().

%%%===================================================================
%%% start socket with ip

listen_tcp(Port, Ip, SocketOpts) ->
    {ok, Socket} = gen_tcp:listen(Port, [{ip, Ip} | SocketOpts]),
    Socket.

listen_ssl(Port, Ip, SocketOpts) ->
    {ok, Socket} = ssl:listen(Port, [{ip, Ip} | SocketOpts]),
    Socket.
