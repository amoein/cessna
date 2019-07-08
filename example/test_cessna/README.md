test_cessna
=====

An OTP application for test cessna socket acceptor


Build
-----

    $ rebar3 compile
    $ rebar3 release
    $ rebar3 tar
    
RUN
---    
    $ cd _build/default/rel/test_cessna/bin
    $ ./test_cessna console

DEPLOY
---
    $ scp  _build/default/rel/test_cessna/*.tar _your_server_
    
CONFIG:
  *  open config/app.conf    
  
```erlang
[{test_cessna, [{workers, N},% N worker acceptor per ip 
                {ips, [       % list of ips want to lesten
                       {1, 2, 3, 3}             
                      ]}]}].
```
 