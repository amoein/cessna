.PHONY: clean ct format test

format:
	 ERL_AFLAGS="-enable-feature all" rebar3 format

test:
	ct_run -logdir logs

ct:
	rebar3 ct -v 100

clean:
	rebar3 clean