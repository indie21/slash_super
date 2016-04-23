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
    io:format("init ~p~n", [SuperName]),
    Slash = #super{id=node(), pid=self()},
    process_flag(trap_exit, true),
    slash_cluster:set_proc(super, Slash),
    {ok, #state{sup_name=SuperName}}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(crash, State) ->
    {stop, crash, State};
handle_info(Info, State) ->
    io:format("info ~p ~n",[Info]),
    {noreply, State}.

terminate(Reason, _State) ->
    io:format("termiante ~p~n", [Reason]),
    Slash = #super{id=node(), pid=self()},
    slash_cluster:del_object(super, Slash),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================


