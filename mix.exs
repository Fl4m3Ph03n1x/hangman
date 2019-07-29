defmodule Hangman.MixProject do
  use Mix.Project

  def project do
    [
      app: :hangman,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [],
      mod: {Hangman.Application, []}
    ]
  end

  defp deps do
    [
      { :dictionary,    path: "../dictionary" },
      { :typed_struct,  "~> 0.1.4"            },

      { :dialyxir,        "~> 0.5.1", only: [:test, :dev],  runtime: false  },
      { :mix_test_watch,  "~> 0.8",   only: [:dev],         runtime: false  },
      { :credo,           "~> 1.0.0", only: [:dev, :test],  runtime: false  }
    ]
  end
end
