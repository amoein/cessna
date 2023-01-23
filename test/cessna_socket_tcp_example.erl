%%%-------------------------------------------------------------------
%%% @author aleyandro
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Jun 2018 10:41 AM
%%%-------------------------------------------------------------------
-module(cessna_socket_tcp_example).

-author("aleyandro").

-behaviour(gen_server).

%% API
-export([start_link/1]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

-record(state, {socket, pool_pid}).

%%%===================================================================
%%% API
%%%===================================================================
start_link([Socket, PoolPID]) ->
    gen_server:start_link(?MODULE, [Socket, PoolPID], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([Socket, PoolPID]) ->
    {ok, #state{socket = Socket, pool_pid = PoolPID}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({tcp, Socket, Data}, #state{socket = S} = State) ->
    Print_data = binary_to_list(Data),
    {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
