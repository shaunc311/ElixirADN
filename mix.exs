defmodule ElixirADN.Mixfile do
  use Mix.Project

  def project do
    [app: :elixir_adn,
     version: "0.2.0",
     elixir: "> 1.0.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:mock, "~> 0.1.0"},
      {:httpoison, "~> 0.6.2"},
      {:poison, "~> 1.3.0"}
    ]
  end
end
