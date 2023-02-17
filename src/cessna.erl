-module(cessna).

-author("amoein").

%% API
-export([add_listener/2]).

-include("cessna.hrl").

-spec add_listener(atom(), option()) -> ok.
add_listener(Name, Opts) ->
    cessna_sup:add_new_pool(Name, Opts),
    ok.
