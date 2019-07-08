%%%-------------------------------------------------------------------
%%% @author aleyandro
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. Jul 2018 11:41 AM
%%%-------------------------------------------------------------------
-module(cessna).
-author("aleyandro").

%% API
-export([add_listener/2,get_listener_info/1]).

-include("cessna.hrl").

-spec add_listener(atom(), option()) -> ok.
add_listener(Name, Opts) ->
  cessna_pool_sup:add_new_pool(Name ,Opts),
  ok.

-spec get_listener_info(atom()) -> ok.
get_listener_info(Name) ->
  cessna_pool:get_info(Name).