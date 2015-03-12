defmodule ElixirADN.Model.Stream do
  @doc ~S"""
  An elixir representation of the ADN stream map
  {
    "endpoint": "https://stream-channel.app.net...",
    "filter": "...filter object...",
    "id": "1",
    "object_types": [
      "post"
    ],
    "type": "long_poll",
    "key": "rollout_stream"
  }
  """
  defstruct endpoint: "", filter: nil, id: "", object_types: [], type: "", key: ""
end