-module(gtWork).

-behavior(gen_srv).

-export([
   start_link/1
]).

-export([
   init/1
   , handleCall/3
   , handleCast/2
   , handleInfo/2
   , terminate/2
   , code_change/3
]).

-record(state, {}).

%% ********************************************  API *******************************************************************
start_link(SrvName) ->
   gen_srv:start_link({local, SrvName}, ?MODULE, [], []).

%% ********************************************  callback **************************************************************
init(_Args) ->
   {ok, #state{}}.

handleCall(_Msg, _State, _FROM) ->
   {reply, ok}.

%% 默认匹配
handleCast(_Msg, _State) ->
   kpS.

handleInfo({timeout, TimerRef, Msg}, _State) ->
   %% 确认Msg格式 然后做分发处理
   io:format("the timer time out ~p ~p ~n", [TimerRef, Msg]),
   kpS;
handleInfo(_Msg, _State) ->
   kpS.

terminate(_Reason, _State) ->
   ok.

code_change(_OldVsn, State, _Extra) ->
   {ok, State}.
%% ****************************************************** logic ********************************************************




