# Cessna

Minimal Socket Acceptor

## Usage

Put in `rebar.config`.

    	{deps, [
    	 ....
    	{cessna,  {git,  "git@github.com:amoein/cessna.git"}},
    	 ....
    	]}.


Add this to `your_app.erl` on `start` method:

    -include_lib("cessna/include/cessna.hrl").

    start(_StartType, _StartArgs)  ->

    ....
    application:ensure_started(cessna),
    Option  = #option{type  =  tcp,
                      port  =  8080,
                      handler_module  =  your_server_socket,
                      handler_func  =  your_server_function,
                      number_of_worker  =  10,
                      ips  =  [{0,0,0,0}],
                      socket_option  =  [binary]},

    {ok,  _}  =  cessna_sup:add_new_pool(your_pool_name,  Option),

    ....

## Options

### `handler_module` ,` handler_func`:

There are simple `MFA` minus part of `A` , the Arity part is an array contain `[Socket :: inet:socket(), PoolPID :: pid()]`, for example:

    -module(my_module).
    
    my_function([Socket , PID])->
    .....
    end.

It's better to be used on starting of gen_server with it:

    -behaviour(gen_server).
    
    start_link([Socket, PoolPID]) ->
    	gen_server:start_link(?MODULE, [Socket, PoolPID], []).


### `type`:

Currently it is `tcp`, but im ganna implement `ssl` soon.

### `port`:

`non_neg_integer` from 0 to 65535.

### `number_of_worker`:

Number of concurrent listener: `non_neg_integer` from 0

### `ips`:

Cessna can listen to multiple interface and ip for same port. array() ::
[[ip_address()](https://www.erlang.org/doc/man/inet.html#type-ip_address)]

### `socket_option`:

Erlang socket option. array() ::
[[socket_setopt()](https://www.erlang.org/doc/man/inet.html#type-socket_setopt)]
