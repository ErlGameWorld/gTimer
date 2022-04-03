-module(gTimer).

-include("gTimer.hrl").

-export([
   start/0
   , stop/0
   , startWork/1
   , setTimer/2
   , setTimer/3
   , getTimer/1
   , delTimer/1
]).



timerName(Idx) ->
   binary_to_atom(<<"$gtWSork_", (integer_to_binary(Idx))/binary>>).

startWork(Cnt) when Cnt > 0 ->
   case ?gTimerCfg:getV(?workCnt) of
      0 ->
         NameList = [{Idx, timerName(Idx)} || Idx <- lists:seq(1, Cnt)],
         [supervisor:start_child(gTimer_sup, [WorkName]) || {_Idx, WorkName} <- NameList],
         CfgList = [{?workCnt, Cnt} | NameList],
         gtKvsToBeam:load(?gTimerCfg, CfgList),
         ok1;
      _Cnt ->
         {error, started}
   end.

start() ->
   application:ensure_all_started(gTimer).

stop() ->
   gtKvsToBeam:load(?gTimerCfg, [{?workCnt, 0}]),
   application:stop(gTimer).

setTimer(Time, Msg) ->
   Cnt = ?gTimerCfg:getV(?workCnt),
   Idx = rand:uniform(Cnt),
   erlang:start_timer(Time, ?gTimerCfg:getV(Idx), Msg).

setTimer(Time, Msg, Strategy) ->
   Cnt = ?gTimerCfg:getV(?workCnt),
   Idx = ?IIF(Strategy == rand, rand:uniform(Cnt), erlang:phash2(self(), Cnt) + 1),
   erlang:start_timer(Time, ?gTimerCfg:getV(Idx), Msg).

getTimer(TimerRef) ->
   erlang:read_timer(TimerRef).

delTimer(TimerRef) ->
   erlang:cancel_timer(TimerRef) .







