defmodule ElixirADN.Endpoints.User do
	alias ElixirADN.Endpoints.Parameters.Encoder
	alias ElixirADN.Endpoints.Parameters.Pagination
	alias ElixirADN.Endpoints.Parameters.PostParameters
	alias ElixirADN.Model.Post
	alias ElixirADN.Parser.BaseParser
	alias ElixirADN.Parser.StatusParser

	@moduledoc ~S"""
	An interface to the user endpoints in ADN.  They are urls begining with 
	/users here:
	
	https://developers.app.net/reference/resources/	
	"""	

	@doc ~S"""
	Returns the posts for a given user taking into account the parameter objects
	passed in
	"""
	def get_posts(user_id, %PostParameters{} = post_parameters, %Pagination{} = pagination) when is_binary(user_id) do
		result = case String.at(user_id, 0) do
			nil -> {:error, :no_account_name}
			"@" -> process_get_posts(user_id, post_parameters, pagination)
			_ -> {:error, :invalid_account_name_format	}			
		end
		case result do
			{:error, _} -> result
			_ -> {:ok, parse_to_posts(result)}
		end
	end

	def get_posts(user_id, %PostParameters{} = post_parameters, %Pagination{} = pagination) when is_integer(user_id) do
		result = process_get_posts(user_id, post_parameters, pagination)
		case result do
			{:error, _} -> result
			_ -> {:ok, parse_to_posts(result)}
		end
	end

	def get_posts(_, _, _) do
		{:error, :invalid_parameter_to_parse}
	end

	#Parse the response body into a map and then into objects
	defp parse_to_posts(%HTTPotion.Response{body: body}) do
		{result, value} = BaseParser.parse(:users, body)
		case result do
			:ok -> BaseParser.decode(:posts, value, Post)
			:error -> {:error, value}
		end
	end

	#Turn the parameters into a query string and then make the get call
	defp process_get_posts(user_id, %PostParameters{} = post_parameters, %Pagination{} = pagination ) do
		query_string_result = Encoder.generate_query_string([post_parameters, pagination])

		case query_string_result do
			{:ok, query_string} -> call({:get, "https://api.app.net/users/#{user_id}/posts#{query_string}"})
			error -> error
		end	
	end

	#A general function to call an http method.  This should be in it's own
	#module eventually
	defp call({:get, url}) do
		return_on_success = HTTPotion.get(url)
		%HTTPotion.Response{ status_code: code } = return_on_success
		success = StatusParser.parse_status(code)
		case success do
			{:ok, _message} -> return_on_success
			{:error, message} -> {:error, message}
		end
	end
end