%%%-------------------------------------------------------------------
%%% @author aleyandro
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. Jun 2018 1:53 PM
%%%-------------------------------------------------------------------
-module(test_cessna_socket).

-author("amoein").

-behaviour(gen_server).

%% API
-export([start_link/1]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

-record(state, {socket}).

%%%===================================================================
%%% API
%%%===================================================================
start_link([Socket]) ->
    gen_server:start_link(?MODULE, [Socket], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([Socket]) ->
    {ok, #state{socket = Socket}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({tcp, _Socket, Data}, #state{socket = S} = State) ->
    gen_tcp:send(S, Data), 
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
