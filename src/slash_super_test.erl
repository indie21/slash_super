-module(slash_super_test).
-compile([export_all]).

-include("def.hrl").

start() ->
    mnesia:start(),
    application:start(slash_cluster),
    super = slash_cluster:init_table(super, record_info(fields, super), bag),
    slash_super_app:start(),
    %% observer:start(),
    io:format("~p~n", [ets:tab2list(super)]),
    ok.
