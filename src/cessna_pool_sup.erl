%%%-------------------------------------------------------------------
%%% @author aleyandro
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Jun 2018 2:38 PM
%%%-------------------------------------------------------------------
-module(cessna_pool_sup).
-author("aleyandro").

-behaviour(supervisor).

%% API
-export([start_link/0]).
-export([add_new_pool/2]).

%% Supervisor callbacks
-export([init/1]).

-include("cessna.hrl").

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

-spec add_new_pool(atom(), option()) -> ok.
add_new_pool(Name, Opts) ->
    Spec = #{id=> Name,
             start =>{cessna_pool, start_link, [Name,Opts]},
             restart=>permanent,
             type => supervisor},
    supervisor:start_child(cessna_pool_sup, Spec).


start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    {ok, {{one_for_one, 0, 1}, []}}.

%%====================================================================
%% Internal functions
%%====================================================================
