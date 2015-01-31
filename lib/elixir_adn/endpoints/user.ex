defmodule ElixirADN.Endpoints.User do
	alias ElixirADN.Endpoints.Parameters.Encoder
	alias ElixirADN.Endpoints.Parameters.Pagination
	alias ElixirADN.Endpoints.Parameters.PostParameters
	
	@doc ~S"""
	Returns the rest method and endpoint for a user's posts.  This also 
	takes into account any post or pagination parameters.
		
		## Examples
		
			iex> ElixirADN.Endpoints.User.get_posts("@user", %ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{} )
			{:get, "https://api.app.net/users/@user/posts" }

			iex> ElixirADN.Endpoints.User.get_posts("@user", %ElixirADN.Endpoints.Parameters.PostParameters{ include_muted: true }, %ElixirADN.Endpoints.Parameters.Pagination{} )
			{:get, "https://api.app.net/users/@user/posts?include_muted=1" }

			iex> ElixirADN.Endpoints.User.get_posts("@user", %ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{count: 5} )
			{:get, "https://api.app.net/users/@user/posts?count=5" }

			iex> ElixirADN.Endpoints.User.get_posts("@user", %ElixirADN.Endpoints.Parameters.PostParameters{ include_muted: true }, %ElixirADN.Endpoints.Parameters.Pagination{count: 5} )
			{:get, "https://api.app.net/users/@user/posts?include_muted=1&count=5" }

			iex> ElixirADN.Endpoints.User.get_posts("@user", %ElixirADN.Endpoints.Parameters.PostParameters{ include_muted: true, include_annotations: false }, %ElixirADN.Endpoints.Parameters.Pagination{count: 5, before_id: 2} )
			{:get, "https://api.app.net/users/@user/posts?include_annotations=0&include_muted=1&before_id=2&count=5" }

			iex> ElixirADN.Endpoints.User.get_posts("@user", %{ include_muted: true, include_annotations: false }, %{count: 5, before_id: 2} )
			{:error, :invalid_parameter_to_parse}

			iex> ElixirADN.Endpoints.User.get_posts("@user", %ElixirADN.Endpoints.Parameters.PostParameters{ include_muted: 5 }, %ElixirADN.Endpoints.Parameters.Pagination{} )
			{:error, {:invalid_boolean_value, :include_muted, 5} }

			iex> ElixirADN.Endpoints.User.get_posts("@user", %ElixirADN.Endpoints.Parameters.PostParameters{ include_muted: true }, %ElixirADN.Endpoints.Parameters.Pagination{count: 201} )
			{:error, {:value_out_of_range, :count, 201} }

			iex> ElixirADN.Endpoints.User.get_posts("@user", %ElixirADN.Endpoints.Parameters.PostParameters{ include_muted: true }, %ElixirADN.Endpoints.Parameters.Pagination{count: -201} )
			{:error, {:value_out_of_range, :count, -201} }

			iex> ElixirADN.Endpoints.User.get_posts(410, %ElixirADN.Endpoints.Parameters.PostParameters{ }, %ElixirADN.Endpoints.Parameters.Pagination{} )
			{:get, "https://api.app.net/users/410/posts" }


	"""
	def get_posts(user_id, %PostParameters{} = post_parameters, %Pagination{} = pagination) when is_binary(user_id) do
		case String.at(user_id, 0) do
			nil -> {:error, :no_account_name}
			"@" -> process_get_posts(user_id, post_parameters, pagination)
			_ -> {:error, :invalid_account_name_format	}			
		end
	end

	def get_posts(user_id, %PostParameters{} = post_parameters, %Pagination{} = pagination) when is_integer(user_id) do
		process_get_posts(user_id, post_parameters, pagination)
	end

	def get_posts(_, _, _) do
		{:error, :invalid_parameter_to_parse}
	end


	defp process_get_posts(user_id, %PostParameters{} = post_parameters, %Pagination{} = pagination ) do
		query_string_result = Encoder.generate_query_string(post_parameters, pagination)

		case query_string_result do
			{:ok, query_string} -> {:get, "https://api.app.net/users/#{user_id}/posts#{query_string}"}
			error -> error
		end	
	end
end