defmodule Hangman.Game do
  use TypedStruct

  alias __MODULE__
  alias Dictionary

  typedstruct enforce: true, opaque: true do
    field :turns_left,  pos_integer,  default: 7
    field :game_state,  atom,         default: :initializing
    field :letters,     list,         default: []
    field :used,        MapSet.t,     default: MapSet.new()
  end

  ###############
  # Public API  #
  ###############

  @spec new_game(String.t) :: Game.t
  def new_game(word), do:
    %Game{letters: String.codepoints(word)}

  @spec new_game :: Game.t
  def new_game, do:
    new_game(Dictionary.random_word())

  def make_move(%Game{game_state: state} = game, _guess)
  when state in [:won, :lost], do: game

  def make_move(game, guess), do:
    accept_move(game, guess, MapSet.member?(game.used, guess))

  def tally(game), do:
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters:    reveal_guessed(game.letters, game.used)
    }

  ###############
  # Aux Functs  #
  ###############

  defp accept_move(game, _guess, _already_guesses = true), do:
    Map.put(game, :game_state, :already_used)

  defp accept_move(game, guess, _already_guesses = false), do:
    game
    |> Map.put(:used, MapSet.put(game.used, guess))
    |> score_guess(Enum.member?(game.letters, guess))

  defp score_guess(game, _good_guess = true) do
    new_state = MapSet.new(game.letters)
    |> MapSet.subset?(game.used)
    |> maybe_won()

    Map.put(game, :game_state, new_state)
  end

  defp score_guess(game = %Game{turns_left: 1}, _good_guess = false), do:
    Map.put(game, :game_state, :lost)

  defp score_guess(game = %Game{turns_left: turns_left}, _good_guess = false) do
    %Game{ game |
      game_state: :bad_guess,
      turns_left: turns_left - 1
    }
  end

  defp maybe_won(true),   do: :won
  defp maybe_won(false),  do: :good_guess



  defp reveal_guessed(letters, used) do
    letters
    |> Enum.map(fn letter -> reveal_letter(letter, MapSet.member?(used, letter)) end)
  end

  defp reveal_letter(letter, _in_word = true),    do: letter
  defp reveal_letter(_letter, _in_word = false),  do: "_"


end
