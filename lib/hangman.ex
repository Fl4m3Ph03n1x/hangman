defmodule Hangman do
  @moduledoc """
  API for the Hangman game. Offers utilities for clients as well as making the
  necessary calls to the game logic.
  """

  alias Hangman.Game
  alias Hangman.{Server, Supervisor}

  @spec new_game :: pid
  def new_game do
    {:ok, pid} = DynamicSupervisor.start_child(Supervisor, Server)
    pid
  end

  @spec tally(pid) :: Game.tally
  def tally(pid), do: GenServer.call(pid, {:tally})

  @spec make_move(pid, String.t) :: Game.tally
  def make_move(pid, guess), do: GenServer.call(pid, {:make_move, guess})

end
