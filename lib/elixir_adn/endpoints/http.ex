defmodule ElixirADN.Endpoints.Http do
	alias ElixirADN.Parser.StatusParser
	
	#A general function to call an http method.  This should be in it's own
	#module eventually
	def call({:get, url}, headers) when is_list(headers) do
		HTTPotion.get(url, headers)
			|> read_response
	end

	#A general function to call an http method.  This should be in it's own
	#module eventually
	def call({:post, url}, headers) when is_list(headers) do
		HTTPotion.post(url, headers)
			|> read_response
	end

	defp read_response(%HTTPotion.Response{ status_code: code } = success_message) do
		success = StatusParser.parse_status(code)
		case success do
			{:ok, _message} -> success_message
			{:error, message} -> {:error, message}
		end
	end
end