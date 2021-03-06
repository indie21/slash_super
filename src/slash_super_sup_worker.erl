-module(slash_super_sup_worker).

-behaviour(supervisor).

%% %% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

%% %% Helper macro for declaring children of supervisor
%% -define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% %% ===================================================================
%% %% API functions
%% %% ===================================================================

start_link(Name) ->
    supervisor:start_link({local, Name}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    {ok, { {one_for_one , 5, 10}, []} }.


