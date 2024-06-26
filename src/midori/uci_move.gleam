import gleam/string

pub type UciMove =
  String

// we receive a string in the following format: "e2e4"
// we need to convert it to a UciMove
pub fn convert_move(move: String) -> Result(UciMove, _) {
  case string.split(move, "-") {
    [from, to] -> {
      let move = from <> to
      Ok(move)
    }
    _ -> Error("Invalid move format")
  }
}
