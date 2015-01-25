defmodule ElixirADN.Parser.BaseParser do
	@behaviour ElixirADN.Parser.Parser

	@doc ~S"""
	Parse post data coming back from ADN.  It's mapped data => values
	so it needs to get the data value after parsing.  If the meta 
	data is ever needed it can be pulled from this map as well.
	"""
	def parse(:posts, body) when is_binary(body) do
		posts_map = body
			|> Poison.decode!
			|> Map.get("data")

		#posts = decode(:posts, posts_map, ElixirADN.Model.Post)
			
		{:ok, posts_map}
	end

	def parse(_,_) do
		{:error, :invalid_data_to_parse}
	end

	@doc ~S"""
	Decode data into model objects using the Poison library.  Lists
	will decode each element into the given type.  Since Poison
	only does a shallow decode, we also have to decode the children
	of the given object
	"""
	# Match on nil first
	def decode(_, nil, _) do
		nil
	end

	# If we get a list then map each element into a decoded value
	def decode(token, value, as) when is_list(value) do
		value
			|> Enum.map( fn(x) -> decode(token, x, as) end)
	end

	# Decode the value and see if we need to decode any child elements
	def decode(_, value, as) do
		result = Poison.Decode.decode(value, as: as)
		decode_children(result)
	end

	#Decode all the children properties from the post object
	defp decode_children(%ElixirADN.Model.Post{} = post) do
		post = Map.put post, :entities, decode(:entities, post.entities, ElixirADN.Model.Entities)
		post = Map.put post, :source, decode(:source, post.source, ElixirADN.Model.Source)
		post = Map.put post, :user, decode(:user, post.user, ElixirADN.Model.User)
		post = Map.put post, :annotations, decode(:annotation, post.annotations, ElixirADN.Model.Annotation)
		post = Map.put post, :reposters, decode(:users, post.reposters, ElixirADN.Model.User)
		_post = Map.put post, :starred_by, decode(:users, post.starred_by, ElixirADN.Model.User)
	end

	#Decode all the children properties from the user object
	defp decode_children(%ElixirADN.Model.User{} = user) do
		user = Map.put user, :avatar_image, decode(:image, user.avatar_image, ElixirADN.Model.Image)
		user = Map.put user, :counts,  decode(:user_counts,user.counts, ElixirADN.Model.UserCounts)
		user = Map.put user, :cover_image, decode(:image, user.cover_image, ElixirADN.Model.Image)
		user = Map.put user, :description, decode(:description, user.description, ElixirADN.Model.Description)
		_user = Map.put user, :annotations, decode(:annotation, user.annotations, ElixirADN.Model.Annotation)
	end

	#Decode all the children properties from the entities object
	defp decode_children(%ElixirADN.Model.Entities{} = entities) do
		entities = Map.put entities, :hashtags, decode(:hashtags, entities.hashtags, ElixirADN.Model.Hashtag)
		entities = Map.put entities, :links,  decode(:links,entities.links, ElixirADN.Model.Link)
		_entities = Map.put entities, :mentions, decode(:mentions, entities.mentions, ElixirADN.Model.Mention)
	end

	#Decode all the children properties from the description object
	defp decode_children(%ElixirADN.Model.Description{} = description) do
		_description = Map.put description, :entities, decode(:entities, description.entities, ElixirADN.Model.Entities)
	end

	#Fallthrough for decoding children that just returns the parent object
	defp decode_children(value) do
		value
	end

end