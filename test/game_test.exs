defmodule GameTest do
  use ExUnit.Case

  alias Hangman.Game

  describe "new_game/0" do
    test "new_game returns structure" do
      game = Game.new_game()

      assert game.turns_left == 7
      assert game.game_state == :initializing
      assert length(game.letters) > 0
    end
  end

  describe "make_move/2" do
    test "state isn't changed for final state" do
      for final_state <- [:won, :lost] do
        game = Map.put(Game.new_game(), :game_state, final_state)

        {moved_game, _tally} = Game.make_move(game, "x")

        assert moved_game == game
      end
    end

    test "letter is not already used" do
      {game, _tally} =
        Game.new_game()
        |> Game.make_move("x")

      assert game.game_state != :already_used
    end

    test "letter is already used" do
      game = Game.new_game()

      {game, _tally} = Game.make_move(game, "x")
      assert game.game_state != :already_used

      {game, _tally} = Game.make_move(game, "x")
      assert game.game_state == :already_used
    end

    test "a good guess is recognized" do
      {game, _tally} =
        Game.new_game("wibble")
        |> Game.make_move("w")

      assert game.game_state == :good_guess
      assert game.turns_left == 7
    end

    test "a guessed word is a won game" do
      game = Game.new_game("wibble")

      {game, _tally} = Game.make_move(game, "w")
      {game, _tally} = Game.make_move(game, "i")
      {game, _tally} = Game.make_move(game, "b")
      {game, _tally} = Game.make_move(game, "b")
      {game, _tally} = Game.make_move(game, "l")
      {game, _tally} = Game.make_move(game, "e")

      assert game.game_state == :won
      assert game.turns_left == 7
    end

    test "bad guess is recognized" do
      {game, _tally} =
        Game.new_game("wibble")
        |> Game.make_move("x")

      assert game.game_state == :bad_guess
      assert game.turns_left == 6
    end

    test "lost game is recognized" do
      game = Game.new_game("w")

      {game, _tally} = Game.make_move(game, "a")
      {game, _tally} = Game.make_move(game, "b")
      {game, _tally} = Game.make_move(game, "c")
      {game, _tally} = Game.make_move(game, "d")
      {game, _tally} = Game.make_move(game, "e")
      {game, _tally} = Game.make_move(game, "f")
      {game, _tally} = Game.make_move(game, "g")

      assert game.game_state == :lost
    end
  end
end
