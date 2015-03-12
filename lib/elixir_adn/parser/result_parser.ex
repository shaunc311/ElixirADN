defmodule ElixirADN.Parser.ResultParser do
	alias ElixirADN.Model.Annotation
	alias ElixirADN.Model.Channel
	alias ElixirADN.Model.ChannelCounts
	alias ElixirADN.Model.ChannelPermissions
	alias ElixirADN.Model.DerivedFiles
	alias ElixirADN.Model.Description
	alias ElixirADN.Model.Entities
	alias ElixirADN.Model.File
	alias ElixirADN.Model.Hashtag
	alias ElixirADN.Model.Image
	alias ElixirADN.Model.ImageInfo
	alias ElixirADN.Model.ImageThumb
	alias ElixirADN.Model.Link
	alias ElixirADN.Model.Mention
	alias ElixirADN.Model.Message
	alias ElixirADN.Model.Post
	alias ElixirADN.Model.Source
	alias ElixirADN.Model.User
	alias ElixirADN.Model.UserCounts
	
	@moduledoc ~S"""
	This module processes the data coming back from ADN and creates
	structs based on the results.
	"""

	@doc ~S"""
	Parse data coming back from ADN.  It's mapped data => values
	so it needs to get the data value after parsing.  If the meta 
	data is ever needed it can be pulled from this map as well.
	"""
	def convert_to(%HTTPoison.Response{body: body}, :map) do
		parse(body)
	end

	def convert_to(%HTTPoison.Response{body: body}, as) when is_atom(as) do
		result = parse(body)
			|> decode(as)
		{:ok, result}
	end

	def convert_to(body, as) when is_binary(body) and is_atom(as) do
		result = parse(body)
			|> decode(as)
		{:ok, result}
	end

	def convert_to({:error, error_code, error_message}, as) when is_atom(as) do
		{:error,  error_code, error_message}
	end

	
	defp parse(body) when is_binary(body) do
		result = body
			|> Poison.decode!
			|> Map.get("data")
		{:ok, result}
	end

	#Decode data into model objects using the Poison library.  Lists
	#will decode each element into the given type.  Since Poison
	#only does a shallow decode, we also have to decode the children
	#of the given object
	# Match on nil first
	defp decode({:ok, nil}, _) do
		nil
	end

	# If we get a list then map each element into a decoded value
	defp decode({:ok, value}, as) when is_list(value) do
		value
			|> Enum.map( fn(x) -> decode({:ok, x}, as) end)
	end

	#A stream can get any kind of object back so test for
	#attributes
	defp decode({:ok, value}, :stream) do
		is_message = Map.has_key?(value, "channel_id")
  	is_user = Map.has_key?(value, "username")
  	is_channel = Map.has_key?(value, "owner")
  	is_post = Map.has_key?(value, "num_reposts")
  	cond do
  		is_message -> decode({:ok, value}, Message)
  		is_user -> decode({:ok, value}, User)
  		is_channel -> decode({:ok, value}, Channel)
  		is_post -> decode({:ok, value}, Post)
  	end
	end

	# Decode the value and see if we need to decode any child elements
	defp decode({:ok, value}, as) do
		Poison.Decode.decode(value, as: as)
			|> decode_children()
	end

	#Decode all the children properties from the post object
	defp decode_children(%Post{} = post) do
		post
			|> Map.put( :entities, decode({:ok, post.entities}, Entities))
			|> Map.put( :source, decode({:ok, post.source}, Source))
			|> Map.put( :user, decode({:ok, post.user}, User))
			|> Map.put( :annotations, decode({:ok, post.annotations}, Annotation))
			|> Map.put( :reposters, decode({:ok, post.reposters}, User))
			|> Map.put( :starred_by, decode({:ok, post.starred_by}, User))
	end

	#Decode all the children properties from the user object
	defp decode_children(%User{} = user) do
		user
			|> Map.put( :avatar_image, decode({:ok, user.avatar_image}, Image))
			|> Map.put( :counts,  decode({:ok, user.counts}, UserCounts))
			|> Map.put( :cover_image, decode({:ok, user.cover_image}, Image))
			|> Map.put( :description, decode({:ok, user.description}, Description))
			|> Map.put( :annotations, decode({:ok, user.annotations}, Annotation))
	end

	#Decode all the children properties from the entities object
	defp decode_children(%Entities{} = entities) do
		entities
			|> Map.put( :hashtags, decode({:ok, entities.hashtags}, Hashtag))
			|> Map.put( :links,  decode({:ok, entities.links}, Link))
			|> Map.put( :mentions, decode({:ok, entities.mentions}, Mention))
	end

	#Decode all the children properties from the description object
	defp decode_children(%Description{} = description) do
		description
			|> Map.put( :entities, decode({:ok, description.entities}, Entities))
	end

	#Decode all the children properties from the channel object
	defp decode_children(%Channel{} = channel) do
		channel
			|> Map.put( :counts, decode({:ok, channel.counts}, ChannelCounts))
			|> Map.put( :readers, decode({:ok, channel.readers}, ChannelPermissions))
			|> Map.put( :editors, decode({:ok, channel.editors}, ChannelPermissions))
			|> Map.put( :writers, decode({:ok, channel.writers}, ChannelPermissions))
			|> Map.put( :recent_message, decode({:ok, channel.recent_message}, Message))
			|> Map.put( :annotations, decode({:ok, channel.annotations}, Annotation))
	end

	#Decode all the children properties from the message object
	defp decode_children(%Message{} = message) do
		message
			|> Map.put( :entities, decode({:ok, message.entities}, Entities))
			|> Map.put( :source, decode({:ok, message.source}, Source))
			|> Map.put( :user, decode({:ok, message.user}, User))
			|> Map.put( :annotations, decode({:ok, message.annotations}, Annotation))
	end

	#Decode all the children properties from the file object
	defp decode_children(%File{} = file) do
		file
			|> Map.put( :derived_files, decode({:ok, file.derived_files}, DerivedFiles))
			|> Map.put( :image_info, decode({:ok, file.image_info}, ImageInfo))
			|> Map.put( :source, decode({:ok, file.source}, Source))
			|> Map.put( :user, decode({:ok, file.user}, User))
	end

	#Decode all the children properties from the derived file object
	defp decode_children(%DerivedFiles{} = files) do
		files
			|> Map.put( :image_thumb_200s, decode({:ok, files.image_thumb_200s}, ImageThumb))
			|> Map.put( :image_thumb_960r, decode({:ok, files.image_thumb_960r}, ImageThumb))
	end

	defp decode_children(%ImageThumb{} = thumb) do
		thumb
			|> Map.put( :image_info, decode({:ok, thumb.image_info}, ImageInfo))
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