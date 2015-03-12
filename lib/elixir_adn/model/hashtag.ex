defmodule ElixirADN.Model.Hashtag do
  @doc ~S"""
  An elixir representation of the ADN hashtags map found in the User map
  {
    "len": 8,
    "name": "adnhack",
    "pos": 90
  }
  """
  defstruct len: -1, name: "", pos: -1
end