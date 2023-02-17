.PHONY: clean ct format format-check dialyzer test

format:
	 ERL_AFLAGS="-enable-feature all" rebar3 format
	 rebar3 fmt

format-check:	 
	 ERL_AFLAGS="-enable-feature all" rebar3 format -v

ct:
	rebar3 ct -v 100 --cover

clean:
	rebar3 clean

dialyzer:
	rebar3 dialyzer

test:
	ct_run -logdir logs	