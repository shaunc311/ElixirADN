defmodule ElixirADN.Behaviours.Bot do
	use Behaviour
	import BlockTimer

	@moduledoc ~S"""
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
	Starts the bot and waits for messages
	"""
	def start_bot(bot_logic, account_name, auth_token) do
		#every minute? we look for new data
		last_post_id = get_last_post_id(account_name)
		last_message_id = get_last_message_id(account_name)
		{:ok, post_ref} = Agent.start_link (fn -> last_post_id end)
		{:ok, message_ref} = Agent.start_link (fn -> last_message_id end)
		{:ok, {:interval, timer_ref}} = apply_interval 30 |> seconds do
			check_for_posts(bot_logic, account_name, auth_token, post_ref)
			check_for_messages(bot_logic, account_name, auth_token, message_ref)
		end
		{:ok, timer_ref}
	end

	def check_for_posts(bot_logic, account_name, auth_token, post_ref) do
		IO.puts "looking for post mentions"
		last_checked_id =  Agent.get(post_ref, fn(count) -> count end)
		{:ok, posts }= ElixirADN.Endpoints.User.get_mentions(account_name, auth_token, %ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{since_id: last_checked_id})
		Enum.each( posts, fn(post) -> apply(bot_logic, :on_post_mention, [post]) end) 
		case length(posts) do
			0 -> nil
			_ -> 
				#these come in reverse post order, so the top one is the newest
				post = hd(posts)
				Agent.update(post_ref, fn(_old_post_id) -> post.id end)
				store_last_post_id(account_name, post.id)
		end
		:ok
	end

	def check_for_messages(_bot_logic, _account_name, _auth_token, _message_ref) do
		#IO.puts "messages!"
	end

	defp get_last_post_id(account_name) do
		path = "#{account_name}.last_post_id"
		case File.exists?(path) do
			false -> "0"
			true -> File.read!(path)
		end
	end

	defp store_last_post_id(account_name, value) do
		File.write("#{account_name}.last_post_id", value)
	end

	defp get_last_message_id(account_name) do
		path = "#{account_name}.last_message_id"
		case File.exists?(path) do
			false -> "0"
			true -> File.read!(path)
		end
	end

	defp store_last_message_id(account_name, value) do
		File.write("#{account_name}.last_message_id", value)
	end
end