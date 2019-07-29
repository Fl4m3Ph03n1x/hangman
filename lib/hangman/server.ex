defmodule Hangman.Server do
  @moduledoc """
  GenServer that interacts with Game logic and returns the tally to the client.
  """

  use GenServer

  alias Hangman.Game

  @spec start_link(any) :: GenServer.on_start
  def start_link(_), do: GenServer.start_link(__MODULE__, nil)

  @impl GenServer
  @spec init(any) :: {:ok, Game.t}
  def init(_args), do: {:ok, Game.new_game()}

  @impl GenServer
  def handle_call({:make_move, guess}, _from, game) do
    {game, tally} = Game.make_move(game, guess)
    {:reply, tally, game}
  end

  @impl GenServer
  def handle_call({:tally}, _from, game), do: {:reply, Game.tally(game), game}
end
