defmodule ElixirADN.Model.Annotation do
  @doc ~S"""
  An elixir representation of the ADN annotation map
  {
    "type": "net.app.core.directory.blog",
    "value": {
      "url": "http://daltoncaldwell.com/"
    }
  }
  """
  defstruct type: "", value: %{}
end