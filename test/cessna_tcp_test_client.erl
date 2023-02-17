-module(cessna_tcp_test_client).

-author("aleyandro").

-behaviour(gen_server).

-include("cessna.hrl").

%% API
-export([start_link/0]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

-record(state, {socket :: inet:socket(), packet_count = 0 :: integer()}).

%%%===================================================================
%%% API
%%%===================================================================
-spec start_link() -> {ok, pid()} | ignore | {error, term()}.
start_link() ->
    gen_server:start_link(?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
-spec init(term()) -> {ok, #state{}}.
init([]) ->
    gen_server:cast(self(), st),
    {ok, #state{}}.

-spec handle_call(term(), {pid(), term()}, #state{}) -> {reply, term(), #state{}}.
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

-spec handle_cast(term(), #state{}) -> {noreply, #state{}}.
handle_cast(st, State) ->
    {ok, Socket} = gen_tcp:connect("127.0.0.1", 8080, [{mode,binary}]),    
    ?LOG_DEBUG("New Socket ~p", [Socket]),
    {noreply, State#state{socket = Socket}};
    
handle_cast(_Request, State) ->
    {noreply, State}.

-spec handle_info(term(), #state{}) -> {noreply, #state{}}.
handle_info(_Info, State) ->    
    {noreply, State}.

-spec terminate(term(), #state{}) -> ok.
terminate(_Reason, _State) ->    
    ok.

-spec code_change(term(), #state{}, term()) -> {ok, #state{}}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
