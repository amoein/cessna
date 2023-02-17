-module(cessna_sup).

-author("amoein").

-behaviour(supervisor).

%% API
-export([start_link/0, add_new_pool/2]).
%% Supervisor callbacks
-export([init/1]).

-include("cessna.hrl").

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

-spec add_new_pool(Name :: atom(), Opts :: option()) -> {ok, pid()} | {error, term()}.
add_new_pool(Name, Opts) ->
    PoolSpec =
        #{
            id => Name,
            start => {cessna_pool, start_link, [Name, Opts]},
            restart => permanent,
            type => supervisor
        },
    supervisor:start_child(?MODULE, PoolSpec).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id, StartFunc, Restart, Shutdown, Type, Modules}
init([]) ->
    {ok, {{one_for_one, 0, 1}, []}}.
