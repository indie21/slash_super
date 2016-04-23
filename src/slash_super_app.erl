-module(slash_super_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, start/0]).


%% ===================================================================
%% Application callbacks
%% ===================================================================


start(_StartType, _StartArgs) ->
    slash_super_sup:start_link().

stop(_State) ->
    ok.

start() ->
    application:start(slash_super),
    Count = application:get_env(slash_super, count, 10),
    [start_super_one(Id) || Id <- lists:seq(1, Count) ],
    ok.


atom_suffix(Prefix, No) ->
    L = atom_to_list(Prefix) ++ "_" ++ integer_to_list(No),
    list_to_atom(L).


%% 获取super的spec.
super_spec(Id) ->
    Name = atom_suffix(slash_super_sup_worker, Id),
    {Name,
     {slash_super_sup_worker, start_link, [Name]},
     permanent,
     infinity,
     supervisor,
     []
    }.

%% 获取super的spec.
worker_spec(Id) ->
    Name = atom_suffix(slash_super_worker, Id),
    {Name,
     {slash_super_worker, start_link, [Name]},
     permanent,
     infinity,
     worker,
     []
    }.

start_super_one(Id) ->
    _Ret1 = supervisor:start_child(slash_super_sup, super_spec(Id)),
    %% io:format("start_super_one id ~p (~p)~n", [Id, Ret1]),
    _Ret2= supervisor:start_child(slash_super_sup, worker_spec(Id)),
    %% io:format("start_super_one(~p)~n", [ Ret2]),
    ok.
