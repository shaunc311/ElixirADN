defmodule ElixirADN.Endpoints.User do
	alias ElixirADN.Endpoints.Http
	alias ElixirADN.Endpoints.Parameters.Encoder
	alias ElixirADN.Endpoints.Parameters.Pagination
	alias ElixirADN.Endpoints.Parameters.PostParameters
	alias ElixirADN.Model.Post
	alias ElixirADN.Parser.ResultParser

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

	@doc ~S"""
	Returns the posts mentioning a given user taking into account the parameter objects
	passed in.  A token (app or user) is required
	"""
	def get_mentions(user_id, token, %PostParameters{} = post_parameters, %Pagination{} = pagination) when is_binary(user_id) do
		result = case String.at(user_id, 0) do
			nil -> {:error, :no_account_name}
			"@" -> process_get_mentions(user_id, token, post_parameters, pagination)
			_ -> {:error, :invalid_account_name_format	}			
		end
		case result do
			{:error, _} -> result
			_ -> {:ok, parse_to_posts(result)}
		end
	end

	def get_mentions(user_id, token, %PostParameters{} = post_parameters, %Pagination{} = pagination) when is_integer(user_id) do
		result = process_get_mentions(user_id, token, post_parameters, pagination)
		case result do
			{:error, _} -> result
			_ -> {:ok, parse_to_posts(result)}
		end
	end

	def get_mentions(_, _, _) do
		{:error, :invalid_parameter_to_parse}
	end


	#Parse the response body into a map and then into objects
	defp parse_to_posts(%HTTPotion.Response{body: body}) do
		{result, value} = ResultParser.parse(:users, body)
		case result do
			:ok -> ResultParser.decode(:posts, value, Post)
			:error -> {:error, value}
		end
	end

	#Turn the parameters into a query string and then make the get call
	defp process_get_posts(user_id, %PostParameters{} = post_parameters, %Pagination{} = pagination ) do
		query_string_result = Encoder.generate_query_string([post_parameters, pagination])

		case query_string_result do
			{:ok, query_string} -> Http.call({:get, "https://api.app.net/users/#{user_id}/posts#{query_string}"}, [])
			error -> error
		end	
	end

	#Turn the parameters into a query string and then make the get call
	defp process_get_mentions(user_id, token, %PostParameters{} = post_parameters, %Pagination{} = pagination ) do
		query_string_result = Encoder.generate_query_string([post_parameters, pagination])

		case query_string_result do
			{:ok, query_string} -> Http.call({:get, "https://api.app.net/users/#{user_id}/mentions#{query_string}"}, [headers: ["Authorization": "Bearer #{token}"]])
			error -> error
		end	
	end

	
end