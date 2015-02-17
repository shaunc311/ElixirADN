defmodule ElixirADN.Behaviours.Bot do
	alias ElixirADN.Endpoints.Parameters.StreamEndpointParameters
	alias ElixirADN.Endpoints.Parameters.SubscriptionParameters
	alias ElixirADN.Endpoints.UserStream
	use Behaviour



	@moduledoc ~S"""
	From the ADN docs on what a bot account can do:
	bot means that this account interacts with other App.net users without 
	a human’s involvement. If your account mentions or sends messages to other 
	App.net users without a human’s interaction, it must be classified as a Bot 
	to comply with Appp.net’s Terms of Service. A bot account has the following 
	restrictions:

	* A bot can only follow users who follow the bot.
	* A bot can only initiate Channels with users who follow the bot. This means that a bot can only auto-subscribe its followers to channels.
	* A bot’s posts do not appear in the global stream.
	* A bot can only mention users who follow the bot.
	"""

	@doc ~S"""
	Define what happens when the bot is mentioned in a post.  Should just 
	return :ok
	"""
	defcallback on_post_mention(ElixirADN.Model.Post.t) :: atom

	@doc ~S"""
	Define what happens when the bot is mentioned in a channel message.
	Should just return :ok
	"""
	defcallback on_message_mention(ElixirADN.Model.Message.t) :: atom


	@doc ~S"""
	Starts the bot and waits for messages on the given interval
	"""
	def start_bot(bot_logic, username, auth_token) do
		#UserStream.stream(auth_token, %StreamEndpointParameters{}, [{:my_mentions, %SubscriptionParameters{}}])
		UserStream.stream(auth_token, %StreamEndpointParameters{}, [{:channel_messages, "59922", %SubscriptionParameters{}}])
			|> Stream.filter( fn(x) -> not_from_bot?(username,x) end)
			|> Stream.filter( fn(x) -> mentions_bot?(username,x) end)
			|> Enum.map( fn(x) -> apply( bot_logic, :on_message_mention, [x]) end)

	end

	defp mentions_bot?(username, %ElixirADN.Model.Message{} = message) do
		mentions?(username, message.entities.mentions)
	end

	defp mentions_bot?(username, %ElixirADN.Model.Post{} = post) do
		mentions?(username, post.entities.mentions)
	end

	defp not_from_bot?(username, %ElixirADN.Model.Message{} = message) do
		is_not_bot?(username, message.user.username)
	end

	defp not_from_bot?(username, %ElixirADN.Model.Post{} = post) do
		is_not_bot?(username, post.user.username)
	end

	defp mentions?(username, mentions) when is_list(mentions) do
		Enum.any?(mentions, fn(x) -> "@"<>x.name == username end )
	end

	defp is_not_bot?(username, post_username) do
		username != "@"<>post_username
	end
end