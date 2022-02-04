import gleam/io
import gleam/option
import gleam/string
import gleam/otp/actor
// import gleam/otp/process
import gleam/erlang

fn serge_init() -> actor.InitResult(Nil, msg_type) {
  io.println("Starting!")
  actor.Ready(state: Nil, receiver: option.None)
}

fn serge_loop(_msg: msg_type, state: Nil) -> actor.Next(Nil) {
  io.println("Received a message")
  actor.Continue(state)
}

pub fn main() -> Nil {
  // Result(process.Sender(msg_type), actor.StartError)
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
