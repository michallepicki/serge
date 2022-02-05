-module(serge_ffi).

-export([ets_new/0]).

ets_new() ->
  ets:new(ets, []).

