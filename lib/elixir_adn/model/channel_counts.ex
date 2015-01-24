defmodule ElixirADN.Model.ChannelCounts do
	@doc ~S"""
	An elixir representation of the ADN channel map
	{
    "messages": 42,
    "subscribers": 43
  }
	"""
	defstruct messages: -1, subscribers: -1 
end