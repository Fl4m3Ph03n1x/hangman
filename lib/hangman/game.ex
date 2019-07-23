defmodule Hangman.Game do

  alias __MODULE__
  alias Dictionary

  defstruct turns_left: 7,
    game_state: :initializing,
    letters: []

  def new_game, do:
    %Game{letters: String.codepoints(Dictionary.random_word())}

end
