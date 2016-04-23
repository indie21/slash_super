-module(slash_super).
-compile([export_all]).

-include("def.hrl").

%% 查找某一个Node上任意一个super.
get(Node) ->
    List = mnesia:dirty_read(super, Node),
    PidList = [Pid || #super{pid=Pid} <- List],
    lists:nth(random:uniform(length(PidList)), PidList).

