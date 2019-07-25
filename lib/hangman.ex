defmodule Hangman do
  @moduledoc """
  API for the Hangman game. Offers utilities for clients as well as making the
  necessary calls to the game logic.
  """

  alias Hangman.Game

  defdelegate new_game(),             to: Game
  defdelegate tally(game),            to: Game

  @spec make_move(Game.t, String.t) :: {Game.t, Game.tally}
  def make_move(game, guess) do
    game = Game.make_move(game, guess)
    {game, tally(game)}
  end

end
