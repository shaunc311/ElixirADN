defmodule ElixirADN.Parser.BaseParser do

	@doc ~S"""
	Parse post data coming back from ADN.  It's mapped data => values
	so it needs to get the data value after parsing.  If the meta 
	data is ever needed it can be pulled from this map as well.
	"""
	def parse(:posts, body) when is_binary(body) do
		parse_data(body)
	end

	def parse(:users, body) when is_binary(body) do
		parse_data(body)
	end

	def parse(:channels, body) when is_binary(body) do
		parse_data(body)
	end

	def parse(:messages, body) when is_binary(body) do
		parse_data(body)
	end

	def parse(:files, body) when is_binary(body) do
		parse_data(body)
	end

	def parse(_,_) do
		{:error, :invalid_data_to_parse}
	end

	defp parse_data(body) do
		map = body
			|> Poison.decode!
			|> Map.get("data")

		{:ok, map}
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
		_result = decode_children(result)
	end

	#Decode all the children properties from the post object
	defp decode_children(%ElixirADN.Model.Post{} = post) do
		post
			|> Map.put( :entities, decode(:entities, post.entities, ElixirADN.Model.Entities))
			|> Map.put( :source, decode(:source, post.source, ElixirADN.Model.Source))
			|> Map.put( :user, decode(:user, post.user, ElixirADN.Model.User))
			|> Map.put( :annotations, decode(:annotation, post.annotations, ElixirADN.Model.Annotation))
			|> Map.put( :reposters, decode(:users, post.reposters, ElixirADN.Model.User))
			|> Map.put( :starred_by, decode(:users, post.starred_by, ElixirADN.Model.User))
	end

	#Decode all the children properties from the user object
	defp decode_children(%ElixirADN.Model.User{} = user) do
		user
			|> Map.put( :avatar_image, decode(:image, user.avatar_image, ElixirADN.Model.Image))
			|> Map.put( :counts,  decode(:user_counts,user.counts, ElixirADN.Model.UserCounts))
			|> Map.put( :cover_image, decode(:image, user.cover_image, ElixirADN.Model.Image))
			|> Map.put( :description, decode(:description, user.description, ElixirADN.Model.Description))
			|> Map.put( :annotations, decode(:annotation, user.annotations, ElixirADN.Model.Annotation))
	end

	#Decode all the children properties from the entities object
	defp decode_children(%ElixirADN.Model.Entities{} = entities) do
		entities
			|> Map.put( :hashtags, decode(:hashtags, entities.hashtags, ElixirADN.Model.Hashtag))
			|> Map.put( :links,  decode(:links,entities.links, ElixirADN.Model.Link))
			|> Map.put( :mentions, decode(:mentions, entities.mentions, ElixirADN.Model.Mention))
	end

	#Decode all the children properties from the description object
	defp decode_children(%ElixirADN.Model.Description{} = description) do
		description
			|> Map.put( :entities, decode(:entities, description.entities, ElixirADN.Model.Entities))
	end

	#Decode all the children properties from the channel object
	defp decode_children(%ElixirADN.Model.Channel{} = channel) do
		channel
			|> Map.put( :counts, decode(:counts, channel.counts, ElixirADN.Model.ChannelCounts))
			|> Map.put( :readers, decode(:readers, channel.readers, ElixirADN.Model.ChannelPermissions))
			|> Map.put( :editors, decode(:editors, channel.editors, ElixirADN.Model.ChannelPermissions))
			|> Map.put( :writers, decode(:writers, channel.writers, ElixirADN.Model.ChannelPermissions))
			|> Map.put( :recent_message, decode(:recent_message, channel.recent_message, ElixirADN.Model.Message))
			|> Map.put( :annotations, decode(:annotation, channel.annotations, ElixirADN.Model.Annotation))
	end

	#Decode all the children properties from the message object
	defp decode_children(%ElixirADN.Model.Message{} = message) do
		message
			|> Map.put( :entities, decode(:entities, message.entities, ElixirADN.Model.Entities))
			|> Map.put( :source, decode(:source, message.source, ElixirADN.Model.Source))
			|> Map.put( :user, decode(:user, message.user, ElixirADN.Model.User))
			|> Map.put( :annotations, decode(:annotation, message.annotations, ElixirADN.Model.Annotation))
	end

	#Decode all the children properties from the file object
	defp decode_children(%ElixirADN.Model.File{} = file) do
		file
			|> Map.put( :derived_files, decode(:derived_files, file.derived_files, ElixirADN.Model.DerivedFiles))
			|> Map.put( :image_info, decode(:image_info, file.image_info, ElixirADN.Model.ImageInfo))
			|> Map.put( :source, decode(:source, file.source, ElixirADN.Model.Source))
			|> Map.put( :user, decode(:user, file.user, ElixirADN.Model.User))
	end

	#Decode all the children properties from the derived file object
	defp decode_children(%ElixirADN.Model.DerivedFiles{} = files) do
		files
			|> Map.put( :image_thumb_200s, decode(:image_thumb, files.image_thumb_200s, ElixirADN.Model.ImageThumb))
			|> Map.put( :image_thumb_960r, decode(:image_thumb, files.image_thumb_960r, ElixirADN.Model.ImageThumb))
	end

	defp decode_children(%ElixirADN.Model.ImageThumb{} = thumb) do
		thumb
			|> Map.put( :image_info, decode(:image_info, thumb.image_info, ElixirADN.Model.ImageInfo))
	end

	#Decode all the children properties from the description object
	defp decode_children(list) when is_list(list) do
		Enum.map( list, fn(x) -> decode_children(x) end)
	end

	#Fallthrough for decoding children that just returns the parent object
	defp decode_children(value) do
		value
	end

end