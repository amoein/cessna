-module(cessna).

-author("amoein").

%% API
-export([add_listener/2, get_listener_info/1]).

-include("cessna.hrl").

-spec add_listener(atom(), option()) -> ok.
add_listener(Name, Opts) ->
    cessna_sup:add_new_pool(Name, Opts),
    ok.

-spec get_listener_info(atom()) -> ok.
get_listener_info(Name) ->
    cessna_pool:get_info(Name).
