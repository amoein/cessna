-module(cessna_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

-spec start(_StartType :: tuple(), _StartArgs :: tuple()) ->
    {ok, pid()} | {error, tuple()}.
start(_StartType, _StartArgs) ->
    cessna_sup:start_link().

-spec stop(_State :: tuple()) -> ok.
stop(_State) ->
    ok.
