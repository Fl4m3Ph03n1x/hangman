defmodule Hangman.Game do
  @moduledoc """
  Logic for the Hangman game. Contains the state machine that decides what
  actions are possible and the consequences of such actions.
  """

  use TypedStruct

  alias __MODULE__
  alias Dictionary

  typedstruct enforce: true, opaque: true do
    field :turns_left,  non_neg_integer,  default: 7
    field :game_state,  atom,             default: :initializing
    field :letters,     list,             default: []
    field :used,        MapSet.t,         default: MapSet.new()
  end

  @type tally :: %{
    game_state: :already_used | :bad_guess | :good_guess | :lost | :won,
    turns_left: non_neg_integer,
    letters:    [String.t],
    guesses:    [String.t]
  }

  ###############
  # Public API  #
  ###############

  @spec new_game(String.t) :: Game.t
  def new_game(word), do:
    %Game{letters: String.codepoints(word)}

  @spec new_game :: Game.t
  def new_game, do:
    new_game(Dictionary.random_word())

  @spec make_move(Game.t, String.t) :: {Game.t, tally}
  def make_move(%Game{game_state: state} = game, _guess)
  when state in [:won, :lost], do: return_with_tally(game)

  def make_move(game, guess), do:
    game
    |> accept_move(guess, MapSet.member?(game.used, guess))
    |> return_with_tally()

  @spec tally(Game.t) :: tally
  def tally(game), do:
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters:    reveal_guessed(game.letters, game.used),
      guesses:    MapSet.to_list(game.used)
    }

  ###############
  # Aux Functs  #
  ###############

  @spec accept_move(Game.t, String.t, boolean) :: Game.t
  defp accept_move(game, _guess, _already_guessed = true), do:
    Map.put(game, :game_state, :already_used)

  defp accept_move(game, guess, _already_guessed = false), do:
    game
    |> Map.put(:used, MapSet.put(game.used, guess))
    |> score_guess(Enum.member?(game.letters, guess))

  @spec return_with_tally(Game.t) :: {Game.t, tally}
  defp return_with_tally(game), do: {game, tally(game)}

  @spec score_guess(Game.t, boolean) :: Game.t
  defp score_guess(game, _good_guess = true) do
    new_state =
      game.letters
      |> MapSet.new()
      |> MapSet.subset?(game.used)
      |> maybe_won()

    Map.put(game, :game_state, new_state)
  end

  defp score_guess(game = %Game{turns_left: 1}, _good_guess = false), do:
    game
    |> Map.put(:turns_left, 0)
    |> Map.put(:game_state, :lost)

  defp score_guess(game = %Game{turns_left: turns_left}, _good_guess = false) do
    %Game{game |
      game_state: :bad_guess,
      turns_left: turns_left - 1
    }
  end

  @spec maybe_won(boolean) :: :won | :good_guess
  defp maybe_won(true),   do: :won
  defp maybe_won(false),  do: :good_guess

  @spec reveal_guessed([String.t], MapSet.t) :: [String.t]
  defp reveal_guessed(letters, used), do:
    Enum.map(
      letters,
      fn letter -> reveal_letter(letter, MapSet.member?(used, letter)) end
    )

  @spec reveal_letter(String.t, boolean) :: String.t
  defp reveal_letter(letter, _in_word = true),    do: letter
  defp reveal_letter(_letter, _in_word = false),  do: "_"
end
