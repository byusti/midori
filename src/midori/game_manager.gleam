import gleam/otp/actor
import gleam/dict.{type Dict}
import gleam/list
import gleam/int
import gleam/erlang/process.{type Subject}
import game_server.{type Message, new_game_from_fen}
import position
import ids/uuid
import midori/uci_move.{type UciMove}

pub type GameManagerMessage {
  Shutdown
  ApplyMove(reply_with: Subject(ApplyMoveResult), id: String, move: UciMove)
  NewGame(reply_with: Subject(String))
}

// The first element of the tuple is the origin square
// and the second element is a list of possible destination squares
pub type ClientFormatMoveList {
  ClientFormatMoveList(moves: List(#(String, List(String))))
}

pub type ApplyMoveResult {
  ApplyMoveResult(legal_moves: ClientFormatMoveList, fen: String)
}

fn handle_message(
  message: GameManagerMessage,
  game_map: Dict(String, Subject(Message)),
) -> actor.Next(GameManagerMessage, Dict(String, Subject(Message))) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    ApplyMove(client, id, move) -> {
      let assert Ok(server) = dict.get(game_map, id)
      game_server.apply_move_uci_string(server, move.move)
      let legal_moves = game_server.all_legal_moves(server)
      let length = list.length(legal_moves)
      let random_index = int.random(length)
      let assert Ok(random_move) = list.at(legal_moves, random_index)
      game_server.apply_move(server, random_move)
      let unformatted_moves = game_server.all_legal_moves(server)
      let formatted_moves =
        list.fold(unformatted_moves, ClientFormatMoveList(moves: []), fn(
          acc,
          move,
        ) {
          let origin = move.from
          let origin_string = position.to_string(origin)
          case list.find(acc.moves, fn(move) { move.0 == origin_string }) {
            Error(_) -> {
              let new_move = #(origin_string, [position.to_string(move.to)])
              ClientFormatMoveList(moves: [new_move, ..acc.moves])
            }
            Ok(#(_, destinations)) -> {
              let new_destinations =
                list.append(destinations, [position.to_string(move.to)])
              let new_move = #(origin_string, new_destinations)
              let new_moves =
                list.filter(acc.moves, fn(move) { move.0 != origin_string })
              ClientFormatMoveList(moves: [new_move, ..new_moves])
            }
          }
        })

      let response =
        ApplyMoveResult(
          legal_moves: formatted_moves,
          fen: game_server.get_fen(server),
        )
      process.send(client, response)
      actor.continue(game_map)
    }
    NewGame(client) -> {
      let server: Subject(Message) = game_server.new_server()
      new_game_from_fen(
        server,
        "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
      )
      let assert Ok(id) = uuid.generate_v7()
      let game_map = dict.insert(game_map, id, server)
      process.send(client, id)
      actor.continue(game_map)
    }
  }
}

pub fn start_game_manager() {
  let game_map = dict.new()
  let actor = actor.start(game_map, handle_message)
  actor
}
