%%%-------------------------------------------------------------------
%%% @author zhuoyikang <>
%%% @copyright (C) 2016, zhuoyikang
%%% @doc
%%% 这些worker是super使用的代理.
%%%
%%% @end
%%% Created : 23 Apr 2016 by zhuoyikang <>
%%%-------------------------------------------------------------------

-module(slash_super_worker).

-behaviour(gen_server).

%% API
-export([start_link/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-include("def.hrl").

-define(SERVER, ?MODULE).

-record(state, {sup_name}).

%%%===================================================================
%%% API
%%%===================================================================


start_link(SuperName, Name) ->
    gen_server:start_link({local, Name}, ?MODULE, [SuperName], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([SuperName]) ->
    Slash = #super{id=node(), pid=self()},
    process_flag(trap_exit, true),
    slash_cluster:set_val(super, Slash),
    {ok, #state{sup_name=SuperName}}.

%% 同步调用。
handle_call({start_child, Spec}, _From, State = #state{sup_name=SuperName}) ->
    Reply = start_child(SuperName, Spec),
    {reply, Reply, State};

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% 异步调用。
handle_cast({start_child, Spec, Fun}, State = #state{sup_name=SuperName}) ->
    case start_child(SuperName, Spec) of
        Pid when is_pid(Pid) -> spawn(fun() -> Fun(Pid) end);
        _-> ignore
    end,
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    Slash = #super{id=node(), pid=self()},
    slash_cluster:del_object(super, Slash),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================


%% 新启动一个child.
start_child(SuperName, Spec) ->
    case catch supervisor:start_child(SuperName, Spec) of
        {ok,Pid} -> Pid;
        E -> io:format("start_child error ~p~n", [E]), undefined
    end.
