-module(gTimer).

-include("gTimer.hrl").

-export([
   start/0
   , stop/0
   , startWork/1
   , setTimer/2
   , setTimer/3
   , getTimer/1
   , asyncDelTimer/1
   , syncDelTimer/1
]).

timerName(Idx) ->
   binary_to_atom(<<"$gtWork_", (integer_to_binary(Idx))/binary>>).

-spec startWork(Cnt :: non_neg_integer()) -> ok | {error, term()}.
startWork(Cnt) when Cnt > 0 ->
   case ?gTimerCfg:getV(?workCnt) of
      0 ->
         NameList = [{Idx, timerName(Idx)} || Idx <- lists:seq(1, Cnt)],
         [supervisor:start_child(gTimer_sup, [WorkName]) || {_Idx, WorkName} <- NameList],
         CfgList = [{?workCnt, Cnt} | NameList],
         gtKvsToBeam:load(?gTimerCfg, CfgList),
         ok;
      _Cnt ->
         {error, started}
   end.

start() ->
   application:ensure_all_started(gTimer).

stop() ->
   gtKvsToBeam:load(?gTimerCfg, [{?workCnt, 0}]),
   application:stop(gTimer).

-spec setTimer(Time :: non_neg_integer(), MFA :: {module(), atom(), term()}) -> reference().
setTimer(Time, MFA) ->
   Cnt = ?gTimerCfg:getV(?workCnt),
   Idx = rand:uniform(Cnt),
   erlang:start_timer(Time, ?gTimerCfg:getV(Idx), MFA).

-spec setTimer(Time :: non_neg_integer(), MFA :: {module(), atom(), term()}, Strategy :: rand | bind) -> reference().
setTimer(Time, MFA, Strategy) ->
   Cnt = ?gTimerCfg:getV(?workCnt),
   Idx = ?IIF(Strategy == rand, rand:uniform(Cnt), erlang:phash2(self(), Cnt) + 1),
   erlang:start_timer(Time, ?gTimerCfg:getV(Idx), MFA).

-spec getTimer(TimerRef :: reference()) -> false |  non_neg_integer().
getTimer(TimerRef) ->
   erlang:read_timer(TimerRef).

-spec asyncDelTimer(TimerRef :: reference()) -> false |  non_neg_integer().
asyncDelTimer(TimerRef) ->
   erlang:cancel_timer(TimerRef, [{async, true}, {info, false}]).

-spec syncDelTimer(TimerRef :: reference()) -> false |  non_neg_integer().
syncDelTimer(TimerRef) ->
   erlang:cancel_timer(TimerRef).