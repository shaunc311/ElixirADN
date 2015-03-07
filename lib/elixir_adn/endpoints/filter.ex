defmodule ElixirADN.Endpoints.Filter do
	alias ElixirADN.Endpoints.Http
	alias ElixirADN.Endpoints.Parameters.Encoder
	alias ElixirADN.Parser.ResultParser
	@moduledoc ~S"""
	An interface to the filters endpoints in ADN.  They are urls begining with 
	/filters here:
	
	https://developers.app.net/reference/resources/	
	"""	
	@doc ~S"""
	Get a list of a users filters.  Requires a user token
	"""
	def get(user_token) do
		Http.call({:get, "https://api.app.net/filters"}, user_token)
			|> ResultParser.convert_to(ElixirADN.Model.Filter)
	end

	@doc ~S"""
	Get a particular user filter.  Requires a user token
	"""
	def get(user_token, filter_id) when is_binary(filter_id) do
		Http.call({:get, "https://api.app.net/filters/#{filter_id}"}, user_token)
			|> ResultParser.convert_to(ElixirADN.Model.Filter)
	end

	@doc ~S"""
	Create a filter.  Requires a user token.
	"""
	def create_filter(user_token, %ElixirADN.Model.Filter{} = filter) when is_binary(user_token) do
		Encoder.generate_json(filter)
			|> Http.call({:post, "https://api.app.net/filters"}, user_token)	
	end
end