defmodule ElixirADN.Parser.MetaParser do
	@moduledoc ~S"""
	Parse any meta data from the data object returned from ADN
	"""

	@doc ~S"""
	Parse the document body for an error message

	Examples:
		iex> ElixirADN.Parser.MetaParser.parse_error "{\"meta\":{\"error_message\":\"hi\"}}"
		"hi"
	"""
	def parse_error(body) when is_binary(body) do
		Poison.decode!(body)
			|> Map.get("meta")
			|> Map.get("error_message")
	end
end