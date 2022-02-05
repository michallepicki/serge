-module(serge_ffi).

-export([ets_kv_new/0, ets_kv_set/3, ets_kv_get/2]).

ets_kv_new() ->
  ets:new(ets, []).

ets_kv_set(Table, Key, Value) ->
  ets:insert(Table, {Key, Value}),
  Table.

ets_kv_get(Table, Key) ->
  case ets:lookup(Table, Key) of
    [{_, Value}] -> {some, Value};
    []      -> none
  end.
