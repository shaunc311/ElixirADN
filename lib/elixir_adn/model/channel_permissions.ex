defmodule ElixirADN.Model.ChannelPermissions do
  @doc ~S"""
  An elixir representation of the ADN channel reader/writer/editor permissions
  {
    "any_user": false,
    "immutable": false,
    "public": true,
    "user_ids": [

    ],
    "you": true
  }
  """
  defstruct any_user: false, immutable: false, public: false, user_ids: [], you: false 
end