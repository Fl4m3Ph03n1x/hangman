defmodule Hangman.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Hangman.Supervisor]
    DynamicSupervisor.start_link(opts)
  end
end
