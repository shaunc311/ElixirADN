defmodule ElixirADN.Model.Links do
	@doc ~S"""
	An elixir representation of the ADN links map found in the User map
	{
    "len": 7,
    "pos": 31,
    "text": "App.net",
    "url": "http://App.net"
  }
	"""
	defstruct len: -1, pos: -1, text: "", url: ""
end