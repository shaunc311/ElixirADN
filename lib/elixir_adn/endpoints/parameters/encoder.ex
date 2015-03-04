defmodule ElixirADN.Endpoints.Parameters.Encoder do
	alias ElixirADN.Model.Clause
	alias ElixirADN.Model.Filter
	alias ElixirADN.Model.Message
	alias ElixirADN.Model.Post
	alias ElixirADN.Endpoints.Parameters.AppStreamParameters
	alias ElixirADN.Endpoints.Parameters.Pagination
	alias ElixirADN.Endpoints.Parameters.PostParameters
	alias ElixirADN.Endpoints.Parameters.StreamEndpointParameters
	alias ElixirADN.Endpoints.Parameters.SubscriptionParameters
	alias ElixirADN.Endpoints.Parameters.UserParameters

	@moduledoc ~S"""
	This module encodes a list of parameter objects into a query string.  It currently 
	works with Pagination and Post Parameters.

	Pagination: https://developers.app.net/reference/make-request/pagination
	Post: https://developers.app.net/reference/resources/post/#general-parameters

	"""
	@doc ~S"""
	Turn a pagination object into a collection of objects into a query string.

	It will return one of:
		{:ok, query_string} where query_string is a basic formatted query string.  There are probably defects in here.
		{:error, {message, field, value}} when a field is the wrong type or the value is invalid 
		{:error, message} when something general goes wrong


	## Examples

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{}]
			{:ok, "" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{since_id: 400}]
			{:ok, "?since_id=400" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{before_id: 400}]
			{:ok, "?before_id=400" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{count: -100 }]
			{:ok, "?count=-100" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{count: 200 }]
			{:ok, "?count=200" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{before_id: 1, count: 200 }]
			{:ok, "?before_id=1&count=200" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.PostParameters{ include_muted: true}, %ElixirADN.Endpoints.Parameters.Pagination{before_id: 1, count: 200 }]
			{:ok, "?include_muted=1&before_id=1&count=200" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{count: 201 }]
			{:error, {:value_out_of_range, :count, 201 } }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{count: -201 }]
			{:error, {:value_out_of_range, :count, -201 } }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{}]
			{:ok, "" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.PostParameters{include_annotations: false}, %ElixirADN.Endpoints.Parameters.Pagination{}]
			{:ok, "?include_annotations=0" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: false}]
			{:ok, "?include_incomplete=0" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: false}]
			{:ok, "?include_incomplete=0" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.SubscriptionParameters{file_types: "bad"}]
			{:ok, "?file_types=bad" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.StreamEndpointParameters{include_annotations: false}]
			{:ok, "?include_annotations=0" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.PostParameters{include_muted: 1}, %ElixirADN.Endpoints.Parameters.Pagination{}]
			{:error, {:invalid_boolean_value, :include_muted, 1 }} 

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.PostParameters{include_muted: true, include_deleted: true, include_directed_posts: true, include_machine: true, include_starred_by: true, include_reposters: true, include_annotations: true, include_post_annotations: true, include_user_annotations: true, include_html: true}, %ElixirADN.Endpoints.Parameters.Pagination{}]
			{:ok, "?include_annotations=1&include_deleted=1&include_directed_posts=1&include_html=1&include_machine=1&include_muted=1&include_post_annotations=1&include_reposters=1&include_starred_by=1&include_user_annotations=1" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string [%ElixirADN.Endpoints.Parameters.UserParameters{include_annotations: true}]
			{:ok, "?include_annotations=1" }

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_query_string ["hi", "hello"]
			{:error, :invalid_object_to_parse }

	"""
	def generate_query_string(parameters) when is_list(parameters) do
		results = Enum.map(parameters, fn(x) -> convert_to_query_string(x) end)
			|> Enum.reduce([], fn(x, acc) -> gather_parameters(x, acc) end)

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

	#This is a passthrough to make sure we have a valid object to encode
	defp convert_to_query_string(%PostParameters{} = post_parameters) do
		encode_parameters(post_parameters)
	end

	defp convert_to_query_string(%Pagination{} = pagination) do
		encode_parameters(pagination)
	end

	defp convert_to_query_string(%Post{} = post) do
		encode_parameters(post)
	end

	defp convert_to_query_string(%StreamEndpointParameters{} = stream_parameters) do
		encode_parameters(stream_parameters)
	end

	defp convert_to_query_string(%SubscriptionParameters{} = sub_parameters) do
		encode_parameters(sub_parameters)
	end

	defp convert_to_query_string(%UserParameters{} = user_parameters) do
		encode_parameters(user_parameters)
	end

	#This shouldn't hit because encoder is only called from an endpoint
	#that should already check this
	defp convert_to_query_string(_), do: {:error, :invalid_object_to_parse}

	@doc ~S"""
	Turns a Post object into a valid map of data for ADN

	It currently supports these values:
		text
		reply_to

	ADN also supports the following attributes that this module doesn't support yet:
		machine_only
		annotations
		entities 



	## Examples

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_json(%ElixirADN.Model.Post{}) |> IO.iodata_to_binary
			"{\"text\":\"\",\"reply_to\":null}"

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_json(%ElixirADN.Model.Post{text: "test"}) |> IO.iodata_to_binary
			"{\"text\":\"test\",\"reply_to\":null}"

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_json(%ElixirADN.Model.Post{reply_to: "1"}) |> IO.iodata_to_binary
			"{\"text\":\"\",\"reply_to\":\"1\"}"

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_json(%ElixirADN.Model.Post{text: "test", reply_to: "1"}) |> IO.iodata_to_binary
			"{\"text\":\"test\",\"reply_to\":\"1\"}"

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_json(%ElixirADN.Model.Message{text: "test", reply_to: "1"}) |> IO.iodata_to_binary
			"{\"text\":\"test\",\"reply_to\":\"1\"}"

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_json(%ElixirADN.Model.Message{text: "test", channel_id: "4", reply_to: "1"}) |> IO.iodata_to_binary
			"{\"text\":\"test\",\"reply_to\":\"1\"}"

			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_json(%ElixirADN.Model.Filter{name: "name", match_policy: "match_policy", clauses: [%ElixirADN.Model.Clause{field: "field", object_type: "object_type", operator: "operator", value: "value"}]}) |> IO.iodata_to_binary
			"{\"name\":\"name\",\"match_policy\":\"match_policy\",\"clauses\":[{\"value\":\"value\",\"operator\":\"operator\",\"object_type\":\"object_type\",\"field\":\"field\"}]}"
			
			iex> ElixirADN.Endpoints.Parameters.Encoder.generate_json(%ElixirADN.Endpoints.Parameters.AppStreamParameters{object_types: ["object_types"], type: "type", filter_id: "filter_id", key: "key"}) |> IO.iodata_to_binary
			"{\"type\":\"type\",\"object_types\":[\"object_types\"],\"key\":\"key\",\"filter_id\":\"filter_id\"}"
			

	"""
	def generate_json(%Post{text: text, reply_to: reply_to, machine_only: machine_only, annotations: annotations, entities: entities}) do
		message = %{text: text, reply_to: reply_to}
		Poison.Encoder.encode( message, [] )
	end

	def generate_json(%Message{text: text, reply_to: reply_to, machine_only: machine_only, annotations: annotations, entities: entities}) do
		message = %{text: text, reply_to: reply_to}
		Poison.Encoder.encode( message, [] )
	end

	def generate_json(%Filter{name: name, match_policy: match_policy, clauses: clauses}) do
		clauses = Enum.map(clauses, fn(%Clause{field: field, object_type: object_type, operator: operator, value: value}) -> %{field: field, object_type: object_type, operator: operator, value: value} end)
		%{ name: name, match_policy: match_policy, clauses: clauses}
			|> Poison.Encoder.encode([])
	end

	def generate_json(%AppStreamParameters{object_types: object_types, type: type, filter_id: filter_id, key: key}) do
		%{object_types: object_types, type: type, filter_id: filter_id, key: key}
			|> Poison.Encoder.encode([])
	end

	def generate_json(_) do
		{:error, :invalid_object_to_encode }
	end

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
	defp validate(%Pagination{count: count}) when abs(count) > 200 do
		{:error, {:value_out_of_range, :count, count}}
	end

	#Pagination with a count inside -200 to 200 which is totally ok, although 0 might be stupid
	defp validate(%Pagination{}), do: :ok

	#All the parameters in PostParameters are flags so make sure everything is true/false
	defp validate(%PostParameters{} = post_parameters) do
		result = Map.keys(post_parameters)
			|> Enum.reduce( :ok, fn(key,acc) -> validate_boolean_parameter(acc, key, Map.get(post_parameters, key)) end)
		result
	end

	defp validate(%StreamEndpointParameters{} = stream_parameters) do
		result = Map.keys(stream_parameters)
			|> Enum.reduce( :ok, fn(key,acc) -> validate_boolean_parameter(acc, key, Map.get(stream_parameters, key)) end)
		result
	end

	defp validate(%UserParameters{} = user_parameters) do
		result = Map.keys(user_parameters)
			|> Enum.reduce( :ok, fn(key,acc) -> validate_boolean_parameter(acc, key, Map.get(user_parameters, key)) end)
		result
	end

	defp validate(%SubscriptionParameters{} = sub_parameters) do
		result = Map.keys(sub_parameters)
			#Only check the boolean parameters
			|> Enum.filter( fn(x) -> x in [:include_incomplete, :include_private, :include_read, :include_muted, :include_deleted, :include_machine, :include_directed_posts] end)
			|> Enum.reduce( :ok, fn(key,acc) -> validate_boolean_parameter(acc, key, Map.get(sub_parameters, key)) end)
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

	defp join_parameters(param_list) when is_list(param_list) do
		Enum.filter( param_list, fn(x) -> x != "" end)
			|> Enum.join("&")
	end

	defp gather_parameters(_value, {:error, error}), do: {:error, error} 
	defp gather_parameters({:ok, value}, acc), do: acc ++ [value]
	defp gather_parameters(error, _acc), do: error
end