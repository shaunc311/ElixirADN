defmodule ElixirADN.Endpoints.Post do
	alias ElixirADN.Endpoints.Http
	alias ElixirADN.Endpoints.Parameters.Encoder
	alias ElixirADN.Endpoints.Parameters.Pagination
	alias ElixirADN.Endpoints.Parameters.PostParameters
	alias ElixirADN.Model.Post
	alias ElixirADN.Parser.ResultParser

	@moduledoc ~S"""
	An interface to the posts endpoints in ADN.  They are urls begining with 
	/posts here:
	
	https://developers.app.net/reference/resources/	
	"""	
	@doc ~S"""
	Post to ADN.  This requests a user token.
	"""
	def create_post(user_token, %Post{} = post) when is_binary(user_token) do
		process_add_post(user_token, post)
	end

	def create_post(_,_) do
		{:error, :invalid_object_to_post}
	end

	@doc ~S"""
	Get posts from the global stream
	"""
	def get_posts(%PostParameters{} = post_parameters, %Pagination{} = pagination) do
		#Make sure the string starts with @
		results = process_get_posts(post_parameters, pagination)
			|> parse_to_posts
		
		{:ok, results}
	end

	#Parse the response body into a map and then into objects
	defp parse_to_posts(%HTTPoison.Response{body: body}) do
		{result, value} = ResultParser.parse(:posts, body)
		case result do
			:ok -> ResultParser.decode(:posts, value, Post)
			:error -> {:error, value}
		end
	end

	#Turn the parameters into a query string and then make the get call
	defp process_get_posts(%PostParameters{} = post_parameters, %Pagination{} = pagination ) do
		query_string_result = Encoder.generate_query_string([post_parameters, pagination])

		case query_string_result do
			{:ok, query_string} -> Http.call({:get, "https://api.app.net/posts/stream/global#{query_string}"}, [])
			error -> error
		end	
	end

	#Call the post endpoint with the json post
	defp process_add_post(token, %Post{} = post ) do
		body = Encoder.generate_json(post)
		Http.call({:post, "https://api.app.net/posts"}, body, [{"Authorization", "Bearer #{token}"}, {"Content-Type", "application/json"}])		
	
	end
end