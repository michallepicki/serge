import gleam/io
import gleam/option
import gleam/string
import gleam/otp/actor
// import gleam/otp/process
import gleam/erlang

external type Ets(key_t, value_t)

external fn ets_kv_new() -> Ets(key_t, value_t) =
  "serge_ffi" "ets_new"

fn serge_init() -> actor.InitResult(Ets(key_t, value_t), msg_t) {
  io.println("Starting!")
  let state = ets_kv_new()
  actor.Ready(state: state, receiver: option.None)
}

fn serge_loop(
  _msg: msg_t,
  state: Ets(key_t, val_t),
) -> actor.Next(Ets(key_t, val_t)) {
  io.println("Received a message")
  actor.Continue(state)
}

pub fn main() -> Nil {
  // Result(process.Sender(msg_t), actor.StartError)
  case actor.start_spec(actor.Spec(
    init: serge_init,
    init_timeout: 500,
    loop: serge_loop,
  )) {
    Ok(_serge_sender) -> erlang.sleep_forever()
    Error(e) -> {
      io.println(string.append("Error when starting serge: ", erlang.format(e)))
      Nil
    }
  }
}
