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

	def parse(atom, body, module) when is_atom(atom) and is_atom(module) do
		apply(module, :parse, [body])
	end

	def parse(atom, body) when is_atom(atom) do
		ElixirADN.Parser.BaseParser.parse(atom, body)
	end

	def decode(atom, map, as, module) when is_atom(atom) and is_map(map) and is_atom(as) and is_atom(module) do
		apply(module, :decode, [atom, map, as])
	end

	def decode(atom, list, as, module) when is_atom(atom) and is_list(list) and is_atom(as) and is_atom(module) do
		apply(module, :decode, [atom, list, as])
	end

	def decode(atom, map, as) when is_atom(atom) and is_map(map) and is_atom(as) do
		ElixirADN.Parser.BaseParser.decode(atom, map, as)
	end

	def decode(atom, list, as) when is_atom(atom) and is_list(list) and is_atom(as) do
		ElixirADN.Parser.BaseParser.decode(atom, list, as)
	end
end