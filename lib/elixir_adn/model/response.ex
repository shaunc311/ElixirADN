defmodule ElixirADN.Model.Response do
  @doc ~S"""
  A helper struct to make replying to posts and messages seemless
  """
  defstruct entities: nil, machine_only: false, reply_to: nil, text: "", annotations: []
end