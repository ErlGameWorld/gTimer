-module(gTimer_app).

-behaviour(application).

-include("gTimer.hrl").

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    gtKvsToBeam:load(?gTimerCfg, [{?workCnt, 0}]),
    gTimer_sup:start_link().

stop(_State) ->
    ok.

