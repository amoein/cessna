# Cessna

Cessna is a lightweight, TCP based socket acceptor pool for Erlang/OTP.

![CI](https://github.com/amoein/cessna/actions/workflows/ci.yaml/badge.svg)

## Goals

Cessna aims to provide a simple and lightweight approach to accepting TCP while you have heavy loads.
Mostly, It helps when you have live connections like a Chat or an AMPQ server. 
For example, try to imagine this scenario:
While your server has a 100K socket connection, it goes down (for some reason like deployment) and gets back up; you face heavy socket accept requests concurrently.

## Installation
- Pre Requirement:
    Use `Erlang/OTP +18`.

- Step 1: 
    Add `cessna` to `rebar.config`.
    ```erlang
    {deps, [
     ....
    {cessna,  {git,  "git@github.com:amoein/cessna.git"}},
     ....
    ]}.
     ```   
     
- Step 2:
    Make sure `cessna` starts in `your_app.erl`:
    ```erlang
    -module(your_app).
    
    start(_StartType, _StartArgs)  ->
    ....
    application:ensure_started(cessna),
    ...
    ```
    
- Step 3:

    ```bash
    rebar3 deps
    ```
    
## Usage

First of all you should include `cessna/include/cessna.hrl` in your module like this:

```erlang
-include_lib("cessna/include/cessna.hrl").
```

For add new acceptor you should use `cessna_sup:add_new_pool`:

```erlang
{ok,  _}  =  cessna_sup:add_new_pool(your_pool_name,  #option{}),
````
- Spec

    - `your_pool_name`:
        It's your acceptor pool name and it's `atom()`
        
    - `#option{}`:
       It's record define by cessne contains:
       ```erlang
       #option{type  =  tcp,
               port  =  8080,
               handler_module  =  your_server_socket,
               handler_func  =  your_server_function,
               number_of_worker  =  10,
               ips  =  [{0,0,0,0}],
               socket_option  =  [binary]}
       ```        

        - `handler_module` and ` handler_func`:

            There are simple `MFA`(minus part of `A`). The Arity part is an array contain `[Socket :: inet:socket(), PoolPID :: pid()]`, for example:
            ```erlang    
             -module(my_module).

             my_function([Socket , PID])->
             .....
             end.
            ```   
            To get socket messages, you **must** provide a listening loop in your function.
            For more handy usage, it's better to be used on starting `gen_serve` like this:
            ```erlang
            - module(handler_module).
            
            -behaviour(gen_server).

            start_link([Socket, PoolPID]) ->
                gen_server:start_link(?MODULE, [Socket, PoolPID], []).
            ```    


        - `type`:

            Currently it is `tcp`, but im ganna implement `ssl` soon.

        - `port`:

            `non_neg_integer` from 0 to 65535.

        - `number_of_worker`:

            Number of concurrent listener: `non_neg_integer` from 0

        - `ips`:

            Cessna can listen to multiple interface and ip for same port. array() ::
            [[ip_address()](https://www.erlang.org/doc/man/inet.html#type-ip_address)]

        - `socket_option`:

            Erlang socket option. array() ::
            [[socket_setopt()](https://www.erlang.org/doc/man/inet.html#type-socket_setopt)]

## Version History

- 0.2.0 (2 March 2023)
    - Remove extra code
    - Improve documentation
    - Improve test
  
- 0.1.0(8 JUl 2019)
    - Initial Release
  