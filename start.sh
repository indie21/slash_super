rebar compile; erl -name 'master1@127.0.0.1'  -config scripts/sys.config -pa ebin/ deps/*/ebin/ -s slash_super_test start
