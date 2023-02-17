-module(cessna_tcp_test_server).

-author("amoein").

-behaviour(gen_server).

-include("cessna.hrl").

%% API
-export([start_link/1]).
%% gen_server callbacks
-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

-record(state, {socket}).

%%%===================================================================
%%% API
%%%===================================================================
start_link([Socket, PoolPID]) ->
    gen_server:start_link(?MODULE, [Socket, PoolPID], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([Socket, _PoolPID]) ->
    {ok, #state{socket = Socket}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({tcp, Socket, Data}, #state{socket = Socket} = State) ->
    ?LOG_DEBUG("~nServer receive~nSocket: ~p ~nData: ~p~n", [Socket, Data]),
    gen_tcp:send(Socket, Data),
    {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
