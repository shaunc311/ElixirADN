defmodule ElixirADN.Model.ImageInfo do
  @doc ~S"""
  An elixir representation of the ADN image info map
  {
    "width": 200,
    "height": 200
  }
  """
  defstruct width: -1, height: -1
end