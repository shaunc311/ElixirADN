defmodule ElixirADN.Parser.Parser do
	use Behaviour

	@doc ~S"""
	Parse data from a source into ElixirADN.Model structs

	Example: parse(:posts, post_data)
	"""
	defcallback parse(atom, any)

	@doc ~S"""
	Decode regular map data into ElixirADN.Model stucts.

	Example: decode(:post, data, ElixirADN.Model.Post)
	"""
	defcallback decode(atom, Map.t, any)
end