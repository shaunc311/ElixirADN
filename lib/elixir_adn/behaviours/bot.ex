defmodule ElixirADN.Behaviours.Bot do
	use Behaviour
	import BlockTimer

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
	def start_bot(bot_logic, account_name, auth_token, start_post_id, interval_seconds) do
		#Store the post id for reference
		{:ok, post_ref} = Agent.start_link (fn -> start_post_id end)
		#Check for posts on the interval
		{:ok, {:interval, timer_ref}} = apply_interval interval_seconds |> seconds do
			check_for_posts(bot_logic, account_name, auth_token, post_ref)
		end
		{:ok, timer_ref}
	end

	#Check for posts since the last post and call on_post_mention for each one
	defp check_for_posts(bot_logic, account_name, auth_token, post_ref) do
		IO.puts "looking for post mentions"
		#Get the last post id
		last_checked_id =  Agent.get(post_ref, fn(post_id) -> post_id end)
		#Get the mentions since the last interval
		{:ok, posts }= ElixirADN.Endpoints.User.get_mentions(account_name, auth_token, %ElixirADN.Endpoints.Parameters.PostParameters{}, %ElixirADN.Endpoints.Parameters.Pagination{since_id: last_checked_id})
		#Process each mention
		Enum.each( posts, fn(post) -> apply(bot_logic, :on_post_mention, [post]) end) 
		case length(posts) do
			0 -> nil
			_ -> 
				#these come in reverse post order, so the top one is the newest
				post = hd(posts)
				#store it in the agent so we start from the right place next interval
				Agent.update(post_ref, fn(_old_post_id) -> post.id end)
		end
		:ok
	end

end