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
		parse(body)
			|> decode(as)
	end

	def convert_to(body, as) when is_binary(body) and is_atom(as) do
		parse(body)
			|> decode(as)
	end

	def convert_to({:error, error_code, error_message}, as) when is_atom(as) do
		{:error,  error_code, error_message}
	end

	
	defp parse(body) when is_binary(body) do
		body
			|> Poison.decode!
			|> Map.get("data")
	end

	#Decode data into model objects using the Poison library.  Lists
	#will decode each element into the given type.  Since Poison
	#only does a shallow decode, we also have to decode the children
	#of the given object
	# Match on nil first
	defp decode(nil, _) do
		nil
	end

	# If we get a list then map each element into a decoded value
	defp decode(value, as) when is_list(value) do
		value
			|> Enum.map( fn(x) -> decode(x, as) end)
	end

	#A stream can get any kind of object back so test for
	#attributes
	defp decode(value, :stream) do
		is_message = Map.has_key?(value, "channel_id")
  	is_user = Map.has_key?(value, "username")
  	is_channel = Map.has_key?(value, "owner")
  	is_post = Map.has_key?(value, "num_reposts")
  	cond do
  		is_message -> decode(value, Message)
  		is_user -> decode(value, User)
  		is_channel -> decode(value, Channel)
  		is_post -> decode(value, Post)
  	end
	end

	# Decode the value and see if we need to decode any child elements
	defp decode(value, as) do
		result = Poison.Decode.decode(value, as: as)
		_result = decode_children(result)
	end

	#Decode all the children properties from the post object
	defp decode_children(%Post{} = post) do
		post
			|> Map.put( :entities, decode(post.entities, Entities))
			|> Map.put( :source, decode(post.source, Source))
			|> Map.put( :user, decode(post.user, User))
			|> Map.put( :annotations, decode(post.annotations, Annotation))
			|> Map.put( :reposters, decode(post.reposters, User))
			|> Map.put( :starred_by, decode(post.starred_by, User))
	end

	#Decode all the children properties from the user object
	defp decode_children(%User{} = user) do
		user
			|> Map.put( :avatar_image, decode(user.avatar_image, Image))
			|> Map.put( :counts,  decode(user.counts, UserCounts))
			|> Map.put( :cover_image, decode(user.cover_image, Image))
			|> Map.put( :description, decode(user.description, Description))
			|> Map.put( :annotations, decode(user.annotations, Annotation))
	end

	#Decode all the children properties from the entities object
	defp decode_children(%Entities{} = entities) do
		entities
			|> Map.put( :hashtags, decode(entities.hashtags, Hashtag))
			|> Map.put( :links,  decode(entities.links, Link))
			|> Map.put( :mentions, decode(entities.mentions, Mention))
	end

	#Decode all the children properties from the description object
	defp decode_children(%Description{} = description) do
		description
			|> Map.put( :entities, decode(description.entities, Entities))
	end

	#Decode all the children properties from the channel object
	defp decode_children(%Channel{} = channel) do
		channel
			|> Map.put( :counts, decode(channel.counts, ChannelCounts))
			|> Map.put( :readers, decode(channel.readers, ChannelPermissions))
			|> Map.put( :editors, decode(channel.editors, ChannelPermissions))
			|> Map.put( :writers, decode(channel.writers, ChannelPermissions))
			|> Map.put( :recent_message, decode(channel.recent_message, Message))
			|> Map.put( :annotations, decode(channel.annotations, Annotation))
	end

	#Decode all the children properties from the message object
	defp decode_children(%Message{} = message) do
		message
			|> Map.put( :entities, decode(message.entities, Entities))
			|> Map.put( :source, decode(message.source, Source))
			|> Map.put( :user, decode(message.user, User))
			|> Map.put( :annotations, decode(message.annotations, Annotation))
	end

	#Decode all the children properties from the file object
	defp decode_children(%File{} = file) do
		file
			|> Map.put( :derived_files, decode(file.derived_files, DerivedFiles))
			|> Map.put( :image_info, decode(file.image_info, ImageInfo))
			|> Map.put( :source, decode(file.source, Source))
			|> Map.put( :user, decode(file.user, User))
	end

	#Decode all the children properties from the derived file object
	defp decode_children(%DerivedFiles{} = files) do
		files
			|> Map.put( :image_thumb_200s, decode(files.image_thumb_200s, ImageThumb))
			|> Map.put( :image_thumb_960r, decode(files.image_thumb_960r, ImageThumb))
	end

	defp decode_children(%ImageThumb{} = thumb) do
		thumb
			|> Map.put( :image_info, decode(thumb.image_info, ImageInfo))
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