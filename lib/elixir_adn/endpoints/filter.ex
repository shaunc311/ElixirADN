defmodule ElixirADN.Endpoints.Filter do
	alias ElixirADN.Endpoints.Http
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
		result = process_get_filters(user_token)
		case result do
			{:error, _} -> result
			_ -> {:ok, parse_to_filters(result)}
		end
	end

	#make the get call with the auth token
	defp process_get_filters(user_token) do
		Http.call({:get, "https://api.app.net/filters"}, [{"Authorization", "Bearer #{user_token}"}])
	end

	#Parse the response body into a map and then into objects
	defp parse_to_filters(%HTTPoison.Response{body: body}) do
		{result, value} = ResultParser.parse(:filters, body)
		case result do
			:ok -> ResultParser.decode(:filters, value, ElixirADN.Model.Filter)
			:error -> {:error, value}
		end
	end
end