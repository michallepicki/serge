import gleam/io
import gleam/option
import gleam/string
import gleam/otp/actor
import gleam/otp/process
import gleam/erlang

external type EtsKV(key_t, value_t)

external fn ets_kv_new() -> EtsKV(key_t, value_t) =
  "serge_ffi" "ets_kv_new"

external fn ets_kv_set(
  ets_kv: EtsKV(key_t, value_t),
  key: key_t,
  value: value_t,
) -> EtsKV(key_t, value_t) =
  "serge_ffi" "ets_kv_set"

external fn ets_kv_get(
  ets_kv: EtsKV(key_t, value_t),
  key: key_t,
) -> option.Option(value_t) =
  "serge_ffi" "ets_kv_get"

type EtsKVMessage(key_t, value_t) {
  Write(key_t, value_t, process.Sender(Nil))
  GetEtsKV(process.Sender(EtsKV(key_t, value_t)))
}

fn serge_init() -> actor.InitResult(
  EtsKV(key_t, value_t),
  EtsKVMessage(key_t, value_t),
) {
  io.println("Starting!")
  let state = ets_kv_new()
  actor.Ready(state: state, receiver: option.None)
}

fn serge_loop(
  msg: EtsKVMessage(key_t, value_t),
  state: EtsKV(key_t, value_t),
) -> actor.Next(EtsKV(key_t, value_t)) {
  io.println("Received a message")
  case msg {
    Write(key, value, reply_sender) -> {
      ets_kv_set(state, key, value)
      process.send(reply_sender, Nil)
      Nil
    }
    GetEtsKV(reply_sender) -> {
      process.send(reply_sender, state)
      Nil
    }
  }
  actor.Continue(state)
}

pub fn main() -> Nil {
  // Result(process.Sender(msg_t), actor.StartError)
  case actor.start_spec(actor.Spec(
    init: serge_init,
    init_timeout: 500,
    loop: serge_loop,
  )) {
    Ok(serge_sender) -> {
      assert Ok(ets_kv) = process.try_call(serge_sender, GetEtsKV, 100)
      io.debug(ets_kv_get(ets_kv, 100))
      assert Ok(Nil) =
        process.try_call(
          serge_sender,
          fn(reply_sender) { Write(100, "a hundred", reply_sender) },
          100,
        )
      io.debug(ets_kv_get(ets_kv, 100))
      erlang.sleep_forever()
    }
    Error(e) -> {
      io.println(string.append("Error when starting serge: ", erlang.format(e)))
      Nil
    }
  }
}
