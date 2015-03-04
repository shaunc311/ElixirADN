defmodule ElixirADN.Endpoints.Http do
	alias ElixirADN.Parser.StatusParser
	@moduledoc ~S"""
	A helper utility to send a request to a url and process it
	"""

	@doc ~S"""
	A general function to get an http request and process the result.
	"""
	def call({:get, url}, headers) when is_list(headers) do
		HTTPoison.get!(url, headers)
			|> read_response
	end

	@doc ~S"""
	A general function to post to an http endpoint and process the result.
	"""
	def call({:delete, url}, headers) when is_list(headers) do
		HTTPoison.delete!(url, headers)
			|> read_response
	end

	@doc ~S"""
	A general function to post to an http endpoint and process the result.
	"""
	def call({:post, url}, body, headers) when is_list(headers) do
		HTTPoison.post!(url, body, headers)
			|> read_response
	end

	

	#Parse the status code that comes back
	defp read_response(%HTTPoison.Response{ status_code: code } = success_message) do
		success = StatusParser.parse_status(code)
		case success do
			{:ok, _message} -> success_message
			{:error, message} -> {:error, message}
		end
	end
end