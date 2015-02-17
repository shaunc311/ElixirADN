defmodule ElixirADN.Endpoints.Subscription do
	alias ElixirADN.Endpoints.Parameters.Encoder
	alias ElixirADN.Endpoints.Parameters.SubscriptionParameters

	@doc ~S"""
	The url to subscribe to all the users following you

	## Examples

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:following_me, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{}}, "5" )
			{:ok, "https://api.app.net/users/me/following?connection_id=5" }

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:following_me, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: true}}, "5")
			{:ok, "https://api.app.net/users/me/following?include_incomplete=1&connection_id=5" }

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:following_me, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: "bad"}}, "5")
			{:error, {:invalid_boolean_value, :include_incomplete, "bad"}}

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:my_followers, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: true}}, "5" )
			{:ok, "https://api.app.net/users/me/followers?include_incomplete=1&connection_id=5" }

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:my_posts, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: true}}, "5" )
			{:ok, "https://api.app.net/users/me/posts?include_incomplete=1&connection_id=5" }

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:my_mentions, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: true}}, "5")
			{:ok, "https://api.app.net/users/me/mentions?include_incomplete=1&connection_id=5" }

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:post_replies, "15", %ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: true}}, "5")
			{:ok, "https://api.app.net/posts/15/replies?include_incomplete=1&connection_id=5" }

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:hashtag_posts, "15", %ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: true}}, "5")
			{:ok, "https://api.app.net/posts/tag/15?include_incomplete=1&connection_id=5" }

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:personal, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: true}}, "5")
			{:ok, "https://api.app.net/posts/stream?include_incomplete=1&connection_id=5" }

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:unified, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: true}}, "5")
			{:ok, "https://api.app.net/posts/stream/unified?include_incomplete=1&connection_id=5" }

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:my_channels, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: true}}, "5")
			{:ok, "https://api.app.net/channels?include_incomplete=1&connection_id=5" }

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:channel_subscribers, "15", %ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: true}}, "5")
			{:ok, "https://api.app.net/channels/15/subscribers?include_incomplete=1&connection_id=5" }

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:channel_messages, "15", %ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: true}}, "5")
			{:ok, "https://api.app.net/channels/15/messages?include_incomplete=1&connection_id=5" }

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:my_files, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: true}}, "5")
			{:ok, "https://api.app.net/users/me/files?include_incomplete=1&connection_id=5" }

			iex> ElixirADN.Endpoints.Subscription.subscribe( {:my_token, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{include_incomplete: true}}, "5")
			{:ok, "https://api.app.net/token?include_incomplete=1&connection_id=5" }

	"""

	def subscribe({:following_me, %SubscriptionParameters{} = parameters}, connection_id) do
		append_query_string( "https://api.app.net/users/me/following", connection_id, parameters)
	end

	def subscribe({:my_followers, %SubscriptionParameters{} = parameters}, connection_id) do
		append_query_string( "https://api.app.net/users/me/followers", connection_id, parameters)
	end

	def subscribe({:my_posts, %SubscriptionParameters{} = parameters}, connection_id) do
		append_query_string( "https://api.app.net/users/me/posts", connection_id, parameters)
	end

	def subscribe({:my_mentions, %SubscriptionParameters{} = parameters}, connection_id) do
		append_query_string( "https://api.app.net/users/me/mentions", connection_id, parameters)
	end

	def subscribe({:post_replies, post_id, %SubscriptionParameters{} = parameters}, connection_id ) do
		append_query_string( "https://api.app.net/posts/#{post_id}/replies", connection_id, parameters)
	end

	def subscribe({:hashtag_posts, hashtag, %SubscriptionParameters{} = parameters}, connection_id) do
		append_query_string( "https://api.app.net/posts/tag/#{hashtag}", connection_id, parameters)
	end

	def subscribe({:personal, %SubscriptionParameters{} = parameters}, connection_id) do
		append_query_string( "https://api.app.net/posts/stream", connection_id, parameters)
	end

	def subscribe({:unified, %SubscriptionParameters{} = parameters}, connection_id ) do
		append_query_string( "https://api.app.net/posts/stream/unified", connection_id, parameters)
	end

	def subscribe({:my_channels, %SubscriptionParameters{} = parameters}, connection_id) do
		append_query_string( "https://api.app.net/channels", connection_id, parameters)
	end

	def subscribe({:channel_subscribers, channel_id, %SubscriptionParameters{} = parameters}, connection_id) do
		append_query_string( "https://api.app.net/channels/#{channel_id}/subscribers", connection_id, parameters)
	end

	def subscribe({:channel_messages, channel_id, %SubscriptionParameters{} = parameters}, connection_id ) do
		append_query_string( "https://api.app.net/channels/#{channel_id}/messages", connection_id, parameters)
	end

	def subscribe({:my_files, %SubscriptionParameters{} = parameters}, connection_id) do
		append_query_string( "https://api.app.net/users/me/files", connection_id, parameters)
	end

	def subscribe({:my_token, %SubscriptionParameters{} = parameters}, connection_id ) do
		append_query_string( "https://api.app.net/token", connection_id, parameters)
	end

	defp append_query_string(url, connection_id, %SubscriptionParameters{} = parameters) do
		query_result = Encoder.generate_query_string([parameters])
			case query_result do
			{:ok, query_string} -> format_query_string(connection_id, url, query_string)
			error -> error
		end
	end

	defp format_query_string(connection_id, url, query_string) do
		case String.length(query_string) > 0 do
			false -> {:ok, url <> "?connection_id=#{connection_id}" }
			true -> {:ok, url <> "#{query_string}&connection_id=#{connection_id}" }
		end
	end
end