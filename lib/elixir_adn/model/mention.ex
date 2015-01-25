defmodule ElixirADN.Model.Mention do
	@doc ~S"""
	An Elixir representation of the ADN mention map
	{
		"name": "berg",
	  "id": "2",
	  "pos": 0,
	  "len": 5,
	  "is_leading": true
	}
	"""
	defstruct name: "", id: "", pos: -1, len: -1, is_leading: false
end