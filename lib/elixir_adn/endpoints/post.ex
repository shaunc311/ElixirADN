defmodule ElixirADN.Endpoints.Post do
	alias ElixirADN.Endpoints.Http
	alias ElixirADN.Endpoints.Parameters.Encoder
	alias ElixirADN.Model.Post

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

	#Call the post endpoint with the json post
	defp process_add_post(token, %Post{} = post ) do
		body = Encoder.generate_json(post)
		Http.call({:post, "https://api.app.net/posts"}, body, [{"Authorization", "Bearer #{token}"}, {"Content-Type", "application/json"}])		
	
	end
end