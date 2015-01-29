defmodule ElixirADN.Endpoints.Parameters.Encoder do
	@doc ~S"""
	Turn a pagination object into a collection of tuples of query parameters.

	It will return one of:
		{:ok, query_string} where query_string is a basic formatted query string.  There are probably defects in here.
		{:error, {message, field, value}} when a field is the wrong type or the value is invalid 
		{:error, message} when something general goes wrong


	## Examples

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string %ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{}
			{:ok, "" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string %ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{since_id: 400}
			{:ok, "?since_id=400" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string %ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{before_id: 400}
			{:ok, "?before_id=400" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string %ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{count: -100 }
			{:ok, "?count=-100" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string %ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{count: 200 }
			{:ok, "?count=200" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string %ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{before_id: 1, count: 200 }
			{:ok, "?before_id=1&count=200" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string %ElixirADN.Endpoints.Parameters.PostParameters{ include_muted: true}, %ElixirADN.Endpoints.Parameters.Pagination{before_id: 1, count: 200 }
			{:ok, "?include_muted=1&before_id=1&count=200" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string %ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{count: 201 }
			{:error, {:value_out_of_range, :count, 201 } }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string %ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{count: -201 }
			{:error, {:value_out_of_range, :count, -201 } }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string %ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{}
			{:ok, "" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string %ElixirADN.Endpoints.Parameters.PostParameters{include_annotations: false}, %ElixirADN.Endpoints.Parameters.Pagination{}
			{:ok, "?include_annotations=0" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string %ElixirADN.Endpoints.Parameters.PostParameters{include_muted: 1}, %ElixirADN.Endpoints.Parameters.Pagination{}
			{:error, {:invalid_boolean_value, :include_muted, 1 }} 

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string %ElixirADN.Endpoints.Parameters.PostParameters{include_muted: true, include_deleted: true, include_directed_posts: true, include_machine: true, include_starred_by: true, include_reposters: true, include_annotations: true, include_post_annotations: true, include_user_annotations: true, include_html: true}, %ElixirADN.Endpoints.Parameters.Pagination{}
			{:ok, "?include_annotations=1&include_deleted=1&include_directed_posts=1&include_html=1&include_machine=1&include_muted=1&include_post_annotations=1&include_reposters=1&include_starred_by=1&include_user_annotations=1" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string "hi", "hello"
			{:error, :invalid_object_to_parse }

	"""
	def generate_query_string(%ElixirADN.Endpoints.Parameters.PostParameters{} = post_parameters, %ElixirADN.Endpoints.Parameters.Pagination{} =pagination) do
		post_result = encode_parameters(post_parameters)
		pagination_result = encode_parameters(pagination)
		
		#check for errors
		results = Enum.reduce([post_result, pagination_result], [], fn(x,acc) -> gather_parameters(x, acc) end)
		
		#if it's a list then it isn't an error
		case is_list(results) do
			true -> 
				formatted_string = results
					|> join_parameters
					|> format_query_string
				{:ok, formatted_string }
			false -> results
		end
	end

	#This shouldn't hit because encoder is only called from an endpoint
	#that should already check this
	def generate_query_string(_,_), do: {:error, :invalid_object_to_parse}

	#Turn the struct into a query string
	defp encode_parameters(struct) do
		result = create_query_parameters(struct)
		case result do
			{:ok, tuples} -> create_query_string(tuples)
			_ -> result
		end
	end

	#Empty query string doesn't need a ?
	defp format_query_string(""), do: ""

	#Put a ? in front of the query string since it isn't empty
	defp format_query_string(query_string) when is_binary(query_string) do
		"?" <> query_string
	end

	# A method to create tuples of value to translate to 
	defp create_query_parameters(struct) when is_map(struct) do
		case validate(struct) do
			:ok ->
				result = Map.keys(struct)
					|> Enum.reduce( %{}, fn(key,acc) -> encode(acc, key, Map.get(struct, key)) end)
				{:ok, result}
			value ->
				value
		end
	end

	#Encode the URI with the given parameters
	defp create_query_string(parameters) when is_map(parameters) do
		query_string = URI.encode_query(parameters)
		{:ok, query_string}
	end

	#Pagination errors when the count is less than -200 or greater than 200
	defp validate(%ElixirADN.Endpoints.Parameters.Pagination{count: count}) when abs(count) > 200 do
		{:error, {:value_out_of_range, :count, count}}
	end

	#Pagination with a count inside -200 to 200 which is totally ok, although 0 might be stupid
	defp validate(%ElixirADN.Endpoints.Parameters.Pagination{}), do: :ok

	#All the parameters in PostParameters are flags so make sure everything is true/false
	defp validate(%ElixirADN.Endpoints.Parameters.PostParameters{} = post_parameters) do
		result = Map.keys(post_parameters)
			|> Enum.reduce( :ok, fn(key,acc) -> validate_boolean_parameter(acc, key, Map.get(post_parameters, key)) end)
		result
	end

	#ignore the struct key
	defp encode(acc, :__struct__, _), do: acc
	#ignore any defaulted keys
	defp encode(acc, name, nil) when is_atom(name), do: acc

	#true/false values are converted to 1/0
	defp encode(acc, name, value) when is_atom(name) and is_boolean(value) do
		case value do
			true -> Map.put( acc, name, 1 )
			false -> Map.put( acc, name, 0 )
		end
	end

	#add the new atom/value pair
	defp encode(acc, name, value) when is_atom(name) do
		Map.put( acc, name, value )
	end

	#ignore the struct paramter
	defp validate_boolean_parameter(acc, :__struct__,_), do: acc
	#ignore nil values
	defp validate_boolean_parameter(acc, _parameter, nil), do: acc
	#if the value is true/false everything is ok
	defp validate_boolean_parameter(acc, parameter, value) when is_atom(parameter) and value in [true, false], do: acc

	#error if a boolean parameter is not boolean
	defp validate_boolean_parameter(_acc, parameter, value) when is_atom(parameter) do
		{:error, {:invalid_boolean_value, parameter, value}}
	end

	defp join_parameters(["",""]), do: ""
	defp join_parameters(["",value]) when is_binary(value), do: value
	defp join_parameters([value, ""]) when is_binary(value), do: value
	defp join_parameters([one, two]) when is_binary(one) and is_binary(two) do
		one <> "&" <> two
	end

	defp gather_parameters(_value, {:error, error}), do: {:error, error} 
	defp gather_parameters({:ok, value}, acc), do: acc ++ [value]
	defp gather_parameters(error, _acc), do: error
end